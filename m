From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 21:58:37 +0200
Message-ID: <1433793517.4616.4.camel@stressinduktion.org>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, dsahern@gmail.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:52796 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753059AbbFHT6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:58:42 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id D298020A27
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 15:58:41 -0400 (EDT)
In-Reply-To: <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shrijeet,

On Mo, 2015-06-08 at 11:35 -0700, Shrijeet Mukherjee wrote:
> From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> 
> Incoming frames for IP protocol stacks need the IIF to be changed
> from the actual interface to the VRF device. This allows the IIF
> rule to be used to select tables (or do regular PBR)
> 
> This change selects the iif to be the VRF device if it exists and
> the incoming iif is enslaved to the VRF device.
> 
> Since VRF aware sockets are always bound to the VRF device this
> system allows return traffic to find the socket of origin.
> 
> changes are in the arp_rcv, icmp_rcv and ip_rcv paths
> 
> Question : I did not wrap the rcv modifications, in CONFIG_NET_VRF
> as it would create code variations and the vrf_ptr check is there
> I can make that whole thing modular.

>From an architectural level I think the output path looks good. For the
input path I would also to propose my (I think) more flexible solution:

For rx layer I want to also propose my try:

[PATCH net-next RFC] net: ipv4: arp: strong end system model semantics by per-interface local table override

By allowing to direct routing table lookups to a specific table based
on the incoming interface for IPv4 and ARP, we start to behave like a
strong end host system without tweaking arp_* sysctl settings.

The main motivation behind this patch was input and forwarding support
in a VRF like model. Maybe it also helps for hardware offloading by
allowing reducing rule complexity.

An example:

$ ip rule flush
$ ip rule del
$ ip rule del
$ ip rule add inherit-table
0:      from all inherit-table

This by default still uses RT_TABLE_LOCAL until we set up per interface
route tables:

$ ip link set dev enp0s25 ipv4-rt-table-id 100
$ ip -d link ls dev enp0s25
2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether e4:7f:b2:1b:4c:61 brd ff:ff:ff:ff:ff:ff promiscuity 0 ipv4-rt-table-id 100 addrgenmode none

This let's incoming and arp requests use routing table 100. The system
will stop responding to arp requests as we don't have any entries in
this routing table.

$ ip address add 192.168.88.223/24 dev enp0s25 table 100
$ ip -d address ls
2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether e4:7f:b2:1b:4c:61 brd ff:ff:ff:ff:ff:ff promiscuity 0
    inet 192.168.88.223/24 scope global enp0s25 table 100
       valid_lft forever preferred_lft forever
$ ip route add 192.168.88.0/24 dev enp0s25 table 100
$ ip route add default via 192.168.88.1 table 100
$ ip route ls dev table 100
local 192.168.88.223 dev enp0s25  proto kernel  scope host  src 192.168.88.223
192.168.88.0/24 dev enp0s25  scope link
default via 192.168.88.1 dev enp0s25 proto static metric 600

Those changes direct arp lookups towards table 100 and the input route,
too. The local address is used for icmp source addresses and arp
replies. The connected route to steer icmp packets out of that interface.

