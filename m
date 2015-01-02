From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Fri, 02 Jan 2015 14:57:53 -0800
Message-ID: <54A72271.8010100@cumulusnetworks.com>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com> <54A63186.1090807@cumulusnetworks.com> <CAE4R7bBJa8LiDHw8PhL6ARfK5nOfUXg36tfnggwWs=tynBw6Jw@mail.gmail.com> <E4CD12F19ABA0C4D8729E087A761DC3505DD315B@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Smlyw60gUMOtcmtv?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:60189 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbbABW54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:57:56 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so24447886pdj.28
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 14:57:55 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DD315B@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/2/15, 3:39 AM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org] On
>> Behalf Of Scott Feldman
>> Sent: Friday, January 02, 2015 10:01 AM
>> To: roopa
>> Cc: Netdev; Ji=C5=99=C3=AD P=C3=ADrko; john fastabend; Thomas Graf; =
Jamal Hadi Salim; Andy
>> Gospodarek
>> Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support =
for swdev
>>
>> On Thu, Jan 1, 2015 at 9:49 PM, roopa <roopa@cumulusnetworks.com> wr=
ote:
>>> On 1/1/15, 7:29 PM, sfeldma@gmail.com wrote:
>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> To offload IPv4 L3 routing functions to swdev device, the swdev de=
vice
>>>> driver
>>>> implements two new ndo ops (ndo_switch_fib_ipv4_add/del).  The ops=
 are
>>>> called
>>>> by the core IPv4 FIB code when installing/removing FIB entries to/=
from the
>>>> kernel FIB.  On install, the driver should return 0 if FIB entry (=
route)
>>>> can be
>>>> installed to device for offloading, -EOPNOTSUPP if route cannot be
>>>> installed
>>>> due to device limitations, and other negative error code on failur=
e to
>>>> install
>>>> route to device.  On failure error code, the route is not installe=
d to
>>>> device,
>>>> and not installed in kernel FIB, and the return code is propagated=
 back to
>>>> the
>>>> user-space caller (via netlink).  An -EOPNOTSUPP error code is ski=
pped for
>>>> the
>>>> device but installed in the kernel FIB.
>>>>
>>>> The FIB entry (route) nexthop list is used to find the swdev devic=
e port
>>>> to
>>>> anchor the ndo op call.  The route's fib_dev (the first nexthop's =
dev) is
>>>> used
>>>> find the swdev port by recursively traversing the fib_dev's lower_=
dev list
>>>> until a swdev port is found.  The ndo op is called on this swdev p=
ort.
>>>
>>> scott, I posted a similar api for bridge attribute sets. But, nobod=
y
>>> supported it.
>>> http://marc.info/?l=3Dlinux-netdev&m=3D141820234410602&w=3D2
>>>
>>> If this is acceptable, I will be resubmitting my api as well.
>>>
>> This may get shot down as well, who knows?
>>
>> For routes, the nexthop dev may be a bridge or a bond for an IP on t=
he
>> router, so we have no choice but to walk down from the bridge or the
>> bond to find a swport dev to call the ndo op to install the route.
>>
> Another case is when VLAN-aware bridge with VLAN filtering is used. I=
n that
> case IP interfaces are VLAN interfaces created on top of the bridge.
>
>> For bridge settings, I remember someone raised the issue that settin=
gs
>> should be propagated down the dev hierarchy, with parent calling
>> child's op and so on.  I'll go back and look at your post.
>>
> This was my comment. I'm not sure it was correct. My concern was the =
VLAN
> interface on top of a VLAN-aware bridge use-case. I now believe that =
such
> interfaces are upper devices of the bridge (not master). Therefore, i=
t seems
> that traversal starting at a VLAN interface on top of a bridge will f=
ollow a
> path: VLAN interface =3D> bridge =3D> [team/bond] =3D> switchdev port=
=2E
for l3 this seems right. My patches were doing the same thing only for=20
l2...vlan filtering bridge,
and those were only for bridge attributes (learning, flooding etc),=20
which will be like below:
bridge =3D> [team/bond] =3D> switchdev port.

