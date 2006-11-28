From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 1/2] [TCP]: Change tcp_header_len member in tcp_sock to u16
Date: Tue, 28 Nov 2006 01:16:23 -0200
Message-ID: <20061128031622.GC4029@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:22982 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S934996AbWK1DQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 22:16:29 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this we eliminate the last hole in struct tcp_sock.

End result:

[acme@newtoy net-2.6.20]$ codiff -sV /tmp/tcp.o.before net/ipv4/tcp.o
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/tcp.c:
  struct tcp_sock |   -4
    tcp_header_len;
     from: int                   /*  1000(0)     4(0) */
     to:   u16                   /*  1000(0)     2(0) */
 1 struct changed
[acme@newtoy net-2.6.20]$

Now sizeof(tcp_sock) is just...

[acme@newtoy net-2.6.20]$ pahole --sizes ../OUTPUT/qemu/net-2.6.20/net/ipv4/tcp.o | grep -w tcp_sock
struct tcp_sock: 1500 0

1500 bytes ;-)

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/tcp.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index dd61b17..b42ff0e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -227,7 +227,8 @@ static inline struct tcp_request_sock *t
 struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
-	int	tcp_header_len;	/* Bytes of tcp header to send		*/
+	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
+	u16	xmit_size_goal;	/* Goal for segmenting output packets	*/
 
 /*
  *	Header prediction flags
@@ -268,8 +269,6 @@ #endif
 	__u32	snd_wnd;	/* The window we expect to receive	*/
 	__u32	max_window;	/* Maximal window ever seen from peer	*/
 	__u32	mss_cache;	/* Cached effective mss, not including SACKS */
-	__u16	xmit_size_goal;	/* Goal for segmenting output packets	*/
-	/* XXX Two bytes hole, try to pack */
 
 	__u32	window_clamp;	/* Maximal window to advertise		*/
 	__u32	rcv_ssthresh;	/* Current window clamp			*/
-- 
1.4.2.1.g3d5c