This patch covers only the forwarding path.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/inetdevice.h        | 19 ++++++++++++++++---
 include/net/flow.h                |  2 ++
 include/uapi/linux/fib_rules.h    |  1 +
 include/uapi/linux/if_addr.h      |  1 +
 include/uapi/linux/if_link.h      |  1 +
 net/core/fib_rules.c              | 12 +++++++++---
 net/ipv4/devinet.c                | 18 +++++++++++++++++-
 net/ipv4/fib_frontend.c           | 11 +++++++++--
 net/ipv4/fib_rules.c              |  7 ++++++-
 net/ipv4/fib_semantics.c          |  4 +++-
 net/ipv4/icmp.c                   |  1 +
 net/ipv4/netfilter/ipt_rpfilter.c |  1 +
 net/ipv4/route.c                  |  1 +
 13 files changed, 68 insertions(+), 11 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 0a21fbe..ed68f8e 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -25,19 +25,20 @@ struct in_device {
        atomic_t                refcnt;
        int                     dead;
        struct in_ifaddr        *ifa_list;      /* IP ifaddr chain              */
+       u32                     rt_table_id;
 
        struct ip_mc_list __rcu *mc_list;       /* IP multicast filter chain    */
        struct ip_mc_list __rcu * __rcu *mc_hash;
 
        int                     mc_count;       /* Number of installed mcasts   */
+       unsigned char           mr_qrv;
+       unsigned char           mr_gq_running;
+       unsigned char           mr_ifc_count;
        spinlock_t              mc_tomb_lock;
        struct ip_mc_list       *mc_tomb;
        unsigned long           mr_v1_seen;
        unsigned long           mr_v2_seen;
        unsigned long           mr_maxdelay;
-       unsigned char           mr_qrv;
-       unsigned char           mr_gq_running;
-       unsigned char           mr_ifc_count;
        struct timer_list       mr_gq_timer;    /* general query timer */
        struct timer_list       mr_ifc_timer;   /* interface change timer */
 
@@ -145,6 +146,7 @@ struct in_ifaddr {
        __u32                   ifa_preferred_lft;
        unsigned long           ifa_cstamp; /* created timestamp */
        unsigned long           ifa_tstamp; /* updated timestamp */
+       __u32                   ifa_rt_table; /* subnet route table */
 };
 
 int register_inetaddr_notifier(struct notifier_block *nb);
@@ -237,6 +239,17 @@ static inline void in_dev_put(struct in_device *idev)
 #define __in_dev_put(idev)  atomic_dec(&(idev)->refcnt)
 #define in_dev_hold(idev)   atomic_inc(&(idev)->refcnt)
 
+static inline u32 ipv4_idev_rt_table(const struct net_device *dev)
+{
+       u32 table_id;
+
+       rcu_read_lock();
+       table_id = __in_dev_get_rcu(dev)->rt_table_id;
+       rcu_read_unlock();
+
+       return table_id != RT_TABLE_UNSPEC ? table_id : RT_TABLE_LOCAL;
+}
+
 #endif /* __KERNEL__ */
 
 static __inline__ __be32 inet_make_mask(int logmask)
diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a15..635e028 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -70,6 +70,8 @@ struct flowi4 {
        /* (saddr,daddr) must be grouped, same order as in IP header */
        __be32                  saddr;
        __be32                  daddr;
+       __u32                   rt_table_id;
+
 
        union flowi_uli         uli;
 #define fl4_sport              uli.ports.sport
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 2b82d7e..da7c79a 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -64,6 +64,7 @@ enum {
        FR_ACT_BLACKHOLE,       /* Drop without notification */
        FR_ACT_UNREACHABLE,     /* Drop with ENETUNREACH */
        FR_ACT_PROHIBIT,        /* Drop with EACCES */
+       FR_ACT_TO_TBL_INHERIT_DEV,
        __FR_ACT_MAX,
 };
 
diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index 4318ab1..af89016 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -32,6 +32,7 @@ enum {
        IFA_CACHEINFO,
        IFA_MULTICAST,
        IFA_FLAGS,
+       IFA_RT_TABLE,
        __IFA_MAX,
 };
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1737b7a..7f4cdb2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -163,6 +163,7 @@ enum {
 enum {
        IFLA_INET_UNSPEC,
        IFLA_INET_CONF,
+       IFLA_INET_RT_TABLE,
        __IFLA_INET_MAX,
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a12668..2728873 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -556,11 +556,17 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 
        frh = nlmsg_data(nlh);
        frh->family = ops->family;
-       frh->table = rule->table;
-       if (nla_put_u32(skb, FRA_TABLE, rule->table))
-               goto nla_put_failure;
+
+       /* table id is not valid if we inherit from interface */
+       if (rule->action != FR_ACT_TO_TBL_INHERIT_DEV) {
+               frh->table = rule->table;
+               if (nla_put_u32(skb, FRA_TABLE, rule->table))
+                       goto nla_put_failure;
+       }
+
        if (nla_put_u32(skb, FRA_SUPPRESS_PREFIXLEN, rule->suppress_prefixlen))
                goto nla_put_failure;
+
        frh->res1 = 0;
        frh->res2 = 0;
        frh->action = rule->action;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 419d23c..91f074d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -100,6 +100,7 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
        [IFA_LABEL]             = { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
        [IFA_CACHEINFO]         = { .len = sizeof(struct ifa_cacheinfo) },
        [IFA_FLAGS]             = { .type = NLA_U32 },
+       [IFA_RT_TABLE]          = { .type = NLA_U32 },
 };
 
 #define IN4_ADDR_HSIZE_SHIFT   8
@@ -244,6 +245,7 @@ static struct in_device *inetdev_init(struct net_device *dev)
                        sizeof(in_dev->cnf));
        in_dev->cnf.sysctl = NULL;
        in_dev->dev = dev;
+       in_dev->rt_table_id = RT_TABLE_UNSPEC;
        in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl);
        if (!in_dev->arp_parms)
                goto out_kfree;
@@ -783,6 +785,11 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
        if (!tb[IFA_ADDRESS])
                tb[IFA_ADDRESS] = tb[IFA_LOCAL];
 
+       if (tb[IFA_RT_TABLE])
+               ifa->ifa_rt_table = nla_get_u32(tb[IFA_RT_TABLE]);
+       else
+               ifa->ifa_rt_table = RT_TABLE_UNSPEC;
+
        INIT_HLIST_NODE(&ifa->hash);
        ifa->ifa_prefixlen = ifm->ifa_prefixlen;
        ifa->ifa_mask = inet_make_mask(ifm->ifa_prefixlen);
@@ -1549,6 +1556,7 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
            (ifa->ifa_label[0] &&
             nla_put_string(skb, IFA_LABEL, ifa->ifa_label)) ||
            nla_put_u32(skb, IFA_FLAGS, ifa->ifa_flags) ||
+           nla_put_u32(skb, IFA_RT_TABLE, ifa->ifa_rt_table) ||
            put_cacheinfo(skb, ifa->ifa_cstamp, ifa->ifa_tstamp,
                          preferred, valid))
                goto nla_put_failure;
@@ -1652,7 +1660,8 @@ static size_t inet_get_link_af_size(const struct net_device *dev)
        if (!in_dev)
                return 0;
 
-       return nla_total_size(IPV4_DEVCONF_MAX * 4); /* IFLA_INET_CONF */
+       return nla_total_size(IPV4_DEVCONF_MAX * 4) +   /* IFLA_INET_CONF */
+              nla_total_size(sizeof(u32));             /* IFLA_INET_RT_TABLE */
 }
 
 static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
