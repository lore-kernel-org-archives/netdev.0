From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [Bug-Fix][Patch 1/1] dccp: fix oops on Reset after close
Date: Wed, 2 Mar 2011 07:34:47 +0100
Message-ID: <20110302063447.GB4902@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <jhovold@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53089 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750918Ab1CBGe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 01:34:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

could you please apply the below bug fix for a condition where a simple packet
reception can trigger oops.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: fix oops on Reset after close

This fixes a bug in the order of dccp_rcv_state_process() that still permitted
reception even after closing the socket. A Reset after close thus causes a NULL
pointer dereference by not preventing operations on an already torn-down socket.

 dccp_v4_do_rcv() 
	|
	| state other than OPEN
	v
 dccp_rcv_state_process()
	|
	| DCCP_PKT_RESET
	v
 dccp_rcv_reset()
	|
	v
 dccp_time_wait()

 WARNING: at net/ipv4/inet_timewait_sock.c:141 __inet_twsk_hashdance+0x48/0x128()
 Modules linked in: arc4 ecb carl9170 rt2870sta(C) mac80211 r8712u(C) crc_ccitt ah
 [<c0038850>] (unwind_backtrace+0x0/0xec) from [<c0055364>] (warn_slowpath_common)
 [<c0055364>] (warn_slowpath_common+0x4c/0x64) from [<c0055398>] (warn_slowpath_n)
 [<c0055398>] (warn_slowpath_null+0x1c/0x24) from [<c02b72d0>] (__inet_twsk_hashd)
 [<c02b72d0>] (__inet_twsk_hashdance+0x48/0x128) from [<c031caa0>] (dccp_time_wai)
 [<c031caa0>] (dccp_time_wait+0x40/0xc8) from [<c031c15c>] (dccp_rcv_state_proces)
 [<c031c15c>] (dccp_rcv_state_process+0x120/0x538) from [<c032609c>] (dccp_v4_do_)
 [<c032609c>] (dccp_v4_do_rcv+0x11c/0x14c) from [<c0286594>] (release_sock+0xac/0)
 [<c0286594>] (release_sock+0xac/0x110) from [<c031fd34>] (dccp_close+0x28c/0x380)
 [<c031fd34>] (dccp_close+0x28c/0x380) from [<c02d9a78>] (inet_release+0x64/0x70)

The fix is by testing the socket state first. Receiving a packet in Closed state
now also produces the required "No connection" Reset reply of RFC 4340, 8.3.1.

Reported-and-tested-by: Johan Hovold <jhovold@gmail.com>
Cc: stable@kernel.org
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -614,6 +614,9 @@ int dccp_rcv_state_process(struct sock *
 		/* Caller (dccp_v4_do_rcv) will send Reset */
 		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
 		return 1;
+	} else if (sk->sk_state == DCCP_CLOSED) {
+		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
+		return 1;
 	}
 
 	if (sk->sk_state != DCCP_REQUESTING && sk->sk_state != DCCP_RESPOND) {
@@ -668,10 +671,6 @@ int dccp_rcv_state_process(struct sock *
 	}
 
 	switch (sk->sk_state) {
-	case DCCP_CLOSED:
-		dcb->dccpd_reset_code = DCCP_RESET_CODE_NO_CONNECTION;
-		return 1;
-
 	case DCCP_REQUESTING:
 		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
 		if (queued >= 0)
