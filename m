From: gfree.wind@foxmail.com
Subject: [PATCH nf-next 1/1] net: tcp: Refine the __tcp_select_window
Date: Thu, 30 Mar 2017 06:49:19 +0800
Message-ID: <1490827759-12142-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org, gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:36122 "EHLO
        smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932644AbdC2Wtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 18:49:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

1. Move the "window = tp->rcv_wnd;" into the condition block without
tp->rx_opt.rcv_wscale.
Because it is unnecessary when enable wscale;

2. Use the macro ALIGN instead of two statements.
The two statements are used to make window align to 1<<wscale.
Use the ALIGN is more clearer.

3. Use the rounddown to make codes clearer.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/tcp_output.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 22548b5..1397194 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2561,7 +2561,6 @@ u32 __tcp_select_window(struct sock *sk)
 	/* Don't do rounding if we are using window scaling, since the
 	 * scaled window will not line up with the MSS boundary anyway.
 	 */
-	window = tp->rcv_wnd;
 	if (tp->rx_opt.rcv_wscale) {
 		window = free_space;
 
@@ -2569,10 +2568,9 @@ u32 __tcp_select_window(struct sock *sk)
 		 * Import case: prevent zero window announcement if
 		 * 1<<rcv_wscale > mss.
 		 */
-		if (((window >> tp->rx_opt.rcv_wscale) << tp->rx_opt.rcv_wscale) != window)
-			window = (((window >> tp->rx_opt.rcv_wscale) + 1)
-				  << tp->rx_opt.rcv_wscale);
+		window = ALIGN(window, (1 << tp->rx_opt.rcv_wscale));
 	} else {
+		window = tp->rcv_wnd;
 		/* Get the largest window that is a nice multiple of mss.
 		 * Window clamp already applied above.
 		 * If our current window offering is within 1 mss of the
@@ -2582,7 +2580,7 @@ u32 __tcp_select_window(struct sock *sk)
 		 * is too small.
 		 */
 		if (window <= free_space - mss || window > free_space)
-			window = (free_space / mss) * mss;
+			window = rounddown(free_space, mss);
 		else if (mss == full_space &&
 			 free_space > window + (full_space >> 1))
 			window = free_space;
-- 
1.9.1