@@ -1664,6 +1673,9 @@ static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
        if (!in_dev)
                return -ENODATA;
 
+       if (nla_put_u32(skb, IFLA_INET_RT_TABLE, in_dev->rt_table_id) < 0)
+               return -EMSGSIZE;
+
        nla = nla_reserve(skb, IFLA_INET_CONF, IPV4_DEVCONF_MAX * 4);
        if (!nla)
                return -EMSGSIZE;
@@ -1676,6 +1688,7 @@ static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
 
 static const struct nla_policy inet_af_policy[IFLA_INET_MAX+1] = {
        [IFLA_INET_CONF]        = { .type = NLA_NESTED },
+       [IFLA_INET_RT_TABLE]    = { .type = NLA_U32 },
 };
 
 static int inet_validate_link_af(const struct net_device *dev,
@@ -1723,6 +1736,9 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
                        ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
        }
 
+       if (tb[IFLA_INET_RT_TABLE])
+               in_dev->rt_table_id = nla_get_u32(tb[IFLA_INET_RT_TABLE]);
+
        return 0;
 }
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 872494e..56b2656 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -225,7 +225,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 
        rcu_read_lock();
 
-       local_table = fib_get_table(net, RT_TABLE_LOCAL);
+       local_table = fib_get_table(net, dev ? ipv4_idev_rt_table(dev) : RT_TABLE_LOCAL);
        if (local_table) {
                ret = RTN_UNICAST;
                if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
@@ -277,6 +277,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
                fl4.flowi4_iif = LOOPBACK_IFINDEX;
                fl4.daddr = ip_hdr(skb)->saddr;
                fl4.saddr = 0;
+               fl4.rt_table_id = ipv4_idev_rt_table(dev);
                fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
                fl4.flowi4_scope = scope;
                fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
@@ -311,6 +312,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
        fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
        fl4.daddr = src;
        fl4.saddr = dst;
+       fl4.rt_table_id =  ipv4_idev_rt_table(dev);
        fl4.flowi4_tos = tos;
        fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 
@@ -774,7 +776,12 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
                },
        };
 
