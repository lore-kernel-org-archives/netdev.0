From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH] Exporting IPv6 statistics via netlink.
Date: Thu, 19 Apr 2007 15:42:09 +0900 (JST)
Message-ID: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43650 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993118AbXDSGlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 02:41:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

(Sorry for resending..., I failed to put an appropriate subject line...)

Please consider pulling following changesets for supporting exporting
stats information via netlink, on top of net-2.6.22.

Statistics values are exported as u64.  Correspoinding draft patch
for iproute2 can be found at
    <http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/yoshfuji/iproute2-dev.git;a=shortlog;h=v2_6_19-061214-20070404-protinfo-20070404>

3rd patch is preparation for preparation for future support for
IPv4 per-interface statistics and netlink interface, so we may want
to drop it for now.

All changeset are available on branch
    net-2.6.22-20070417-stats-20070417
at
    <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

Regards,

---

HEADLINES
---------

    [IPV6] SNMP: Netlink interface.
    [IPV6] SNMP: Move some statistic bits to net/ipv6/proc.c.
    [IPV4] SNMP: Move some statistic bits to net/ipv4/proc.c.

DIFFSTAT
--------

 include/linux/if_link.h |    1 +
 include/net/ip.h        |    3 ++
 include/net/ipv6.h      |    1 +
 net/ipv4/af_inet.c      |   59 ++++++++++++++++++++++++++++++---------------
 net/ipv4/proc.c         |   25 +++++++++++++++++++
 net/ipv6/addrconf.c     |   22 +++++++++++++----
 net/ipv6/af_inet6.c     |   33 -------------------------
 net/ipv6/proc.c         |   62 +++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 148 insertions(+), 58 deletions(-)

CHANGESETS
----------

commit 4fa0b46927813ad4d70c82e0049d419345ddb7de
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 3 18:21:31 2007 +0900

    [IPV6] SNMP: Netlink interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 35ed3b5..604c243 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -126,6 +126,7 @@ enum
 	IFLA_INET6_STATS,	/* statistics			*/
 	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
 	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
+	IFLA_INET6_ICMP6STATS,	/* statistics (icmpv6)		*/
 	__IFLA_INET6_MAX
 };
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 00328b7..4408def 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -172,6 +172,7 @@ int snmp6_alloc_dev(struct inet6_dev *idev);
 int snmp6_free_dev(struct inet6_dev *idev);
 int snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
 void snmp6_mib_free(void *ptr[2]);
+void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes);
 
 struct ip6_ra_chain
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47d3adf..d80ca98 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3429,6 +3429,8 @@ static inline size_t inet6_if_nlmsg_size(void)
 			nla_total_size(4) /* IFLA_INET6_FLAGS */
 			+ nla_total_size(sizeof(struct ifla_cacheinfo))
 			+ nla_total_size(DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
+			+ nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
+			+ nla_total_size(ICMP6_MIB_MAX * 8) /* IFLA_INET6_ICMP6STATS */
 		 );
 }
 
@@ -3436,7 +3438,7 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct net_device *dev = idev->dev;
-	struct nlattr *conf;
+	struct nlattr *nla;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
 	void *protoinfo;
@@ -3476,12 +3478,22 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	ci.retrans_time = idev->nd_parms->retrans_time;
 	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
 
-	conf = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
-	if (conf == NULL)
+	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
+	if (nla == NULL)
 		goto nla_put_failure;
-	ipv6_store_devconf(&idev->cnf, nla_data(conf), nla_len(conf));
+	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
 
-	/* XXX - Statistics/MC not implemented */
+	/* XXX - MC not implemented */
+
+	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
+	if (nla == NULL)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
+
+	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
+	if (nla == NULL)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
 
 	nla_nest_end(skb, protoinfo);
 	return nlmsg_end(skb, nlh);
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index fa3fb50..0dc5515 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -207,6 +207,31 @@ static const struct file_operations snmp6_seq_fops = {
 	.release = single_release,
 };
 
+static inline void
+__snmp6_fill_stats(u64 *stats, void **mib, int items, int bytes)
+{
+	int i;
+	int pad = bytes - sizeof(u64) * items;
+	BUG_ON(pad < 0);
+	stats[0] = items;
+	for (i = 1; i < items; i++)
+		stats[i] = (u64)fold_field(mib, i);
+	memset(&stats[items], 0, pad);
+}
+
+void
+snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes)
+{
+	switch(attrtype) {
+	case IFLA_INET6_STATS:
+		__snmp6_fill_stats(stats, (void **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
+		break;
+	case IFLA_INET6_ICMP6STATS:
+		__snmp6_fill_stats(stats, (void **)idev->stats.icmpv6, ICMP6_MIB_MAX, bytes);
+		break;
+	}
+}
+
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	struct proc_dir_entry *p;
@@ -283,6 +308,13 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
 {
 	return 0;
 }
+
+void
+snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes)
+{
+	memset(stats, 0, sizeof(bytes));
+}
+
 #endif	/* CONFIG_PROC_FS */
 
 int snmp6_alloc_dev(struct inet6_dev *idev)

---
commit c471a8be12a140dd2f4ca9ad30d572d36fc9dc83
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 5 22:30:19 2007 +0900

    [IPV6] SNMP: Move some statistic bits to net/ipv6/proc.c.
    
    Siged-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index df31cdd..825d03e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -712,39 +712,6 @@ int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
 
 EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
-int
-snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
-{
-	if (ptr == NULL)
-		return -EINVAL;
-
-	ptr[0] = __alloc_percpu(mibsize);
-	if (!ptr[0])
-		goto err0;
-
-	ptr[1] = __alloc_percpu(mibsize);
-	if (!ptr[1])
-		goto err1;
-
-	return 0;
-
-err1:
-	free_percpu(ptr[0]);
-	ptr[0] = NULL;
-err0:
-	return -ENOMEM;
-}
-
-void
-snmp6_mib_free(void *ptr[2])
-{
-	if (ptr == NULL)
-		return;
-	free_percpu(ptr[0]);
-	free_percpu(ptr[1]);
-	ptr[0] = ptr[1] = NULL;
-}
-
 static int __init init_ipv6_mibs(void)
 {
 	if (snmp6_mib_init((void **)ipv6_statistics, sizeof (struct ipstats_mib),
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 0dc5515..5c3ce1c 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -346,4 +346,34 @@ int snmp6_free_dev(struct inet6_dev *idev)
 	return 0;
 }
 
+int snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
+{
+	if (ptr == NULL)
+		return -EINVAL;
+
+	ptr[0] = __alloc_percpu(mibsize);
+	if (!ptr[0])
+		goto err0;
+
+	ptr[1] = __alloc_percpu(mibsize);
+	if (!ptr[1])
+		goto err1;
+
+	return 0;
+
+err1:
+	free_percpu(ptr[0]);
+	ptr[0] = NULL;
+err0:
+	return -ENOMEM;
+}
+
+void snmp6_mib_free(void *ptr[2])
+{
+	if (ptr == NULL)
+		return;
+	free_percpu(ptr[0]);
+	free_percpu(ptr[1]);
+	ptr[0] = ptr[1] = NULL;
+}
 

---
commit 5f6de81e10d5d9bef8019689183f513ce6fed05f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 5 22:52:09 2007 +0900

    [IPV4] SNMP: Move some statistic bits to net/ipv4/proc.c.
    
    This also fixes memory leak in error path.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ip.h b/include/net/ip.h
index 6a08b65..083458a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -166,6 +166,9 @@ DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
 
+extern int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
+extern void snmp_mib_free(void *ptr[2]);
+
 extern int sysctl_local_port_range[2];
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 45ced52..a33ca7e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1245,28 +1245,47 @@ static struct net_protocol icmp_protocol = {
 
 static int __init init_ipv4_mibs(void)
 {
-	net_statistics[0] = alloc_percpu(struct linux_mib);
-	net_statistics[1] = alloc_percpu(struct linux_mib);
-	ip_statistics[0] = alloc_percpu(struct ipstats_mib);
-	ip_statistics[1] = alloc_percpu(struct ipstats_mib);
-	icmp_statistics[0] = alloc_percpu(struct icmp_mib);
-	icmp_statistics[1] = alloc_percpu(struct icmp_mib);
-	tcp_statistics[0] = alloc_percpu(struct tcp_mib);
-	tcp_statistics[1] = alloc_percpu(struct tcp_mib);
-	udp_statistics[0] = alloc_percpu(struct udp_mib);
-	udp_statistics[1] = alloc_percpu(struct udp_mib);
-	udplite_statistics[0] = alloc_percpu(struct udp_mib);
-	udplite_statistics[1] = alloc_percpu(struct udp_mib);
-	if (!
-	    (net_statistics[0] && net_statistics[1] && ip_statistics[0]
-	     && ip_statistics[1] && tcp_statistics[0] && tcp_statistics[1]
-	     && udp_statistics[0] && udp_statistics[1]
-	     && udplite_statistics[0] && udplite_statistics[1]             ) )
-		return -ENOMEM;
-
-	(void) tcp_mib_init();
+	if (snmp_mib_init((void **)net_statistics,
+			  sizeof(struct linux_mib),
+			  __alignof__(struct linux_mib)) < 0)
+		goto err_net_mib;
+	if (snmp_mib_init((void **)ip_statistics,
+			  sizeof(struct ipstats_mib),
+			  __alignof__(struct ipstats_mib)) < 0)
+		goto err_ip_mib;
+	if (snmp_mib_init((void **)icmp_statistics,
+			  sizeof(struct icmp_mib),
+			  __alignof__(struct icmp_mib)) < 0)
+		goto err_icmp_mib;
+	if (snmp_mib_init((void **)tcp_statistics,
+			  sizeof(struct tcp_mib),
+			  __alignof__(struct tcp_mib)) < 0)
+		goto err_tcp_mib;
+	if (snmp_mib_init((void **)udp_statistics,
+			  sizeof(struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
+		goto err_udp_mib;
+	if (snmp_mib_init((void **)udplite_statistics,
+			  sizeof(struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
+		goto err_udplite_mib;
+
+	tcp_mib_init();
 
 	return 0;
+
+err_udplite_mib:
+	snmp_mib_free((void **)udp_statistics);
+err_udp_mib:
+	snmp_mib_free((void **)tcp_statistics);
+err_tcp_mib:
+	snmp_mib_free((void **)icmp_statistics);
+err_icmp_mib:
+	snmp_mib_free((void **)ip_statistics);
+err_ip_mib:
+	snmp_mib_free((void **)net_statistics);
+err_net_mib:
+	return -ENOMEM;
 }
 
 static int ipv4_proc_init(void);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ae68a69..97952d5 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -391,3 +391,28 @@ out_netstat:
 	goto out;
 }
 
+int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
+{
+	BUG_ON(ptr == NULL);
+	ptr[0] = __alloc_percpu(mibsize);
+	if (!ptr[0])
+		goto err0;
+	ptr[1] = __alloc_percpu(mibsize);
+	if (!ptr[1])
+		goto err1;
+	return 0;
+err1:
+	free_percpu(ptr[0]);
+	ptr[0] = NULL;
+err0:
+	return -ENOMEM;
+}
+
+void snmp_mib_free(void *ptr[2])
+{
+	BUG_ON(ptr == NULL);
+	free_percpu(ptr[0]);
+	free_percpu(ptr[1]);
+	ptr[0] = ptr[1] = NULL;
+}
+

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
