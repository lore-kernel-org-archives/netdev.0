From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Wed, 12 Nov 2008 08:58:18 +0000
Message-ID: <63599554-7243-4E44-BFEF-5B4B36743606@nuim.ie>
References: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
 <20081110.215033.22437445.davem@davemloft.net>
 <B4ABF490-649C-4981-A953-B5FA55022EBD@nuim.ie>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_e0pRC7Y2iqQyGRbrIiFbBw)"
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:48897 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbYKLI6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 03:58:13 -0500
Received: from [10.220.3.214] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KA7002YLQ8ZN770@mango.nuim.ie> for
 netdev@vger.kernel.org; Wed, 12 Nov 2008 08:58:11 +0000 (GMT)
In-reply-to: <B4ABF490-649C-4981-A953-B5FA55022EBD@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Boundary_(ID_e0pRC7Y2iqQyGRbrIiFbBw)
Content-type: text/plain; charset=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT

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

Resending with patch as attachment.   Hope this does the trick.


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



--Boundary_(ID_e0pRC7Y2iqQyGRbrIiFbBw)
Content-type: application/octet-stream; x-unix-mode=0644; name=patch.diff
Content-transfer-encoding: 7bit
Content-disposition: attachment; filename=patch.diff

--- net/ipv4/tcp_htcp.c	2008-11-05 15:50:18.000000000 +0000
+++ net/ipv4/tcp_htcp.c.new	2008-11-11 15:20:31.000000000 +0000
@@ -71,5 +71,8 @@ static u32 htcp_cwnd_undo(struct sock *s
 
-	ca->last_cong = ca->undo_last_cong;
-	ca->maxRTT = ca->undo_maxRTT;
-	ca->old_maxB = ca->undo_old_maxB;
+	if (ca->undo_last_cong) {
+		ca->last_cong = ca->undo_last_cong;
+		ca->maxRTT = ca->undo_maxRTT;
+		ca->old_maxB = ca->undo_old_maxB;
+		ca->undo_last_cong = 0;  
+	}
 
@@ -267,8 +270,11 @@ static void htcp_state(struct sock *sk, 
 	switch (new_state) {
-	case TCP_CA_Open:
+	case TCP_CA_Open: 
 		{
 			struct htcp *ca = inet_csk_ca(sk);
-			ca->last_cong = jiffies;
+        		if (ca->undo_last_cong) { 
+				ca->last_cong = jiffies;   
+				ca->undo_last_cong = 0;
+			}
 		}
-		break;
+		break;	
 	case TCP_CA_CWR:

--Boundary_(ID_e0pRC7Y2iqQyGRbrIiFbBw)
Content-type: text/plain; charset=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT



--Boundary_(ID_e0pRC7Y2iqQyGRbrIiFbBw)--
