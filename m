From: Bill Nottingham <notting@redhat.com>
Subject: [PATCH] net: fix comparisons of unsigned < 0
Date: Wed, 30 May 2007 03:56:13 -0400
Message-ID: <20070530075613.GA29081@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbXE3H56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 03:57:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent gcc versions emit warnings when unsigned variables are compared < 0 or >= 0.

Signed-off-by: Bill Nottingham <notting@redhat.com>

---

 8021q/vlan.c                               |    3 +--
 dccp/probe.c                               |    2 +-
 ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    3 +--
 ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    3 +--
 sched/act_pedit.c                          |    3 +--
 sctp/debug.c                               |    8 --------
 sctp/sm_statetable.c                       |    2 +-
 wanrouter/wanmain.c                        |    2 +-
 8 files changed, 7 insertions(+), 19 deletions(-)

diff -ru linux-2.6.21-old/net/8021q/vlan.c linux-2.6.21/net/8021q/vlan.c
--- linux-2.6.21-old/net/8021q/vlan.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/8021q/vlan.c	2007-05-30 02:35:47.000000000 -0400
@@ -740,8 +740,7 @@
 	case SET_VLAN_NAME_TYPE_CMD:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if ((args.u.name_type >= 0) &&
-		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
+		if (args.u.name_type < VLAN_NAME_TYPE_HIGHEST) {
 			vlan_name_type = args.u.name_type;
 			err = 0;
 		} else {
diff -ru linux-2.6.21-old/net/dccp/probe.c linux-2.6.21/net/dccp/probe.c
--- linux-2.6.21-old/net/dccp/probe.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/dccp/probe.c	2007-05-30 02:36:09.000000000 -0400
@@ -128,7 +128,7 @@
 	int error = 0, cnt = 0;
 	unsigned char *tbuf;
 
-	if (!buf || len < 0)
+	if (!buf)
 		return -EINVAL;
 
 	if (len == 0)
diff -ru linux-2.6.21-old/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c linux-2.6.21/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
--- linux-2.6.21-old/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c	2007-05-30 02:36:44.000000000 -0400
@@ -177,8 +177,7 @@
 
 	protoff = nf_ct_ipv6_skip_exthdr(*pskb, extoff, &pnum,
 					 (*pskb)->len - extoff);
-	if (protoff < 0 || protoff > (*pskb)->len ||
-	    pnum == NEXTHDR_FRAGMENT) {
+	if (protoff > (*pskb)->len || pnum == NEXTHDR_FRAGMENT) {
 		DEBUGP("proto header not found\n");
 		return NF_ACCEPT;
 	}
diff -ru linux-2.6.21-old/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c linux-2.6.21/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
--- linux-2.6.21-old/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c	2007-05-30 02:37:04.000000000 -0400
@@ -168,8 +168,7 @@
 					   skb->len - inip6off
 						    - sizeof(struct ipv6hdr));
 
-	if ((inprotoff < 0) || (inprotoff > skb->len) ||
-	    (inprotonum == NEXTHDR_FRAGMENT)) {
+	if ((inprotoff > skb->len) || (inprotonum == NEXTHDR_FRAGMENT)) {
 		DEBUGP("icmpv6_error: Can't get protocol header in ICMPv6 payload.\n");
 		return -NF_ACCEPT;
 	}
diff -ru linux-2.6.21-old/net/sched/act_pedit.c linux-2.6.21/net/sched/act_pedit.c
--- linux-2.6.21-old/net/sched/act_pedit.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/sched/act_pedit.c	2007-05-30 02:38:19.000000000 -0400
@@ -164,8 +164,7 @@
 				printk("offset must be on 32 bit boundaries\n");
 				goto bad;
 			}
-			if (skb->len < 0 ||
-			    (offset > 0 && offset > skb->len)) {
+			if (offset > 0 && offset > skb->len) {
 				printk("offset %d cant exceed pkt length %d\n",
 				       offset, skb->len);
 				goto bad;
diff -ru linux-2.6.21-old/net/sctp/debug.c linux-2.6.21/net/sctp/debug.c
--- linux-2.6.21-old/net/sctp/debug.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/sctp/debug.c	2007-05-30 02:39:29.000000000 -0400
@@ -77,8 +77,6 @@
 /* Lookup "chunk type" debug name. */
 const char *sctp_cname(const sctp_subtype_t cid)
 {
-	if (cid.chunk < 0)
-		return "illegal chunk id";
 	if (cid.chunk <= SCTP_CID_BASE_MAX)
 		return sctp_cid_tbl[cid.chunk];
 
@@ -146,8 +144,6 @@
 /* Lookup primitive debug name. */
 const char *sctp_pname(const sctp_subtype_t id)
 {
-	if (id.primitive < 0)
-		return "illegal primitive";
 	if (id.primitive <= SCTP_EVENT_PRIMITIVE_MAX)
 		return sctp_primitive_tbl[id.primitive];
 	return "unknown_primitive";
@@ -161,8 +157,6 @@
 /* Lookup "other" debug name. */
 const char *sctp_oname(const sctp_subtype_t id)
 {
-	if (id.other < 0)
-		return "illegal 'other' event";
 	if (id.other <= SCTP_EVENT_OTHER_MAX)
 		return sctp_other_tbl[id.other];
 	return "unknown 'other' event";
@@ -184,8 +178,6 @@
 /* Lookup timer debug name. */
 const char *sctp_tname(const sctp_subtype_t id)
 {
-	if (id.timeout < 0)
-		return "illegal 'timer' event";
 	if (id.timeout <= SCTP_EVENT_TIMEOUT_MAX)
 		return sctp_timer_tbl[id.timeout];
 	return "unknown_timer";
diff -ru linux-2.6.21-old/net/sctp/sm_statetable.c linux-2.6.21/net/sctp/sm_statetable.c
--- linux-2.6.21-old/net/sctp/sm_statetable.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/sctp/sm_statetable.c	2007-05-30 02:38:51.000000000 -0400
@@ -960,7 +960,7 @@
 	if (state > SCTP_STATE_MAX)
 		return &bug;
 
-	if (cid >= 0 && cid <= SCTP_CID_BASE_MAX)
+	if (cid <= SCTP_CID_BASE_MAX)
 		return &chunk_event_table[cid][state];
 
 	if (sctp_prsctp_enable) {
diff -ru linux-2.6.21-old/net/wanrouter/wanmain.c linux-2.6.21/net/wanrouter/wanmain.c
--- linux-2.6.21-old/net/wanrouter/wanmain.c	2007-05-30 02:53:04.000000000 -0400
+++ linux-2.6.21/net/wanrouter/wanmain.c	2007-05-30 02:40:23.000000000 -0400
@@ -454,7 +454,7 @@
 	}
 
 	if (conf->data_size && conf->data) {
-		if (conf->data_size > 128000 || conf->data_size < 0) {
+		if (conf->data_size > 128000) {
 			printk(KERN_INFO
 			    "%s: ERROR, Invalid firmware data size %i !\n",
 					wandev->name, conf->data_size);
