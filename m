From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Tue, 11 Nov 2008 15:33:33 +0000
Message-ID: <B4ABF490-649C-4981-A953-B5FA55022EBD@nuim.ie>
References: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
 <20081110.215033.22437445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:52102 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754340AbYKKPda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 10:33:30 -0500
Received: from [10.220.3.214] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KA600CS5DVR7G80@mango.nuim.ie> for
 netdev@vger.kernel.org; Tue, 11 Nov 2008 15:33:27 +0000 (GMT)
In-reply-to: <20081110.215033.22437445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes a minor bug in tcp_htcp.c which has been
highlighted by Lachlan Andrew and Lawrence Stewart.  Currently, the
time since the last congestion event, which is stored in variable
last_cong, is reset whenever there is a state change into
TCP_CA_Open.  This includes transitions of the type
TCP_CA_Open->TCP_CA_Disorder->TCP_CA_Open which are not associated
with backoff of cwnd.  The patch changes last_cong to be updated
only on transitions into TCP_CA_Open that occur after experiencing
the congestion-related states TCP_CA_Loss, TCP_CA_Recovery,
TCP_CA_CWR.

Signed-off-by:  Doug Leith <doug.leith@nuim.ie>

---

Revised patch with requested style changes.

--- net/ipv4/tcp_htcp.c 2008-11-05 15:50:18.000000000 +0000
+++ net/ipv4/tcp_htcp.c.new     2008-11-11 15:20:31.000000000 +0000
@@ -71,5 +71,8 @@ static u32 htcp_cwnd_undo(struct sock *s

-       ca->last_cong = ca->undo_last_cong;
-       ca->maxRTT = ca->undo_maxRTT;
-       ca->old_maxB = ca->undo_old_maxB;
+       if (ca->undo_last_cong) {
+               ca->last_cong = ca->undo_last_cong;
+               ca->maxRTT = ca->undo_maxRTT;
+               ca->old_maxB = ca->undo_old_maxB;
+               ca->undo_last_cong = 0;
+       }

@@ -267,8 +270,11 @@ static void htcp_state(struct sock *sk,
         switch (new_state) {
-       case TCP_CA_Open:
+       case TCP_CA_Open:
                 {
                         struct htcp *ca = inet_csk_ca(sk);
-                       ca->last_cong = jiffies;
+                       if (ca->undo_last_cong) {
+                               ca->last_cong = jiffies;
+                               ca->undo_last_cong = 0;
+                       }
                 }
-               break;
+               break;
         case TCP_CA_CWR:



