From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: correct off-by-one write allocations reports
Date: Wed, 17 Jun 2009 08:41:53 +0200
Message-ID: <4A389031.1060902@gmail.com>
References: <4A37A058.1030701@gmail.com>	<4A37AA0C.40507@gmail.com>	<alpine.LFD.2.01.0906161155400.3282@localhost.localdomain> <20090616.120829.182011393.davem@davemloft.net> <4A37F495.9030101@gmail.com> <4A37FC93.7070403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47633 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764626AbZFQGmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 02:42:44 -0400
In-Reply-To: <4A37FC93.7070403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

Please find the followup patch I promised yesterday.

Some review still needed for net/atm, since this protocol
sets sock_wmem_alloc initial value to 0

Thank you

[PATCH] net: correct off-by-one write allocations reports

commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 
(net: No more expensive sock_hold()/sock_put() on each tx)
changed initial sk_wmem_alloc value.

We need to take into account this offset when reporting
sk_wmem_alloc to user, in PROC_FS files or various
ioctls (SIOCOUTQ/TIOCOUTQ)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/appletalk/atalk_proc.c   |    4 ++--
 net/appletalk/ddp.c          |    3 +--
 net/ax25/af_ax25.c           |   11 ++++++-----
 net/bluetooth/af_bluetooth.c |    2 +-
 net/decnet/af_decnet.c       |    2 +-
 net/ieee802154/dgram.c       |    3 ++-
 net/ipv4/inet_diag.c         |    4 ++--
 net/ipv4/raw.c               |    7 ++++---
 net/ipv4/udp.c               |    7 ++++---
 net/ipv6/raw.c               |    7 ++++---
 net/ipv6/udp.c               |    4 ++--
 net/ipx/af_ipx.c             |    2 +-
 net/ipx/ipx_proc.c           |    4 ++--
 net/irda/af_irda.c           |    3 ++-
 net/key/af_key.c             |    4 ++--
 net/llc/llc_proc.c           |    4 ++--
 net/netlink/af_netlink.c     |    4 ++--
 net/netrom/af_netrom.c       |    6 +++---
 net/packet/af_packet.c       |    3 ++-
 net/rose/af_rose.c           |    7 ++++---
 net/sched/em_meta.c          |    4 ++--
 net/sctp/socket.c            |    4 ++--
 net/unix/af_unix.c           |    2 +-
 net/x25/af_x25.c             |    4 ++--
 net/x25/x25_proc.c           |    4 ++--
 25 files changed, 58 insertions(+), 51 deletions(-)

diff --git a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
index fd8e084..80caad1 100644
--- a/net/appletalk/atalk_proc.c
+++ b/net/appletalk/atalk_proc.c
@@ -204,8 +204,8 @@ static int atalk_seq_socket_show(struct seq_file *seq, void *v)
 			"%02X %d\n",
 		   s->sk_type, ntohs(at->src_net), at->src_node, at->src_port,
 		   ntohs(at->dest_net), at->dest_node, at->dest_port,
