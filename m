From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Sun, 27 Apr 2008 18:33:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804271810110.10126@u.domain.uli>
References: <bug-10556-10286@http.bugzilla.kernel.org/>
 <20080426040452.4fcbc962.akpm@linux-foundation.org>
 <Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	bugme-daemon@bugzilla.kernel.org
To: l0op8ack@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:48225 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754774AbYD0PdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 11:33:08 -0400
In-Reply-To: <Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

> > On Fri, 25 Apr 2008 21:27:18 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=10556
> > > 
> > >         ReportedBy: l0op8ack@hotmail.com

> 	I can not fully understand the above oops but hope following
> fix can help (not tested). It is for 2.6.25. I can provide patch for
> 2.6.24 if needed (there are rejects):

	As I said, there should be rejects if you apply patch against
2.6.24.4. I recommend to use patch against 2.6.25 because 2.6.25
has some fixes in ip_vs_sync. I suspect some hunks were not applied
correctly, can you clarify what is the kernel version used now?

	In case you are still using 2.6.24.4 I'm appending new
patch, this time against 2.6.24. Let me know if you see some rejects
when applying patch (Hunk FAILED). Also, if TCP conns in backup
are again NONE and conns are not removed I don't have any explanation,
may be you can enable IPVS debugging? As for timeout, I have never
used IPVS sync, it does not send timeout, I suspect it would be
compatibility issue if timeout and nfmark are added to sync structure.
715827:52 should be jiffies 0xFFFFFFFF (time to expire), may be
you can see them with cat /proc/net/ip_vs_conn


        Result from ip_vs_proto_get() should be checked because
