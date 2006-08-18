From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: limit window scaling if window is clamped
Date: Fri, 18 Aug 2006 10:29:38 -0700
Message-ID: <20060818102938.5abc1bcf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29671 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751426AbWHRR3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 13:29:36 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This small change allows for easy per-route workarounds for broken hosts or
middleboxes that are not compliant with TCP standards for window scaling.
Rather than having to turn off window scaling globally. This patch allows
reducing or disabling window scaling if window clamp is present.

Example: Mark Lord reported a problem with 2.6.17 kernel being unable to
access http://www.everymac.com

# ip route add 216.145.246.23/32 via 10.8.0.1 window 65535

I would argue this ought to go in stable kernel as well.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- net-2.6.19.orig/net/ipv4/tcp_output.c
+++ net-2.6.19/net/ipv4/tcp_output.c
@@ -201,6 +201,7 @@ void tcp_select_initial_window(int __spa
 		 * See RFC1323 for an explanation of the limit to 14 
 		 */
 		space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
+		space = min_t(u32, space, *window_clamp);
 		while (space > 65535 && (*rcv_wscale) < 14) {
 			space >>= 1;
 			(*rcv_wscale)++;
