From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Bugme-new] [Bug 10556] New: IPVS sync_backup oops
Date: Sat, 26 Apr 2008 20:48:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804261834450.4615@u.domain.uli>
References: <bug-10556-10286@http.bugzilla.kernel.org/>
 <20080426040452.4fcbc962.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	bugme-daemon@bugzilla.kernel.org, l0op8ack@hotmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:37840 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751745AbYDZRsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 13:48:12 -0400
In-Reply-To: <20080426040452.4fcbc962.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 26 Apr 2008, Andrew Morton wrote:

> On Fri, 25 Apr 2008 21:27:18 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10556
> > 
> >         ReportedBy: l0op8ack@hotmail.com
> > 
> > Latest working kernel version: 2.6.23.17
> > Earliest failing kernel version: 2.6.24
> 
> Also,
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 00000014
> printing eip: c030659e *pde = 00000000 
> Oops: 0000 [#1] SMP 
> Modules linked in: xt_tcpudp iptable_mangle xt_MARK xt_multiport ip_tables
> x_tables ip_vs_wrr ip_vs_wlc ip_vs_sh ip_vs_sed ip_vs_rr ip_vs_nq ip_vs_lc
> ip_vs_lblcr ip_vs_lblc ip_vs_ftp ip_vs_dh pcnet32 crc32 e1000 e100 mii
> 
> Pid: 3960, comm: ipvs_syncbackup Not tainted (2.6.24.4 #3)
> EIP: 0060:[<c030659e>] EFLAGS: 00010246 CPU: 0
> EIP is at sync_thread+0x919/0xa3c
> EAX: 00000000 EBX: f6fe6800 ECX: e3ba2c00 EDX: 00000000
> ESI: 00000000 EDI: 00000000 EBP: f7310034 ESP: f699bf54
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process ipvs_syncbackup (pid: 3960, ti=f699a000 task=f6995030 task.ti=f699a000)
> Stack: 01000000 00000000 23035e0a 00000000 00001183 00000000 f699bfc0 f6d04860 
>        00000002 00000034 f7310000 f78f1800 00000001 f731001c c0000000 00000000 
>        00000010 f699bfc0 00000001 00000000 00000000 00000000 00000000 f6995030 
> Call Trace:
>  [<c011c53a>] default_wake_function+0x0/0x8
>  [<c0305c85>] sync_thread+0x0/0xa3c
>  [<c0104aa7>] kernel_thread_helper+0x7/0x10
>  =======================
> Code: a1 20 64 3e c0 89 43 54 8b 54 24 34 0f b7 42 16 66 c1 c0 08 0f b7 c0 66
> 89 43 42 0f b6 42 01 e8 90 06 00 00 0f b7 53 42 0f b7 d2 <8b> 40 14 8b 04 90 89
> 43 38 89 d8 e8 8a 8e ff ff 8b 44 24 28 03 
> EIP: [<c030659e>] sync_thread+0x919/0xa3c SS:ESP 0068:f699bf54
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> 
> Which will be a bit hard to track down because it seems that pretty much
> the whole world got inlined into sync_thread().

	I can not fully understand the above oops but hope following
fix can help (not tested). It is for 2.6.25. I can provide patch for
2.6.24 if needed (there are rejects):


	Result from ip_vs_proto_get() should be checked because
protocol value can be invalid or unsupported in backup. Also, add
checks to validate message limits and connection state.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v2.6.25/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- v2.6.25/linux/include/net/ip_vs.h	2008-04-17 09:58:08.000000000 +0300
+++ linux/include/net/ip_vs.h	2008-04-26 20:10:46.000000000 +0300
@@ -405,7 +405,8 @@ struct sk_buff;
 struct ip_vs_protocol {
 	struct ip_vs_protocol	*next;
 	char			*name;
-	__u16			protocol;
+	u16			protocol;
+	u16			num_states;
 	int			dont_defrag;
 	atomic_t		appcnt;		/* counter of proto app incs */
 	int			*timeout_table;	/* protocol timeout table */
diff -urp v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_ah.c linux/net/ipv4/ipvs/ip_vs_proto_ah.c
--- v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_ah.c	2007-07-10 09:18:43.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_proto_ah.c	2008-04-26 20:14:17.000000000 +0300
@@ -160,6 +160,7 @@ static void ah_exit(struct ip_vs_protoco
 struct ip_vs_protocol ip_vs_protocol_ah = {
 	.name =			"AH",
 	.protocol =		IPPROTO_AH,
+	.num_states =		1,
 	.dont_defrag =		1,
 	.init =			ah_init,
 	.exit =			ah_exit,
diff -urp v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_esp.c linux/net/ipv4/ipvs/ip_vs_proto_esp.c
--- v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_esp.c	2008-04-17 09:58:09.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_proto_esp.c	2008-04-26 20:14:39.000000000 +0300
@@ -159,6 +159,7 @@ static void esp_exit(struct ip_vs_protoc
 struct ip_vs_protocol ip_vs_protocol_esp = {
 	.name =			"ESP",
 	.protocol =		IPPROTO_ESP,
+	.num_states =		1,
 	.dont_defrag =		1,
 	.init =			esp_init,
 	.exit =			esp_exit,
diff -urp v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_tcp.c linux/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-01-25 10:45:06.000000000 +0200
+++ linux/net/ipv4/ipvs/ip_vs_proto_tcp.c	2008-04-26 20:15:45.000000000 +0300
@@ -594,6 +594,7 @@ static void ip_vs_tcp_exit(struct ip_vs_
 struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.name =			"TCP",
 	.protocol =		IPPROTO_TCP,
+	.num_states =		IP_VS_TCP_S_LAST,
 	.dont_defrag =		0,
 	.appcnt =		ATOMIC_INIT(0),
 	.init =			ip_vs_tcp_init,
diff -urp v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_udp.c linux/net/ipv4/ipvs/ip_vs_proto_udp.c
--- v2.6.25/linux/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-01-25 10:45:06.000000000 +0200
+++ linux/net/ipv4/ipvs/ip_vs_proto_udp.c	2008-04-26 20:15:07.000000000 +0300
@@ -409,6 +409,7 @@ static void udp_exit(struct ip_vs_protoc
 struct ip_vs_protocol ip_vs_protocol_udp = {
 	.name =			"UDP",
 	.protocol =		IPPROTO_UDP,
+	.num_states =		IP_VS_UDP_S_LAST,
 	.dont_defrag =		0,
 	.init =			udp_init,
 	.exit =			udp_exit,
diff -urp v2.6.25/linux/net/ipv4/ipvs/ip_vs_sync.c linux/net/ipv4/ipvs/ip_vs_sync.c
--- v2.6.25/linux/net/ipv4/ipvs/ip_vs_sync.c	2008-04-17 09:58:09.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_sync.c	2008-04-26 20:25:51.000000000 +0300
@@ -288,11 +288,16 @@ static void ip_vs_process_message(const 
 	char *p;
 	int i;
 
+	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
+		IP_VS_ERR_RL("message header too short\n");
+		return;
+	}
+
 	/* Convert size back to host byte order */
 	m->size = ntohs(m->size);
 
 	if (buflen != m->size) {
-		IP_VS_ERR("bogus message\n");
+		IP_VS_ERR_RL("bogus message size\n");
 		return;
 	}
 
@@ -307,9 +312,37 @@ static void ip_vs_process_message(const 
 	for (i=0; i<m->nr_conns; i++) {
 		unsigned flags, state;
 
-		s = (struct ip_vs_sync_conn *)p;
+		if (p + SIMPLE_CONN_SIZE > buffer+buflen) {
+			IP_VS_ERR_RL("bogus message\n");
+			return;
+		}
+		s = (struct ip_vs_sync_conn *) p;
 		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
+		if (flags & IP_VS_CONN_F_SEQ_MASK) {
+			opt = (struct ip_vs_sync_conn_options *)&s[1];
+			p += FULL_CONN_SIZE;
+			if (p > buffer+buflen) {
+				IP_VS_ERR_RL("bogus message\n");
+				return;
+			}
+		} else {
+			opt = NULL;
+			p += SIMPLE_CONN_SIZE;
+		}
+
+		pp = ip_vs_proto_get(s->protocol);
+		if (!pp) {
+			IP_VS_ERR_RL("Unsupported protocol %u in sync msg\n",
+				s->protocol);
+			continue;
+		}
 		state = ntohs(s->state);
+		if (state >= pp->num_states) {
+			IP_VS_DBG(2, "Invalid %s state %u in sync msg\n",
+				pp->name, state);
+			continue;
+		}
+
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			cp = ip_vs_conn_in_get(s->protocol,
 					       s->caddr, s->cport,
@@ -345,7 +378,6 @@ static void ip_vs_process_message(const 
 				IP_VS_ERR("ip_vs_conn_new failed\n");
 				return;
 			}
-			cp->state = state;
 		} else if (!cp->dest) {
 			dest = ip_vs_try_bind_dest(cp);
 			if (!dest) {
@@ -371,23 +403,13 @@ static void ip_vs_process_message(const 
 			}
 		}
 
-		if (flags & IP_VS_CONN_F_SEQ_MASK) {
-			opt = (struct ip_vs_sync_conn_options *)&s[1];
+		if (opt)
 			memcpy(&cp->in_seq, opt, sizeof(*opt));
-			p += FULL_CONN_SIZE;
-		} else
-			p += SIMPLE_CONN_SIZE;
-
 		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
 		cp->state = state;
-		pp = ip_vs_proto_get(s->protocol);
-		cp->timeout = pp->timeout_table[cp->state];
+		cp->timeout = pp->timeout_table ?
+			pp->timeout_table[state] : (3*60*HZ);
 		ip_vs_conn_put(cp);
-
-		if (p > buffer+buflen) {
-			IP_VS_ERR("bogus message\n");
-			return;
-		}
 	}
 }
 
