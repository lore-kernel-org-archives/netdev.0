From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 16/31] [CCID3]: Re-order CCID 3 source file
Date: Tue, 20 Mar 2007 20:14:14 -0300
Message-ID: <20070320231414.GE17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:38396 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbXCTXOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:14:18 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66486wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:14:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No code change at all.
This splits ccid3.c into a RX and a TX section, so that the file has an
organisation similar to the other ones (e.g. packet_history.{h,c}).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   89 ++++++++++++++++++++++++-----------------------
 1 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 4be62a9..0009b39 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -33,7 +33,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
 #include "../ccid.h"
 #include "../dccp.h"
 #include "lib/packet_history.h"
@@ -52,6 +51,9 @@ static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
+/*
+ *	Transmitter Half-Connection Routines
+ */
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
@@ -641,10 +643,50 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
 }
 
+static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
+{
+	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+
+	/* Listen socks doesn't have a private CCID block */
+	if (sk->sk_state == DCCP_LISTEN)
+		return;
+
+	BUG_ON(hctx == NULL);
+
+	info->tcpi_rto = hctx->ccid3hctx_t_rto;
+	info->tcpi_rtt = hctx->ccid3hctx_rtt;
+}
+
+static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
+				  u32 __user *optval, int __user *optlen)
+{
+	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	const void *val;
+
+	/* Listen socks doesn't have a private CCID block */
+	if (sk->sk_state == DCCP_LISTEN)
+		return -EINVAL;
+
+	switch (optname) {
+	case DCCP_SOCKOPT_CCID_TX_INFO:
+		if (len < sizeof(hctx->ccid3hctx_tfrc))
+			return -EINVAL;
+		len = sizeof(hctx->ccid3hctx_tfrc);
+		val = &hctx->ccid3hctx_tfrc;
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	if (put_user(len, optlen) || copy_to_user(optval, val, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 /*
- * RX Half Connection methods
+ *	Receiver Half-Connection Routines
  */
-
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
@@ -1129,20 +1171,6 @@ static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
 }
 
-static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state == DCCP_LISTEN)
-		return;
-
-	BUG_ON(hctx == NULL);
-
-	info->tcpi_rto = hctx->ccid3hctx_t_rto;
-	info->tcpi_rtt = hctx->ccid3hctx_rtt;
-}
-
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
@@ -1170,33 +1198,6 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	return 0;
 }
 
-static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
-				  u32 __user *optval, int __user *optlen)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const void *val;
-
-	/* Listen socks doesn't have a private CCID block */
-	if (sk->sk_state == DCCP_LISTEN)
-		return -EINVAL;
-
-	switch (optname) {
-	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->ccid3hctx_tfrc))
-			return -EINVAL;
-		len = sizeof(hctx->ccid3hctx_tfrc);
-		val = &hctx->ccid3hctx_tfrc;
-		break;
-	default:
-		return -ENOPROTOOPT;
-	}
-
-	if (put_user(len, optlen) || copy_to_user(optval, val, len))
-		return -EFAULT;
-
-	return 0;
-}
-
 static struct ccid_operations ccid3 = {
 	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "ccid3",
-- 
1.5.0.3

