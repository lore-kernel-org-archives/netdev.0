From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Sun, 09 Nov 2008 19:09:24 +0000
Message-ID: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Lachlan Andrew <lachlan.andrew@gmail.com>,
	Lawrence Stewart <lstewart@room52.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:39715 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752881AbYKITJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2008 14:09:25 -0500
Received: from [10.8.0.6] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KA200AWKYJL9UA0@mango.nuim.ie> for
 netdev@vger.kernel.org; Sun, 09 Nov 2008 19:09:22 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a minor bug in tcp_htcp.c which has been highlighted  
by Lachlan Andrew and Lawrence Stewart.   Currently, the time since  
the last congestion event, which is stored in variable last_cong, is  
reset whenever there is a state change into TCP_CA_Open.  This  
includes transitions of the type TCP_CA_Open->TCP_CA_Disorder- 
 >TCP_CA_Open which are not associated with backoff of cwnd.  The  
patch changes last_cong to be updated only on transitions into  
TCP_CA_Open that occur after experiencing the congestion-related  
states TCP_CA_Loss, TCP_CA_Recovery, TCP_CA_CWR.

Doug

--- tcp_htcp.c   2008-11-05 15:50:18.000000000 +0000
+++ tcp_htcp.c.new       2008-11-08 07:11:18.000000000 +0000
@@ -69,9 +69,12 @@
         const struct tcp_sock *tp = tcp_sk(sk);
         struct htcp *ca = inet_csk_ca(sk);

-       ca->last_cong = ca->undo_last_cong;
-       ca->maxRTT = ca->undo_maxRTT;
-       ca->old_maxB = ca->undo_old_maxB;
+       if (ca->undo_last_cong) {
+               ca->last_cong = ca->undo_last_cong;
+               ca->maxRTT = ca->undo_maxRTT;
+               ca->old_maxB = ca->undo_old_maxB;
+               ca->undo_last_cong=0; // flag that ca->last_cong is  
not to be reset when enter TCP_CA_Open state
+       }

         return max(tp->snd_cwnd, (tp->snd_ssthresh << 7) / ca->beta);
  }
@@ -265,12 +268,15 @@
  static void htcp_state(struct sock *sk, u8 new_state)
  {
         switch (new_state) {
-       case TCP_CA_Open:
+       case TCP_CA_Open:
                 {
                         struct htcp *ca = inet_csk_ca(sk);
-                       ca->last_cong = jiffies;
+                       if (ca->undo_last_cong) {
+                               ca->last_cong=jiffies;
+                               ca->undo_last_cong=0;
+                       }
                 }
-               break;
+               break;
         case TCP_CA_CWR:
         case TCP_CA_Recovery:
         case TCP_CA_Loss:



