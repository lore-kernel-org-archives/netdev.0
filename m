From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: drop fragmented ndisc packets by default (RFC 6980)
Date: Tue, 27 Aug 2013 01:36:51 +0200
Message-ID: <20130826233651.GA9183@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fernando@gont.com.ar, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47899 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab3HZXgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 19:36:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements RFC6980: Drop fragmented ndisc packets by
default. If a fragmented ndisc packet is received the user is informed
that it is possible to disable the check.

Cc: Fernando Gont <fernando@gont.com.ar>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt |  6 ++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 10 ++++++++++
 net/ipv6/ndisc.c                       | 17 +++++++++++++++++
 5 files changed, 35 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index debfe85..a2be556 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1349,6 +1349,12 @@ mldv2_unsolicited_report_interval - INTEGER
 	MLDv2 report retransmit will take place.
 	Default: 1000 (1 second)
 
+suppress_frag_ndisc - INTEGER
+	Control RFC 6980 (Security Implications of IPv6 Fragmentation
+	with IPv6 Neighbor Discovery) behavior:
+	1 - (default) discard fragmented neighbor discovery packets
+	0 - allow fragmented neighbor discovery packets
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 9ac5047..28ea384 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -50,6 +50,7 @@ struct ipv6_devconf {
 	__s32		accept_dad;
 	__s32		force_tllao;
 	__s32           ndisc_notify;
+	__s32		suppress_frag_ndisc;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index d07ac69..593b0e3 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -162,6 +162,7 @@ enum {
 	DEVCONF_NDISC_NOTIFY,
 	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
+	DEVCONF_SUPPRESS_FRAG_NDISC,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2d6d179..a7183fc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -204,6 +204,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.suppress_frag_ndisc	= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -241,6 +242,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.suppress_frag_ndisc	= 1,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -4188,6 +4190,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
 	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
+	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5002,6 +5005,13 @@ static struct addrconf_sysctl_table
 			.proc_handler   = proc_dointvec
 		},
 		{
+			.procname	= "suppress_frag_ndisc",
+			.data		= &ipv6_devconf.suppress_frag_ndisc,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..41720fe 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1519,10 +1519,27 @@ static void pndisc_redo(struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
+static bool ndisc_suppress_frag_ndisc(struct sk_buff *skb)
+{
+	struct inet6_dev *idev = __in6_dev_get(skb->dev);
+
+	if (!idev)
+		return true;
+	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED &&
+	    idev->cnf.suppress_frag_ndisc) {
+		net_warn_ratelimited("Received fragmented ndisc packet. Carefully consider disabling suppress_frag_ndisc.\n");
+		return true;
+	}
+	return false;
+}
+
 int ndisc_rcv(struct sk_buff *skb)
 {
 	struct nd_msg *msg;
 
+	if (ndisc_suppress_frag_ndisc(skb))
+		return 0;
+
 	if (skb_linearize(skb))
 		return 0;
 
-- 
1.8.3.1
