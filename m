From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [TCP] Avoid two divides in tcp_output.c
Date: Fri, 21 Dec 2007 06:34:28 +0100
Message-ID: <476B5064.5010302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060104080607000403050800"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54658 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbXLUFep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 00:34:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060104080607000403050800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Because 'free_space' variable in __tcp_select_window() is signed,
expression (free_space / 2) forces compiler to emit an integer divide.

This can be changed to a plain right shift, less expensive.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------060104080607000403050800
Content-Type: text/plain;
 name="tcp_output.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_output.patch"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7c50271..9a9510a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1627,7 +1627,7 @@ u32 __tcp_select_window(struct sock *sk)
 	if (mss > full_space)
 		mss = full_space;
 
-	if (free_space < full_space/2) {
+	if (free_space < (full_space >> 1)) {
 		icsk->icsk_ack.quick = 0;
 
 		if (tcp_memory_pressure)
@@ -1666,7 +1666,7 @@ u32 __tcp_select_window(struct sock *sk)
 		if (window <= free_space - mss || window > free_space)
 			window = (free_space/mss)*mss;
 		else if (mss == full_space &&
-			 free_space > window + full_space/2)
+			 free_space > window + (full_space >> 1))
 			window = free_space;
 	}
 

--------------060104080607000403050800--
