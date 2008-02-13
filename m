From: Kris Katterjohn <katterjohn@gmail.com>
Subject: [PATCH] Reorder ACK/RST checking in LISTEN state
Date: Wed, 13 Feb 2008 00:38:13 -0600
Message-ID: <47B29055.8060409@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000908050606020507060302"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:20412 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbYBMGiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:38:20 -0500
Received: by an-out-0708.google.com with SMTP id d31so1292731and.103
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 22:38:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000908050606020507060302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hey everyone,

[I'm not subscribed, so please CC me on any replies]

I've attached a patch that changes the order of the ACK and RST checking 
in the LISTEN state in tcp_rcv_state_process() in tcp_input.c

Before:  If an ACK/RST packet is received, then tcp_rcv_state_process() 
would return 1 because of the ACK.  Then (following the function calls 
in tcp_ipv4.c and tcp_minisocks.c), tcp_v4_send_reset() is called--but 
since there is a RST in the packet it just returns.  After this, the 
kfree_skb() is called.  The same goes in tcp_ipv6.c as well.

But if the order of the ACK and RST checking is reversed, __kfree_skb() 
is called in tcp_rcv_state_process() because of the RST and the function 
returns 0, which skips that other useless stuff.

This is the order specified on page 65 of RFC 793 anyway.

Signed-off-by: Kris Katterjohn <katterjohn@gmail.com>

Thanks,
Kris Katterjohn

--------------000908050606020507060302
Content-Type: text/x-patch;
 name="ackrst.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ackrst.patch"

--- net/ipv4/tcp_input.c	2008-02-13 00:05:59.000000000 -0600
+++ net/ipv4/tcp_input.c	2008-02-13 00:10:40.000000000 -0600
@@ -4962,12 +4962,12 @@ int tcp_rcv_state_process(struct sock *s
 		goto discard;
 
 	case TCP_LISTEN:
-		if (th->ack)
-			return 1;
-
 		if (th->rst)
 			goto discard;
 
+		if (th->ack)
+			return 1;
+
 		if (th->syn) {
 			if (icsk->icsk_af_ops->conn_request(sk, skb) < 0)
 				return 1;

--------------000908050606020507060302--
