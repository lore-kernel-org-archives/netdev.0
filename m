From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2] tcp: Fix MD5 signature checking on IPv4 mapped
 sockets
Date: Thu, 16 Jul 2009 11:36:52 -0700
Message-ID: <20090716113652.65dd1c8d@nehalam>
References: <1247756691.7627.5.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52628 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932801AbZGPSg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 14:36:58 -0400
In-Reply-To: <1247756691.7627.5.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jul 2009 10:04:51 -0500
John Dykstra <john.dykstra1@gmail.com> wrote:

> This revision to the patch removes a misplaced
> blank line.
> 
> ---
> Fix MD5 signature checking so that an IPv4 active open
> to an IPv6 socket can succeed.  In particular, use the
> correct address family's signature generation function
> for the SYN/ACK.
> 
> Reported-by:   Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

This fixes the syn-ack, but data does not flow.
I had a simpler attempt that had same problem:


--- a/net/ipv6/tcp_ipv6.c	2009-07-15 18:08:11.042505387 -0700
+++ b/net/ipv6/tcp_ipv6.c	2009-07-15 20:05:56.270009553 -0700
@@ -1169,8 +1169,17 @@ static int tcp_v6_conn_request(struct so
 #define want_cookie 0
 #endif
 
-	if (skb->protocol == htons(ETH_P_IP))
-		return tcp_v4_conn_request(sk, skb);
+	if (skb->protocol == htons(ETH_P_IP)) {
+		int err;
+#ifdef CONFIG_TCP_MD5SIG
+		tp->af_specific = &tcp_sock_ipv6_mapped_specific;
+#endif
+		err = tcp_v4_conn_request(sk, skb);
+#ifdef CONFIG_TCP_MD5SIG
+		tp->af_specific = &tcp_sock_ipv6_specific;
+#endif
+		return err;
+	}
 
 	if (!ipv6_unicast_destination(skb))
 		goto drop;