> One complication here is that the VLAN context is important. A "naked=
" nexthop
> shall only be resolved within the VLAN associated with the VLAN inter=
face. When
> ARP resolution is performed by Linux stack, it goes via the VLAN inte=
rface
> which imposes a tag on the packet before handing it to the bridge. Th=
e VLAN-
> aware bridge floods such packet only to member ports of the VLAN. Thi=
s behavior
> of the software bridge has to be preserved with offloaded L3 forwardi=
ng and
> offloaded L2 switching.
>>>
>>>> Since the FIB entry is "naked" when push from the kernel, the
>>>> driver/device
>>>> is responsible for resolving the route's nexthops to neighbor MAC
>>>> addresses.
>>>> This can be done by the driver by monitoring NETEVENT_NEIGH_UPDATE
>>>> netevent notifier to watch for ARP activity.  Once a nexthop is re=
solved
>>>> to
>>>> neighbor MAC address, it can be installed to the device and the de=
vice
>>>> will
>>>> do the L3 routing offload in HW, for that nexthop.
>>>>
>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>> ---
>>>>    include/linux/netdevice.h |   22 +++++++++++
>>>>    include/net/switchdev.h   |   18 +++++++++
>>>>    net/ipv4/fib_trie.c       |   17 ++++++++-
>>>>    net/switchdev/switchdev.c |   89
>>>> +++++++++++++++++++++++++++++++++++++++++++++
>>>>    4 files changed, 145 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>> index 679e6e9..b66d22b 100644
>>>> --- a/include/linux/netdevice.h
>>>> +++ b/include/linux/netdevice.h
>>>> @@ -767,6 +767,8 @@ struct netdev_phys_item_id {
>>>>    typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>>>                                         struct sk_buff *skb);
>>>>    +struct fib_info;
>>>> +
>>>>    /*
>>>>     * This structure defines the management hooks for network devi=
ces.
>>>>     * The following hooks can be defined; unless noted otherwise, =
they are
>>>> @@ -1030,6 +1032,14 @@ typedef u16 (*select_queue_fallback_t)(stru=
ct
>>>> net_device *dev,
>>>>     * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8=
 state);
>>>>     *    Called to notify switch device port of bridge port STP
>>>>     *    state change.
>>>> + * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be=
32 dst,
>>>> + *                                  int dst_len, struct fib_info =
*fi,
>>>> + *                                  u8 tos, u8 type, u32 tb_id);
>>>> + *     Called to add IPv4 route to switch device.
>>>> + * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be=
32 dst,
>>>> + *                                  int dst_len, struct fib_info =
*fi,
>>>> + *                                  u8 tos, u8 type, u32 tb_id);
>>>> + *     Called to delete IPv4 route from switch device.
>>>>     */
>>>>    struct net_device_ops {
>>>>          int                     (*ndo_init)(struct net_device *de=
v);
>>>> @@ -1189,6 +1199,18 @@ struct net_device_ops {
>>>>                                                              struc=
t
>>>> netdev_phys_item_id *psid);
>>>>          int                     (*ndo_switch_port_stp_update)(str=
uct
>>>> net_device *dev,
>>>>                                                                u8 =
state);
>>>> +       int                     (*ndo_switch_fib_ipv4_add)(struct
>>>> net_device *dev,
>>>> +                                                          __be32 =
dst,
>>>> +                                                          int dst=
_len,
>>>> +                                                          struct =
fib_info
>>>> *fi,
>>>> +                                                          u8 tos,=
 u8
>>>> type,
>>>> +                                                          u32 tb_=
id);
>>>> +       int                     (*ndo_switch_fib_ipv4_del)(struct
>>>> net_device *dev,
>>>> +                                                          __be32 =
dst,
>>>> +                                                          int dst=
_len,
>>>> +                                                          struct =
fib_info
>>>> *fi,
>>>> +                                                          u8 tos,=
 u8
>>>> type,
>>>> +                                                          u32 tb_=
id);
>>>>    #endif
>>>>    };
>>>>    diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>>> index 8a6d164..caebc2a 100644
>>>> --- a/include/net/switchdev.h
>>>> +++ b/include/net/switchdev.h
>>>> @@ -17,6 +17,10 @@
>>>>    int netdev_switch_parent_id_get(struct net_device *dev,
>>>>                                  struct netdev_phys_item_id *psid)=
;
>>>>    int netdev_switch_port_stp_update(struct net_device *dev, u8 st=
ate);
>>>> +int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_i=
nfo *fi,
>>>> +                              u8 tos, u8 type, u32 tb_id);
>>>> +int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_i=
nfo *fi,
>>>> +                              u8 tos, u8 type, u32 tb_id);
>>>>      #else
>>>>    @@ -32,6 +36,20 @@ static inline int
>>>> netdev_switch_port_stp_update(struct net_device *dev,
>>>>          return -EOPNOTSUPP;
>>>>    }
>>>>    +static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_=
len,
>>>> +                                            struct fib_info *fi,
>>>> +                                            u8 tos, u8 type, u32 =
tb_id)
>>>> +{
>>>> +       return -EOPNOTSUPP;
>>>> +}
>>>> +
>>>> +static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len=
,
>>>> +                                            struct fib_info *fi,
>>>> +                                            u8 tos, u8 type, u32 =
tb_id)
>>>> +{
>>>> +       return -EOPNOTSUPP;
>>>> +}
>>>> +
>>>>    #endif
>>>>      #endif /* _LINUX_SWITCHDEV_H_ */
>>>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>>> index 281e5e0..ea2dc17 100644
>>>> --- a/net/ipv4/fib_trie.c
>>>> +++ b/net/ipv4/fib_trie.c
>>>> @@ -79,6 +79,7 @@
>>>>    #include <net/tcp.h>
>>>>    #include <net/sock.h>
>>>>    #include <net/ip_fib.h>
>>>> +#include <net/switchdev.h>
>>>>    #include "fib_lookup.h"
>>>>      #define MAX_STAT_DEPTH 32
>>>> @@ -1201,6 +1202,8 @@ int fib_table_insert(struct fib_table *tb, s=
truct
>>>> fib_config *cfg)
>>>>                          fib_release_info(fi_drop);
>>>>                          if (state & FA_S_ACCESSED)
>>>>                                  rt_cache_flush(cfg->fc_nlinfo.nl_=
net);
>>>> +                       netdev_switch_fib_ipv4_add(key, plen, fi,
>>>> fa->fa_tos,
>>>> +                                                  cfg->fc_type,
>>>> tb->tb_id);
>>>>                          rtmsg_fib(RTM_NEWROUTE, htonl(key), new_f=
a, plen,
>>>>                                  tb->tb_id, &cfg->fc_nlinfo,
>>>> NLM_F_REPLACE);
>>>>    @@ -1229,6 +1232,13 @@ int fib_table_insert(struct fib_table *t=
b, struct
>>>> fib_config *cfg)
>>>>          new_fa->fa_tos =3D tos;
>>>>          new_fa->fa_type =3D cfg->fc_type;
>>>>          new_fa->fa_state =3D 0;
>>>> +
>>>> +       /* (Optionally) offload fib info to switch hardware. */
>>>> +       err =3D netdev_switch_fib_ipv4_add(key, plen, fi, tos,
>>>> +                                        cfg->fc_type, tb->tb_id);
>>>> +       if (err && err !=3D -EOPNOTSUPP)
>>>> +               goto out_free_new_fa;
>>>> +
>>>>          /*
>>>>           * Insert new entry to the list.
>>>>           */
>>>> @@ -1237,7 +1247,7 @@ int fib_table_insert(struct fib_table *tb, s=
truct
>>>> fib_config *cfg)
>>>>                  fa_head =3D fib_insert_node(t, key, plen);
>>>>                  if (unlikely(!fa_head)) {
>>>>                          err =3D -ENOMEM;
>>>> -                       goto out_free_new_fa;
>>>> +                       goto out_sw_fib_del;
>>>>                  }
>>>>          }
>>>>    @@ -1253,6 +1263,8 @@ int fib_table_insert(struct fib_table *tb=
, struct
>>>> fib_config *cfg)
>>>>    succeeded:
>>>>          return 0;
>>>>    +out_sw_fib_del:
>>>> +       netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_typ=
e,
>>>> tb->tb_id);
>>>>    out_free_new_fa:
>>>>          kmem_cache_free(fn_alias_kmem, new_fa);
>>>>    out:
>>>> @@ -1529,6 +1541,9 @@ int fib_table_delete(struct fib_table *tb, s=
truct
>>>> fib_config *cfg)
>>>>          rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
>>>>                    &cfg->fc_nlinfo, 0);
>>>>    +     netdev_switch_fib_ipv4_del(key, plen, fa->fa_info, tos,
>>>> +                                  cfg->fc_type, tb->tb_id);
>>>> +
>>>>          list_del_rcu(&fa->fa_list);
>>>>          if (!plen)
>>>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>>> index d162b21..211a8a0 100644
>>>> --- a/net/switchdev/switchdev.c
>>>> +++ b/net/switchdev/switchdev.c
>>>> @@ -12,6 +12,7 @@
>>>>    #include <linux/types.h>
>>>>    #include <linux/init.h>
>>>>    #include <linux/netdevice.h>
>>>> +#include <net/ip_fib.h>
>>>>    #include <net/switchdev.h>
>>>>      /**
>>>> @@ -50,3 +51,91 @@ int netdev_switch_port_stp_update(struct net_de=
vice
>>>> *dev, u8 state)
>>>>          return ops->ndo_switch_port_stp_update(dev, state);
>>>>    }
>>>>    EXPORT_SYMBOL(netdev_switch_port_stp_update);
>>>> +
>>>> +static struct net_device *netdev_switch_get_by_fib_dev(struct net=
_device
>>>> *dev)
>>>> +{
>>>> +       const struct net_device_ops *ops =3D dev->netdev_ops;
>>>> +       struct net_device *lower_dev;
>>>> +       struct net_device *port_dev;
>>>> +       struct list_head *iter;
>>>> +
>>>> +       /* Recusively search from fib_dev down until we find
>>>> +        * a sw port dev.  (A sw port dev supports
>>>> +        * ndo_switch_parent_id_get).
>>>> +        */
>>>> +
>>>> +       if (ops->ndo_switch_parent_id_get)
>>>> +               return dev;
>>>> +
>>>> +       netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>>> +               port_dev =3D netdev_switch_get_by_fib_dev(lower_de=
v);
>>>> +               if (port_dev)
>>>> +                       return port_dev;
>>>> +       }
>>>> +
>>>> +       return NULL;
>>>> +}
>>>> +
>>>> +/**
>>>> + *     netdev_switch_fib_ipv4_add - Add IPv4 route entry to switc=
h
>>>> + *
>>>> + *     @dst: route's IPv4 destination address
>>>> + *     @dst_len: destination address length (prefix length)
>>>> + *     @fi: route FIB info structure
>>>> + *     @tos: route TOS
>>>> + *     @type: route type
>>>> + *     @tb_id: route table ID
>>>> + *
>>>> + *     Add IPv4 route entry to switch device.
>>>> + */
>>>> +int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_i=
nfo *fi,
>>>> +                              u8 tos, u8 type, u32 tb_id)
>>>> +{
>>>> +       struct net_device *dev;
>>>> +       const struct net_device_ops *ops;
>>>> +       int err =3D -EOPNOTSUPP;
>>>> +
>>>> +       dev =3D netdev_switch_get_by_fib_dev(fi->fib_dev);
>>>> +       if (!dev)
>>>> +               return -EOPNOTSUPP;
>>>> +       ops =3D dev->netdev_ops;
>>>> +
>>>> +       if (ops->ndo_switch_fib_ipv4_add)
>>>> +               err =3D ops->ndo_switch_fib_ipv4_add(dev, htonl(ds=
t),
>>>> dst_len,
>>>> +                                                  fi, tos, type, =
tb_id);
>>>> +
>>>> +       return err;
>>>> +}
>>>> +EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
>>>> +
>>>> +/**
>>>> + *     netdev_switch_fib_ipv4_del - Delete IPv4 route entry from =
switch
>>>> + *
>>>> + *     @dst: route's IPv4 destination address
>>>> + *     @dst_len: destination address length (prefix length)
>>>> + *     @fi: route FIB info structure
>>>> + *     @tos: route TOS
>>>> + *     @type: route type
>>>> + *     @tb_id: route table ID
>>>> + *
>>>> + *     Delete IPv4 route entry from switch device.
>>>> + */
>>>> +int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_i=
nfo *fi,
>>>> +                              u8 tos, u8 type, u32 tb_id)
>>>> +{
>>>> +       struct net_device *dev;
>>>> +       const struct net_device_ops *ops;
>>>> +       int err =3D -EOPNOTSUPP;
>>>> +
>>>> +       dev =3D netdev_switch_get_by_fib_dev(fi->fib_dev);
>>>> +       if (!dev)
>>>> +               return -EOPNOTSUPP;
>>>> +       ops =3D dev->netdev_ops;
>>>> +
>>>> +       if (ops->ndo_switch_fib_ipv4_del)
>>>> +               err =3D ops->ndo_switch_fib_ipv4_del(dev, htonl(ds=
t),
>>>> dst_len,
>>>> +                                                  fi, tos, type, =
tb_id);
>>>> +
>>>> +       return err;
>>>> +}
>>>> +EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5
