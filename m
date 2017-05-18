From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net-next] geneve: add rtnl changelink support
Date: Thu, 18 May 2017 08:15:54 -0700
Message-ID: <f3f81e80-7b2b-45e8-1f65-f9144479a798@oracle.com>
References: <1494870424-22699-1-git-send-email-girish.moodalbail@oracle.com>
 <CAOrHB_CRBWb2odpyFBaZS0sJ=zK=ve4d8LRp0iVNJehghmsBGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, Jiri Benc <jbenc@redhat.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22061 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932643AbdERPQB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:16:01 -0400
In-Reply-To: <CAOrHB_CRBWb2odpyFBaZS0sJ=zK=ve4d8LRp0iVNJehghmsBGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TL DR; There is indeed a race between geneve_changelink() and geneve transmit 
path w.r.t attributes being changed and the old value of those attributes being 
used in the transmit patch. I will resubmit V2 of the patch with those issues 
addressed. Thanks!

Please see in-line for my other comments..

>
>> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
>> ---
>>  drivers/net/geneve.c | 149 ++++++++++++++++++++++++++++++++++++++++-----------
>>  1 file changed, 117 insertions(+), 32 deletions(-)
>>
> ...
>> @@ -1169,45 +1181,58 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
>>         info->key.tp_dst = htons(dst_port);
>>  }
>>
>> -static int geneve_newlink(struct net *net, struct net_device *dev,
>> -                         struct nlattr *tb[], struct nlattr *data[])
>> +static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
>> +                         struct nlattr *data[], struct ip_tunnel_info *info,
>> +                         bool *metadata, bool *use_udp6_rx_checksums,
>> +                         bool changelink)
>>  {
>> -       bool use_udp6_rx_checksums = false;
>> -       struct ip_tunnel_info info;
>> -       bool metadata = false;
>> +       struct geneve_dev *geneve = netdev_priv(dev);
>>
>> -       init_tnl_info(&info, GENEVE_UDP_PORT);
>> +       if (changelink) {
>> +               /* if changelink operation, start with old existing info */
>> +               memcpy(info, &geneve->info, sizeof(*info));
>> +               *metadata = geneve->collect_md;
>> +               *use_udp6_rx_checksums = geneve->use_udp6_rx_checksums;
>> +       } else {
>> +               init_tnl_info(info, GENEVE_UDP_PORT);
>> +       }
>>
>>         if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
>>                 return -EINVAL;
>>
>>         if (data[IFLA_GENEVE_REMOTE]) {
>> -               info.key.u.ipv4.dst =
>> +               info->key.u.ipv4.dst =
>>                         nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
>>
>> -               if (IN_MULTICAST(ntohl(info.key.u.ipv4.dst))) {
>> +               if (IN_MULTICAST(ntohl(info->key.u.ipv4.dst))) {
>>                         netdev_dbg(dev, "multicast remote is unsupported\n");
>>                         return -EINVAL;
>>                 }
>> +               if (changelink &&
>> +                   ip_tunnel_info_af(&geneve->info) == AF_INET6) {
>> +                       info->mode &= ~IP_TUNNEL_INFO_IPV6;
>> +                       info->key.tun_flags &= ~TUNNEL_CSUM;
>> +                       *use_udp6_rx_checksums = false;
>> +               }
> This allows changelink to change ipv4 address but there are no changes
> made to the geneve tunnel port hash table after this update.

The following code in geneve_changelink() does what you are asking for

+    if (!geneve_dst_addr_equal(&geneve->info, &info))
+        dst_cache_reset(&info.dst_cache);

geneve_nl2info() accrues all the allowed changes to be made and captures it in 
ip_tunnel_info structure and then the above code in geneve_changelink() ensures 
that all the route cache associated with the old remote address are released 
when the next lookup occurs.

> We also
> need to check to see if there is any conflicts with existing ports.

This is not needed since we don't support changing the remote port.

>
> What is the barrier between the rx/tx threads and changelink process?

There is an issue here like you pointed out (thanks!). Will fix that issue.

>
>>         }
>>
>>         if (data[IFLA_GENEVE_REMOTE6]) {
>>   #if IS_ENABLED(CONFIG_IPV6)
>> -               info.mode = IP_TUNNEL_INFO_IPV6;
>> -               info.key.u.ipv6.dst =
>> +               info->mode = IP_TUNNEL_INFO_IPV6;
>> +               info->key.u.ipv6.dst =
>>                         nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);
>>
>> -               if (ipv6_addr_type(&info.key.u.ipv6.dst) &
>> +               if (ipv6_addr_type(&info->key.u.ipv6.dst) &
>>                     IPV6_ADDR_LINKLOCAL) {
>>                         netdev_dbg(dev, "link-local remote is unsupported\n");
>>                         return -EINVAL;
>>                 }
>> -               if (ipv6_addr_is_multicast(&info.key.u.ipv6.dst)) {
>> +               if (ipv6_addr_is_multicast(&info->key.u.ipv6.dst)) {
>>                         netdev_dbg(dev, "multicast remote is unsupported\n");
>>                         return -EINVAL;
>>                 }
>> -               info.key.tun_flags |= TUNNEL_CSUM;
>> -               use_udp6_rx_checksums = true;
>> +               info->key.tun_flags |= TUNNEL_CSUM;
>> +               *use_udp6_rx_checksums = true;
> Same here. We need to check/fix the geneve tunnel hash table according
> to new IP address.

This is taken care by the call to dst_cache_reset() whenever the remote address 
changes. This function already takes care of races and contentions....

------------8<-----------------8<------
/**
  *      dst_cache_reset - invalidate the cache contents
  *      @dst_cache: the cache
  *
  *      This do not free the cached dst to avoid races and contentions.
  *      the dst will be freed on later cache lookup.
  */
static inline void dst_cache_reset(struct dst_cache *dst_cache)
{
         dst_cache->reset_ts = jiffies;
}
------------8<-----------------8<------

.... by setting reset_ts to current value of jiffies. After this, when we call 
dst_cache_get_ip4() to get a route entry for geneve packet we ensure that cache 
is old/obsolete/invalid/incorrect through the following check in that function

------------8<-----------------8<------
         if (unlikely(!time_after(idst->refresh_ts, dst_cache->reset_ts) ||
                      (dst->obsolete && !dst->ops->check(dst, idst->cookie)))) {
                 dst_cache_per_cpu_dst_set(idst, NULL, 0);
                 dst_release(dst);
                 goto fail;
         }
------------8<-----------------8<------

>
>>  #else
>>                 return -EPFNOSUPPORT;
>>  #endif
>> @@ -1216,48 +1241,107 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
> ...
>>
>> -       if (data[IFLA_GENEVE_PORT])
>> -               info.key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
>> +       if (data[IFLA_GENEVE_PORT]) {
>> +               if (changelink)
>> +                       return -EOPNOTSUPP;
>> +               info->key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
>> +       }
>> +
>> +       if (data[IFLA_GENEVE_COLLECT_METADATA]) {
>> +               if (changelink)
>> +                       return -EOPNOTSUPP;
> Rather than blindly returning error here it should check if the
> changelink is changing existing configuration.

I would like to start by saying that I have kept the same semantic as 
vxlan_changelink() here to keep the operations consistent across geneve and 
vxlan links.

Furthermore, will this not give a semantic that we do support changing metadata 
to an user? For example: Assume that there already existed geneve datalink with 
metadata enabled, now if I do

     # ip link set gen0 type geneve id 100 metadata

it will return success giving an idea that '[no]metadata' attribute is 
modifiable. So, when they try to do

      # ip link set gen0 type geneve id 100 nometadata

it will fail.

>
>> +               *metadata = true;
>> +       }
>> +
>> +       if (data[IFLA_GENEVE_UDP_CSUM]) {
>> +               if (changelink)
>> +                       return -EOPNOTSUPP;
>> +               if (nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
>> +                       info->key.tun_flags |= TUNNEL_CSUM;
>> +       }
>> +
> same here.

please see above

>
>> +       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]) {
>> +               if (changelink)
>> +                       return -EOPNOTSUPP;
>> +               if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
>> +                       info->key.tun_flags &= ~TUNNEL_CSUM;
> same here.

please see above

>
>> +       }
>>
>> -       if (data[IFLA_GENEVE_COLLECT_METADATA])
>> -               metadata = true;
>> +       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
>> +               if (changelink)
>> +                       return -EOPNOTSUPP;
>> +               if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
>> +                       *use_udp6_rx_checksums = false;
>> +       }
>>
>> -       if (data[IFLA_GENEVE_UDP_CSUM] &&
>> -           nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
>> -               info.key.tun_flags |= TUNNEL_CSUM;
>> +       return 0;
>> +}
>>
>> -       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
>> -           nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
>> -               info.key.tun_flags &= ~TUNNEL_CSUM;
>> +static int geneve_newlink(struct net *net, struct net_device *dev,
>> +                         struct nlattr *tb[], struct nlattr *data[])
>> +{
>> +       bool use_udp6_rx_checksums = false;
>> +       struct ip_tunnel_info info;
>> +       bool metadata = false;
>> +       int err;
>>
>> -       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX] &&
>> -           nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
>> -               use_udp6_rx_checksums = false;
>> +       err = geneve_nl2info(dev, tb, data, &info, &metadata,
>> +                            &use_udp6_rx_checksums, false);
>> +       if (err)
>> +               return err;
>>
>>         return geneve_configure(net, dev, &info, metadata, use_udp6_rx_checksums);
>>  }
>>
>> +static int geneve_changelink(struct net_device *dev, struct nlattr *tb[],
>> +                            struct nlattr *data[])
>> +{
>> +       struct geneve_dev *geneve = netdev_priv(dev);
>> +       struct ip_tunnel_info info;
>> +       bool metadata = false;
>> +       bool use_udp6_rx_checksums = false;
>> +       int err;
>> +
>> +       err = geneve_nl2info(dev, tb, data, &info, &metadata,
>> +                            &use_udp6_rx_checksums, true);
>> +       if (err)
>> +               return err;
>> +
>> +       if (!geneve_dst_addr_equal(&geneve->info, &info))
>> +               dst_cache_reset(&info.dst_cache);
>> +       geneve->info = info;
> This would just overwrite dst-cache, which could leak the percpu
> cached dst-entry objects.

It will not. The ip_tunnel_info`dst_cache is a struct with a pointer to per_cpu 
struct and reset_ts. We copy this structure at the beginning of 
geneve_changelink() and this is done under rtnl_lock(). That 
ip_tunnel_info`dst_cache`per_cpu struct doesn't change throughout the operation 
but only reset_ts is set to 'jiffies' if the remote address changes.

Thanks,
~Girish