-		   atomic_read(&s->sk_wmem_alloc),
-		   atomic_read(&s->sk_rmem_alloc),
+		   sk_wmem_alloc_get(s),
+		   sk_rmem_alloc_get(s),
 		   s->sk_state, SOCK_INODE(s->sk_socket)->i_uid);
 out:
 	return 0;
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index f7a53b2..590b839 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1748,8 +1748,7 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 		/* Protocol layer */
 		case TIOCOUTQ: {
-			long amount = sk->sk_sndbuf -
-				      atomic_read(&sk->sk_wmem_alloc);
+			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 
 			if (amount < 0)
 				amount = 0;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 61b35b9..da0f64f 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1690,7 +1690,8 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 	case TIOCOUTQ: {
 		long amount;
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		res = put_user(amount, (int __user *)argp);
@@ -1780,8 +1781,8 @@ static int ax25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		ax25_info.idletimer = ax25_display_timer(&ax25->idletimer) / (60 * HZ);
 		ax25_info.n2count   = ax25->n2count;
 		ax25_info.state     = ax25->state;
-		ax25_info.rcv_q     = atomic_read(&sk->sk_rmem_alloc);
-		ax25_info.snd_q     = atomic_read(&sk->sk_wmem_alloc);
+		ax25_info.rcv_q     = sk_wmem_alloc_get(sk);
+		ax25_info.snd_q     = sk_rmem_alloc_get(sk);
 		ax25_info.vs        = ax25->vs;
 		ax25_info.vr        = ax25->vr;
 		ax25_info.va        = ax25->va;
@@ -1921,8 +1922,8 @@ static int ax25_info_show(struct seq_file *seq, void *v)
 
 	if (ax25->sk != NULL) {
 		seq_printf(seq, " %d %d %lu\n",
-			   atomic_read(&ax25->sk->sk_wmem_alloc),
-			   atomic_read(&ax25->sk->sk_rmem_alloc),
+			   sk_wmem_alloc_get(ax25->sk),
+			   sk_rmem_alloc_get(ax25->sk),
 			   sock_i_ino(ax25->sk));
 	} else {
 		seq_puts(seq, " * * *\n");
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 02b9baa..0250e06 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -337,7 +337,7 @@ int bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		if (sk->sk_state == BT_LISTEN)
 			return -EINVAL;
 
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		err = put_user(amount, (int __user *) arg);
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index a5e3a59..d351b8d 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1240,7 +1240,7 @@ static int dn_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		return val;
 
 	case TIOCOUTQ:
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		err = put_user(amount, (int __user *)arg);
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 1779677..14d3984 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -126,7 +126,8 @@ static int dgram_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	switch (cmd) {
 	case SIOCOUTQ:
 	{
-		int amount = atomic_read(&sk->sk_wmem_alloc);
+		int amount = sk_wmem_alloc_get(sk);
+
 		return put_user(amount, (int __user *)arg);
 	}
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index b0b2735..a706a47 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -156,10 +156,10 @@ static int inet_csk_diag_fill(struct sock *sk,
 	r->idiag_inode = sock_i_ino(sk);
 
 	if (minfo) {
-		minfo->idiag_rmem = atomic_read(&sk->sk_rmem_alloc);
+		minfo->idiag_rmem = sk_rmem_alloc_get(sk);
 		minfo->idiag_wmem = sk->sk_wmem_queued;
 		minfo->idiag_fmem = sk->sk_forward_alloc;
-		minfo->idiag_tmem = atomic_read(&sk->sk_wmem_alloc);
+		minfo->idiag_tmem = sk_wmem_alloc_get(sk);
 	}
 
 	handler->idiag_get_info(sk, r, info);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3dc9171..2979f14 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -799,7 +799,8 @@ static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	switch (cmd) {
 		case SIOCOUTQ: {
-			int amount = atomic_read(&sk->sk_wmem_alloc);
+			int amount = sk_wmem_alloc_get(sk);
+
 			return put_user(amount, (int __user *)arg);
 		}
 		case SIOCINQ: {
@@ -935,8 +936,8 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
-		atomic_read(&sp->sk_wmem_alloc),
-		atomic_read(&sp->sk_rmem_alloc),
+		sk_wmem_alloc_get(sp),
+		sk_rmem_alloc_get(sp),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8f4158d..80e3812 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -840,7 +840,8 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	switch (cmd) {
 	case SIOCOUTQ:
 	{
-		int amount = atomic_read(&sk->sk_wmem_alloc);
+		int amount = sk_wmem_alloc_get(sk);
+
 		return put_user(amount, (int __user *)arg);
 	}
 
@@ -1721,8 +1722,8 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
-		atomic_read(&sp->sk_wmem_alloc),
-		atomic_read(&sp->sk_rmem_alloc),
+		sk_wmem_alloc_get(sp),
+		sk_rmem_alloc_get(sp),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
 		atomic_read(&sp->sk_drops), len);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 36a090d..8b0b6f9 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1130,7 +1130,8 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	switch(cmd) {
 		case SIOCOUTQ:
 		{
-			int amount = atomic_read(&sk->sk_wmem_alloc);
+			int amount = sk_wmem_alloc_get(sk);
+
 			return put_user(amount, (int __user *)arg);
 		}
 		case SIOCINQ:
@@ -1236,8 +1237,8 @@ static void raw6_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
 		   sp->sk_state,
-		   atomic_read(&sp->sk_wmem_alloc),
-		   atomic_read(&sp->sk_rmem_alloc),
+		   sk_wmem_alloc_get(sp),
+		   sk_rmem_alloc_get(sp),
 		   0, 0L, 0,
 		   sock_i_uid(sp), 0,
 		   sock_i_ino(sp),
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fc333d8..023beda 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1061,8 +1061,8 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
 		   sp->sk_state,
-		   atomic_read(&sp->sk_wmem_alloc),
-		   atomic_read(&sp->sk_rmem_alloc),
+		   sk_wmem_alloc_get(sp),
+		   sk_rmem_alloc_get(sp),
 		   0, 0L, 0,
 		   sock_i_uid(sp), 0,
 		   sock_i_ino(sp),
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 1627050..417b0e3 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1835,7 +1835,7 @@ static int ipx_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	switch (cmd) {
 	case TIOCOUTQ:
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		rc = put_user(amount, (int __user *)argp);
diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index 5ed97ad..5761784 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -280,8 +280,8 @@ static int ipx_seq_socket_show(struct seq_file *seq, void *v)
 	}
 
 	seq_printf(seq, "%08X  %08X  %02X     %03d\n",
-		   atomic_read(&s->sk_wmem_alloc),
-		   atomic_read(&s->sk_rmem_alloc),
+		   sk_wmem_alloc_get(s),
+		   sk_rmem_alloc_get(s),
 		   s->sk_state, SOCK_INODE(s->sk_socket)->i_uid);
 out:
 	return 0;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 3eb5bcc..5922feb 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1762,7 +1762,8 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 	case TIOCOUTQ: {
 		long amount;
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		if (put_user(amount, (unsigned int __user *)arg))
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 643c1be..dba9abd 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3662,8 +3662,8 @@ static int pfkey_seq_show(struct seq_file *f, void *v)
 		seq_printf(f ,"%p %-6d %-6u %-6u %-6u %-6lu\n",
 			       s,
 			       atomic_read(&s->sk_refcnt),
-			       atomic_read(&s->sk_rmem_alloc),
-			       atomic_read(&s->sk_wmem_alloc),
+			       sk_rmem_alloc_get(s),
+			       sk_wmem_alloc_get(s),
 			       sock_i_uid(s),
 			       sock_i_ino(s)
 			       );
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index d208b33..f97be47 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -134,8 +134,8 @@ static int llc_seq_socket_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "@%02X ", llc->sap->laddr.lsap);
 	llc_ui_format_mac(seq, llc->daddr.mac);
 	seq_printf(seq, "@%02X %8d %8d %2d %3d %4d\n", llc->daddr.lsap,
-		   atomic_read(&sk->sk_wmem_alloc),
-		   atomic_read(&sk->sk_rmem_alloc) - llc->copied_seq,
+		   sk_wmem_alloc_get(sk),
+		   sk_rmem_alloc_get(sk) - llc->copied_seq,
 		   sk->sk_state,
 		   sk->sk_socket ? SOCK_INODE(sk->sk_socket)->i_uid : -1,
 		   llc->link);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8b6bbb3..2936fa3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1914,8 +1914,8 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 			   s->sk_protocol,
 			   nlk->pid,
 			   nlk->groups ? (u32)nlk->groups[0] : 0,
-			   atomic_read(&s->sk_rmem_alloc),
-			   atomic_read(&s->sk_wmem_alloc),
+			   sk_rmem_alloc_get(s),
+			   sk_wmem_alloc_get(s),
 			   nlk->cb,
 			   atomic_read(&s->sk_refcnt),
 			   atomic_read(&s->sk_drops)
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index cd91190..ce51ce0 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1205,7 +1205,7 @@ static int nr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		long amount;
 
 		lock_sock(sk);
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		release_sock(sk);
@@ -1341,8 +1341,8 @@ static int nr_info_show(struct seq_file *seq, void *v)
 			nr->n2count,
 			nr->n2,
 			nr->window,
-			atomic_read(&s->sk_wmem_alloc),
-			atomic_read(&s->sk_rmem_alloc),
+			sk_wmem_alloc_get(s),
+			sk_rmem_alloc_get(s),
 			s->sk_socket ? SOCK_INODE(s->sk_socket)->i_ino : 0L);
 
 		bh_unlock_sock(s);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4f76e55..ebe5718 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1987,7 +1987,8 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 	switch (cmd) {
 		case SIOCOUTQ:
 		{
-			int amount = atomic_read(&sk->sk_wmem_alloc);
+			int amount = sk_wmem_alloc_get(sk);
+
 			return put_user(amount, (int __user *)arg);
 		}
 		case SIOCINQ:
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 4dd9a7d..6bd8e93 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1309,7 +1309,8 @@ static int rose_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 	case TIOCOUTQ: {
 		long amount;
-		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+
+		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 		if (amount < 0)
 			amount = 0;
 		return put_user(amount, (unsigned int __user *) argp);
@@ -1480,8 +1481,8 @@ static int rose_info_show(struct seq_file *seq, void *v)
 			rose->hb / HZ,
 			ax25_display_timer(&rose->idletimer) / (60 * HZ),
 			rose->idle / (60 * HZ),
-			atomic_read(&s->sk_wmem_alloc),
-			atomic_read(&s->sk_rmem_alloc),
+			sk_wmem_alloc_get(s),
+			sk_rmem_alloc_get(s),
 			s->sk_socket ? SOCK_INODE(s->sk_socket)->i_ino : 0L);
 	}
 
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 266151a..18d85d2 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -349,13 +349,13 @@ META_COLLECTOR(int_sk_type)
 META_COLLECTOR(int_sk_rmem_alloc)
 {
 	SKIP_NONLOCAL(skb);
-	dst->value = atomic_read(&skb->sk->sk_rmem_alloc);
+	dst->value = sk_rmem_alloc_get(skb->sk);
 }
 
 META_COLLECTOR(int_sk_wmem_alloc)
 {
 	SKIP_NONLOCAL(skb);
-	dst->value = atomic_read(&skb->sk->sk_wmem_alloc);
+	dst->value = sk_wmem_alloc_get(skb->sk);
 }
 
 META_COLLECTOR(int_sk_omem_alloc)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0f01e5d..35ba035 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -130,7 +130,7 @@ static inline int sctp_wspace(struct sctp_association *asoc)
 	if (asoc->ep->sndbuf_policy)
 		amt = asoc->sndbuf_used;
 	else
-		amt = atomic_read(&asoc->base.sk->sk_wmem_alloc);
+		amt = sk_wmem_alloc_get(asoc->base.sk);
 
 	if (amt >= asoc->base.sk->sk_sndbuf) {
 		if (asoc->base.sk->sk_userlocks & SOCK_SNDBUF_LOCK)
@@ -6523,7 +6523,7 @@ static int sctp_writeable(struct sock *sk)
 {
 	int amt = 0;
 
-	amt = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+	amt = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 	if (amt < 0)
 		amt = 0;
 	return amt;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 9dcc6e7..36d4e44 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1946,7 +1946,7 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	switch (cmd) {
 	case SIOCOUTQ:
-		amount = atomic_read(&sk->sk_wmem_alloc);
+		amount = sk_wmem_alloc_get(sk);
 		err = put_user(amount, (int __user *)arg);
 		break;
 	case SIOCINQ:
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 8cd2390..21cdc87 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1271,8 +1271,8 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	switch (cmd) {
 		case TIOCOUTQ: {
-			int amount = sk->sk_sndbuf -
-				     atomic_read(&sk->sk_wmem_alloc);
+			int amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
+
 			if (amount < 0)
 				amount = 0;
 			rc = put_user(amount, (unsigned int __user *)argp);
diff --git a/net/x25/x25_proc.c b/net/x25/x25_proc.c
index 1afa44d..0a04e62 100644
--- a/net/x25/x25_proc.c
+++ b/net/x25/x25_proc.c
@@ -163,8 +163,8 @@ static int x25_seq_socket_show(struct seq_file *seq, void *v)
 		   devname, x25->lci & 0x0FFF, x25->state, x25->vs, x25->vr,
 		   x25->va, x25_display_timer(s) / HZ, x25->t2  / HZ,
 		   x25->t21 / HZ, x25->t22 / HZ, x25->t23 / HZ,
-		   atomic_read(&s->sk_wmem_alloc),
-		   atomic_read(&s->sk_rmem_alloc),
+		   sk_wmem_alloc_get(s),
+		   sk_rmem_alloc_get(s),
 		   s->sk_socket ? SOCK_INODE(s->sk_socket)->i_ino : 0L);
 out:
 	return 0;