-       if (type == RTN_UNICAST)
+       /* if ifa_rt_table is different from default RT_TABLE_LOCAL
+        * use its value for all types of routes
+        */
+       if (ifa->ifa_rt_table != RT_TABLE_UNSPEC)
+               tb = fib_new_table(net, ifa->ifa_rt_table);
+       else if (type == RTN_UNICAST)
                tb = fib_new_table(net, RT_TABLE_MAIN);
        else
                tb = fib_new_table(net, RT_TABLE_LOCAL);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 5615198..acb415c 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -75,9 +75,14 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 {
        int err = -EAGAIN;
        struct fib_table *tbl;
+       u32 table;
 
        switch (rule->action) {
+       case FR_ACT_TO_TBL_INHERIT_DEV:
+               table = flp->u.ip4.rt_table_id;
+               break;
        case FR_ACT_TO_TBL:
+               table = rule->table;
                break;
 
        case FR_ACT_UNREACHABLE:
@@ -93,7 +98,7 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 
        rcu_read_lock();
 
-       tbl = fib_get_table(rule->fr_net, rule->table);
+       tbl = fib_get_table(rule->fr_net, table);
        if (tbl)
                err = fib_table_lookup(tbl, &flp->u.ip4,
                                       (struct fib_result *)arg->result,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 28ec3c1..afb0011 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -587,7 +587,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 {
        int err;
        struct net *net;
-       struct net_device *dev;
+       struct net_device *dev = NULL;
 
        net = cfg->fc_nlinfo.nl_net;
        if (nh->nh_gw) {
@@ -616,6 +616,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
                                .flowi4_scope = cfg->fc_scope + 1,
                                .flowi4_oif = nh->nh_oif,
                                .flowi4_iif = LOOPBACK_IFINDEX,
+                               .rt_table_id = dev ? ipv4_idev_rt_table(dev)
+                                              : RT_TABLE_LOCAL,
                        };
 
                        /* It is not necessary, but requires a bit of thinking */
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f5203fb..36952c8 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -425,6 +425,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
        fl4.flowi4_mark = mark;
        fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
        fl4.flowi4_proto = IPPROTO_ICMP;
+       fl4.rt_table_id = ipv4_idev_rt_table(skb->dev);
        security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
        rt = ip_route_output_key(net, &fl4);
        if (IS_ERR(rt))
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 4bfaedf..c7c1407 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -93,6 +93,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
        flow.flowi4_iif = LOOPBACK_IFINDEX;
        flow.daddr = iph->saddr;
        flow.saddr = rpfilter_get_saddr(iph->daddr);
+       flow.rt_table_id = ipv4_idev_rt_table(skb->dev);
        flow.flowi4_oif = 0;
        flow.flowi4_mark = info->flags & XT_RPFILTER_VALID_MARK ? skb->mark : 0;
        flow.flowi4_tos = RT_TOS(iph->tos);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f605598..eec1908 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1716,6 +1716,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
        fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
        fl4.daddr = daddr;
        fl4.saddr = saddr;
+       fl4.rt_table_id = ipv4_idev_rt_table(dev);
        err = fib_lookup(net, &fl4, &res);
        if (err != 0) {
                if (!IN_DEV_FORWARD(in_dev))
-- 
2.4.2
