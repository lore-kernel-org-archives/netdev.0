From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] Fix kernel panic when calling tcp_v(4/6)_md5_do_lookup
Date: Thu, 07 Aug 2008 13:12:57 +0800
Message-ID: <489A8459.1020909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52923 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752894AbYHGFQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 01:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the following packet flow happen, kernel will panic.
MathineA			MathineB
		SYN
	---------------------->    
        	SYN+ACK
	<----------------------
		ACK(bad seq)
	---------------------->
When a bad seq ACK is received, tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr))
is finally called by tcp_v4_reqsk_send_ack(), but the first parameter(skb->sk) is 
NULL at that moment, so kernel panic happens.
This patch fixes this bug.

Below is the OOPS output:

[  302.812793] IP: [<c05cfaa6>] tcp_v4_md5_do_lookup+0x12/0x42
[  302.817075] Oops: 0000 [#1] SMP 
[  302.819815] Modules linked in: ipv6 loop dm_multipath rtc_cmos rtc_core rtc_lib pcspkr pcnet32 mii i2c_piix4 parport_pc i2c_core parport ac button ata_piix libata dm_mod mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod crc_t10dif ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wait_scan]
[  302.849946] 
[  302.851198] Pid: 0, comm: swapper Not tainted (2.6.27-rc1-guijf #5)
[  302.855184] EIP: 0060:[<c05cfaa6>] EFLAGS: 00010296 CPU: 0
[  302.858296] EIP is at tcp_v4_md5_do_lookup+0x12/0x42
[  302.861027] EAX: 0000001e EBX: 00000000 ECX: 00000046 EDX: 00000046
[  302.864867] ESI: ceb69e00 EDI: 1467a8c0 EBP: cf75f180 ESP: c0792e54
[  302.868333]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  302.871287] Process swapper (pid: 0, ti=c0792000 task=c0712340 task.ti=c0746000)
[  302.875592] Stack: c06f413a 00000000 cf75f180 ceb69e00 00000000 c05d0d86 000016d0 ceac5400 
[  302.883275]        c05d28f8 000016d0 ceb69e00 ceb69e20 681bf6e3 00001000 00000000 0a67a8c0 
[  302.890971]        ceac5400 c04250a3 c06f413a c0792eb0 c0792edc cf59a620 cf59a620 cf59a634 
[  302.900140] Call Trace:
[  302.902392]  [<c05d0d86>] tcp_v4_reqsk_send_ack+0x17/0x35
[  302.907060]  [<c05d28f8>] tcp_check_req+0x156/0x372
[  302.910082]  [<c04250a3>] printk+0x14/0x18
[  302.912868]  [<c05d0aa1>] tcp_v4_do_rcv+0x1d3/0x2bf
[  302.917423]  [<c05d26be>] tcp_v4_rcv+0x563/0x5b9
[  302.920453]  [<c05bb20f>] ip_local_deliver_finish+0xe8/0x183
[  302.923865]  [<c05bb10a>] ip_rcv_finish+0x286/0x2a3
[  302.928569]  [<c059e438>] dev_alloc_skb+0x11/0x25
[  302.931563]  [<c05a211f>] netif_receive_skb+0x2d6/0x33a
[  302.934914]  [<d0917941>] pcnet32_poll+0x333/0x680 [pcnet32]
[  302.938735]  [<c05a3b48>] net_rx_action+0x5c/0xfe
[  302.941792]  [<c042856b>] __do_softirq+0x5d/0xc1
[  302.944788]  [<c042850e>] __do_softirq+0x0/0xc1
[  302.948999]  [<c040564b>] do_softirq+0x55/0x88
[  302.951870]  [<c04501b1>] handle_fasteoi_irq+0x0/0xa4
[  302.954986]  [<c04284da>] irq_exit+0x35/0x69
[  302.959081]  [<c0405717>] do_IRQ+0x99/0xae
[  302.961896]  [<c040422b>] common_interrupt+0x23/0x28
[  302.966279]  [<c040819d>] default_idle+0x2a/0x3d
[  302.969212]  [<c0402552>] cpu_idle+0xb2/0xd2
[  302.972169]  =======================
[  302.974274] Code: fc ff 84 d2 0f 84 df fd ff ff e9 34 fe ff ff 83 c4 0c 5b 5e 5f 5d c3 90 90 57 89 d7 56 53 89 c3 50 68 3a 41 6f c0 e8 e9 55 e5 ff <8b> 93 9c 04 00 00 58 85 d2 59 74 1e 8b 72 10 31 db 31 c9 85 f6 
[  303.011610] EIP: [<c05cfaa6>] tcp_v4_md5_do_lookup+0x12/0x42 SS:ESP 0068:c0792e54
[  303.018360] Kernel panic - not syncing: Fatal exception in interrupt


Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 include/net/request_sock.h |    2 +-
 net/ipv4/tcp_ipv4.c        |    4 ++--
 net/ipv4/tcp_minisocks.c   |    2 +-
 net/ipv6/tcp_ipv6.c        |    8 +++++---
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 8d6e991..cac811e 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -33,7 +33,7 @@ struct request_sock_ops {
 	struct kmem_cache	*slab;
 	int		(*rtx_syn_ack)(struct sock *sk,
 				       struct request_sock *req);
-	void		(*send_ack)(struct sk_buff *skb,
+	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
 	void		(*send_reset)(struct sock *sk,
 				      struct sk_buff *skb);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 91a8cfd..44c1e93 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -687,14 +687,14 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	inet_twsk_put(tw);
 }
 
-static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
+static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	tcp_v4_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr));
+			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr));
 }
 
 /*
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 204c421..6d286f5 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -609,7 +609,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 					  tcp_rsk(req)->rcv_isn + 1, tcp_rsk(req)->rcv_isn + 1 + req->rcv_wnd)) {
 		/* Out of window: send ACK and drop. */
 		if (!(flg & TCP_FLAG_RST))
-			req->rsk_ops->send_ack(skb, req);
+			req->rsk_ops->send_ack(sk, skb, req);
 		if (paws_reject)
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
 		return NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 78185a4..5b90b36 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -69,7 +69,8 @@
 #include <linux/scatterlist.h>
 
 static void	tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb);
-static void	tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req);
+static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+				      struct request_sock *req);
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
 
@@ -1138,10 +1139,11 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	inet_twsk_put(tw);
 }
 
-static void tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
+static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+				  struct request_sock *req)
 {
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
-			tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr));
+			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr));
 }
 
 
-- 
1.5.3


