From: Madhu Challa <challa@noironetworks.com>
Subject: Re: [PATCH net-next v4 2/2] multicast: Extend ip address command to
 enable multicast group join/leave on IP level.
Date: Tue, 24 Feb 2015 10:14:59 -0800
Message-ID: <CAN_zqfN84bpeLib+u58_BQx8iCsK4SyT9DUXr27ptXesLye1+A@mail.gmail.com>
References: <1424739550-2691-1-git-send-email-challa@noironetworks.com>
	<1424739550-2691-3-git-send-email-challa@noironetworks.com>
	<54EC4EE4.2010307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38492 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbbBXSPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 13:15:00 -0500
Received: by padbj1 with SMTP id bj1so37861603pad.5
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 10:14:59 -0800 (PST)
In-Reply-To: <54EC4EE4.2010307@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 2:13 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/24/2015 01:59 AM, Madhu Challa wrote:
> ...
>>
>> This patch applies on top of:
>> - 959d10f6bbf6 [PATCH net-next] igmp: add __ip_mc_{join|leave}_group()
>> - igmp v6: add __ipv6_sock_mc_join and __ipv6_sock_mc_drop
>
>
> This above does not really belong into the commit message. Can be moved
> into the cover letter or below the patch's "---" marker, but since Eric's
> commit is in net-next already and your set against net-next as indicated
> in the subject, you don't need to mention it here specifically.
>
>> Signed-off-by: Madhu Challa <challa@noironetworks.com>
>> ---
>>   include/net/netns/ipv4.h     |  1 +
>>   include/net/netns/ipv6.h     |  1 +
>>   include/uapi/linux/if_addr.h |  1 +
>>   net/ipv4/devinet.c           | 31 +++++++++++++++++++++++++++++++
>>   net/ipv4/igmp.c              | 14 ++++++++++++++
>>   net/ipv6/addrconf.c          | 38 +++++++++++++++++++++++++++++++++++---
>>   net/ipv6/mcast.c             | 20 ++++++++++++++++----
>>   7 files changed, 99 insertions(+), 7 deletions(-)
>>
> ...
>>
>> diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
>> index dea10a8..40fdfea 100644
>> --- a/include/uapi/linux/if_addr.h
>> +++ b/include/uapi/linux/if_addr.h
>> @@ -50,6 +50,7 @@ enum {
>>   #define IFA_F_PERMANENT               0x80
>>   #define IFA_F_MANAGETEMPADDR  0x100
>>   #define IFA_F_NOPREFIXROUTE   0x200
>> +#define IFA_F_MCAUTOJOIN       0x400
>>
>>   struct ifa_cacheinfo {
>>         __u32   ifa_prefered;
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index 3a8985c..eae89c5 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -548,6 +548,26 @@ struct in_ifaddr *inet_ifa_byprefix(struct in_device
>> *in_dev, __be32 prefix,
>>         return NULL;
>>   }
>>
>> +static int ip_mc_config(struct sock *sk, bool join, struct in_ifaddr
>> *ifa)
>> +{
>
>
> const struct in_ifaddr *ifa
>
>> +       struct ip_mreqn mreq = {
>> +               .imr_multiaddr.s_addr = ifa->ifa_address,
>> +               .imr_ifindex = ifa->ifa_dev->dev->ifindex,
>> +       };
>> +       int ret;
>> +
>> +       ASSERT_RTNL();
>> +
>> +       lock_sock(sk);
>> +       if (join)
>> +               ret = __ip_mc_join_group(sk, &mreq);
>> +       else
>> +               ret = __ip_mc_leave_group(sk, &mreq);
>> +       release_sock(sk);
>> +
>> +       return ret;
>> +}
>
> ...
>>
>> @@ -2740,6 +2741,8 @@ static const struct file_operations
>> igmp_mcf_seq_fops = {
>>   static int __net_init igmp_net_init(struct net *net)
>>   {
>>         struct proc_dir_entry *pde;
>> +       struct socket *sock;
>
>
> sock is unused now, should be removed.
>
>> +       int err;
>>
>>         pde = proc_create("igmp", S_IRUGO, net->proc_net,
>> &igmp_mc_seq_fops);
>>         if (!pde)
>> @@ -2748,8 +2751,18 @@ static int __net_init igmp_net_init(struct net
>> *net)
>>                           &igmp_mcf_seq_fops);
>>         if (!pde)
>>                 goto out_mcfilter;
>> +       err = inet_ctl_sock_create(&net->ipv4.mc_autojoin_sk, AF_INET,
>> +                                  SOCK_DGRAM, 0, net);
>> +       if (err < 0) {
>> +               pr_err("Failed to initialize the IGMP autojoin socket (err
>> %d)\n",
>> +                      err);
>> +               goto out_sock;
>> +       }
>> +
>>         return 0;
>
> ...
>>
>> @@ -2476,10 +2493,10 @@ static int inet6_addr_add(struct net *net, int
>> ifindex,
>>         struct inet6_ifaddr *ifp;
>>         struct inet6_dev *idev;
>>         struct net_device *dev;
>> +       unsigned long timeout;
>> +       clock_t expires;
>>         int scope;
>>         u32 flags;
>> -       clock_t expires;
>> -       unsigned long timeout;
>
>
> I think this (unrelated) reordering was a leftover from the previous
> version?

yes. I reordered it after Davids comment on ordering of local
variables, longest to shortest. I had a ret here but it was moved to
the scope where it was being used.

I will take care of your remaining comments and send out a new patch.

Thanks !
>
>>         ASSERT_RTNL();
>>
>> @@ -2501,6 +2518,14 @@ static int inet6_addr_add(struct net *net, int
>> ifindex,
>>         if (IS_ERR(idev))
>>                 return PTR_ERR(idev);
>>
>> +       if (ifa_flags & IFA_F_MCAUTOJOIN) {
>> +               int ret = ipv6_mc_config(net->ipv6.mc_autojoin_sk,
>
> ...
>
> Thanks a lot,
> Daniel