protocol value can be invalid or unsupported in backup. But
for valid message we should not fail for templates which use
IPPROTO_IP. Also, add checks to validate message limits and
connection state. Show NONE for templates.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v2.6.24/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- v2.6.24/linux/include/net/ip_vs.h	2008-04-27 17:49:40.000000000 +0300
+++ linux/include/net/ip_vs.h	2008-04-27 17:50:45.000000000 +0300
@@ -403,7 +403,8 @@ struct sk_buff;
 struct ip_vs_protocol {
 	struct ip_vs_protocol	*next;
 	char			*name;
-	__u16			protocol;
+	u16			protocol;
+	u16			num_states;
 	int			dont_defrag;
 	atomic_t		appcnt;		/* counter of proto app incs */
 	int			*timeout_table;	/* protocol timeout table */
diff -urp v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto.c linux/net/ipv4/ipvs/ip_vs_proto.c
--- v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto.c	2008-04-27 17:49:41.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_proto.c	2008-04-27 17:50:45.000000000 +0300
@@ -148,7 +148,7 @@ const char * ip_vs_state_name(__u16 prot
 	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
 
 	if (pp == NULL || pp->state_name == NULL)
-		return "ERR!";
+		return (IPPROTO_IP == proto) ? "NONE" : "ERR!";
 	return pp->state_name(state);
 }
 
diff -urp v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_ah.c linux/net/ipv4/ipvs/ip_vs_proto_ah.c
--- v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_ah.c	2007-07-10 09:18:43.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_proto_ah.c	2008-04-27 17:50:45.000000000 +0300
@@ -160,6 +160,7 @@ static void ah_exit(struct ip_vs_protoco
 struct ip_vs_protocol ip_vs_protocol_ah = {
 	.name =			"AH",
 	.protocol =		IPPROTO_AH,
+	.num_states =		1,
 	.dont_defrag =		1,
 	.init =			ah_init,
 	.exit =			ah_exit,
diff -urp v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_esp.c linux/net/ipv4/ipvs/ip_vs_proto_esp.c
--- v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_esp.c	2008-04-27 17:49:41.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_proto_esp.c	2008-04-27 17:50:45.000000000 +0300
@@ -159,6 +159,7 @@ static void esp_exit(struct ip_vs_protoc
 struct ip_vs_protocol ip_vs_protocol_esp = {
 	.name =			"ESP",
 	.protocol =		IPPROTO_ESP,
+	.num_states =		1,
 	.dont_defrag =		1,
 	.init =			esp_init,
 	.exit =			esp_exit,
diff -urp v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_tcp.c linux/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-01-25 10:45:06.000000000 +0200
+++ linux/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-04-27 17:50:45.000000000 +0300
@@ -594,6 +594,7 @@ static void ip_vs_tcp_exit(struct ip_vs_
 struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.name =			"TCP",
 	.protocol =		IPPROTO_TCP,
+	.num_states =		IP_VS_TCP_S_LAST,
 	.dont_defrag =		0,
 	.appcnt =		ATOMIC_INIT(0),
 	.init =			ip_vs_tcp_init,
diff -urp v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_udp.c linux/net/ipv4/ipvs/ip_vs_proto_udp.c
--- v2.6.24/linux/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-01-25 10:45:06.000000000 +0200
+++ linux/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-04-27 17:50:45.000000000 +0300
@@ -409,6 +409,7 @@ static void udp_exit(struct ip_vs_protoc
 struct ip_vs_protocol ip_vs_protocol_udp = {
 	.name =			"UDP",
 	.protocol =		IPPROTO_UDP,
+	.num_states =		IP_VS_UDP_S_LAST,
 	.dont_defrag =		0,
 	.init =			udp_init,
 	.exit =			udp_exit,
diff -urp v2.6.24/linux/net/ipv4/ipvs/ip_vs_sync.c linux/net/ipv4/ipvs/ip_vs_sync.c
--- v2.6.24/linux/net/ipv4/ipvs/ip_vs_sync.c	2008-04-27 17:49:41.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_sync.c	2008-04-27 18:01:45.000000000 +0300
@@ -288,11 +288,16 @@ static void ip_vs_process_message(const 
 	char *p;
 	int i;
 
+	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
+		IP_VS_ERR_RL("sync message header too short\n");
+		return;
+	}
+
 	/* Convert size back to host byte order */
 	m->size = ntohs(m->size);
 
 	if (buflen != m->size) {
-		IP_VS_ERR("bogus message\n");
+		IP_VS_ERR_RL("bogus sync message size\n");
 		return;
 	}
 
@@ -305,10 +310,50 @@ static void ip_vs_process_message(const 
 
 	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
 	for (i=0; i<m->nr_conns; i++) {
-		unsigned flags;
+		unsigned flags, state;
 
-		s = (struct ip_vs_sync_conn *)p;
+		if (p + SIMPLE_CONN_SIZE > buffer+buflen) {
+			IP_VS_ERR_RL("bogus conn in sync message\n");
+			return;
+		}
+		s = (struct ip_vs_sync_conn *) p;
 		flags = ntohs(s->flags);
+		flags &= ~IP_VS_CONN_F_HASHED;
+		if (flags & IP_VS_CONN_F_SEQ_MASK) {
+			opt = (struct ip_vs_sync_conn_options *)&s[1];
+			p += FULL_CONN_SIZE;
+			if (p > buffer+buflen) {
+				IP_VS_ERR_RL("bogus conn options in sync message\n");
+				return;
+			}
+		} else {
+			opt = NULL;
+			p += SIMPLE_CONN_SIZE;
+		}
+
+		state = ntohs(s->state);
+		if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
+			pp = ip_vs_proto_get(s->protocol);
+			if (!pp) {
+				IP_VS_ERR_RL("Unsupported protocol %u in sync msg\n",
+					s->protocol);
+				continue;
+			}
+			if (state >= pp->num_states) {
+				IP_VS_DBG(2, "Invalid %s state %u in sync msg\n",
+					pp->name, state);
+				continue;
+			}
+		} else {
+			/* protocol in templates is not used for state/timeout */
+			pp = NULL;
+			if (state > 0) {
+				IP_VS_DBG(2, "Invalid template state %u in sync msg\n",
+					state);
+				state = 0;
+			}
+		}
+
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			cp = ip_vs_conn_in_get(s->protocol,
 					       s->caddr, s->cport,
@@ -337,35 +382,31 @@ static void ip_vs_process_message(const 
 				IP_VS_ERR("ip_vs_conn_new failed\n");
 				return;
 			}
-			cp->state = ntohs(s->state);
 		} else if (!cp->dest) {
 			dest = ip_vs_try_bind_dest(cp);
-			if (!dest) {
-				/* it is an unbound entry created by
-				 * synchronization */
-				cp->flags = flags | IP_VS_CONN_F_HASHED;
-			} else
+			if (dest)
 				atomic_dec(&dest->refcnt);
 		}	/* Note that we don't touch its state and flags
 			   if it is a normal entry. */
 
-		if (flags & IP_VS_CONN_F_SEQ_MASK) {
-			opt = (struct ip_vs_sync_conn_options *)&s[1];
+		if (opt)
 			memcpy(&cp->in_seq, opt, sizeof(*opt));
-			p += FULL_CONN_SIZE;
-		} else
-			p += SIMPLE_CONN_SIZE;
 
 		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
-		cp->state = ntohs(s->state);
-		pp = ip_vs_proto_get(s->protocol);
-		cp->timeout = pp->timeout_table[cp->state];
+		cp->state = state;
+		cp->old_state = cp->state;
+		/*
+		 * We can not recover the right timeout for templates
+		 * in all cases, we can not find the right fwmark
+		 * virtual service. If needed, we can do it for
+		 * non-fwmark persistent services.
+		 */
+		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
+			cp->timeout = pp->timeout_table[state];
+		else
+			cp->timeout = (3*60*HZ);
 		ip_vs_conn_put(cp);
 
-		if (p > buffer+buflen) {
-			IP_VS_ERR("bogus message\n");
-			return;
-		}
 	}
 }
 
