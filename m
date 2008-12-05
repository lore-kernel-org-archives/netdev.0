From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: [PATCH 2.6.27] tcp_vegas ssthresh bug fix
Date: Fri, 05 Dec 2008 00:11:05 +0000
Message-ID: <650FA54C-402C-48CC-95AD-CA4AC5086BAD@nuim.ie>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_sDKE+jcDjNpCLwSI/nd/pA)"
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:44525 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbYLEALH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 19:11:07 -0500
Received: from [10.8.0.6] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KBD000FPN6EMN80@mango.nuim.ie> for
 netdev@vger.kernel.org; Fri, 05 Dec 2008 00:11:03 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Boundary_(ID_sDKE+jcDjNpCLwSI/nd/pA)
Content-type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-transfer-encoding: 7BIT

This patch fixes a bug in tcp_vegas.c.  At the moment this code  
leaves ssthresh untouched.  However, this means that the vegas  
congestion control algorithm is effectively unable to reduce cwnd  
below the ssthresh value (if the vegas update lowers the cwnd below  
ssthresh, then slow start is activated to raise it back up).   One  
example where this matters is when during slow start cwnd overshoots  
the link capacity and a flow then exits slow start with ssthresh set  
to a value above where congestion avoidance would like to adjust it.

Signed-off-by:  Doug Leith <doug.leith@nuim.ie>

---
--- net/ipv4/tcp_vegas.c.orig   2008-12-04 23:51:19.000000000 +0000
+++ net/ipv4/tcp_vegas.c        2008-12-05 00:00:42.000000000 +0000
@@ -328,2 +328,4 @@ static void tcp_vegas_cong_avoid(struct
                                 tp->snd_cwnd = tp->snd_cwnd_clamp;
+
+                       tp->snd_ssthresh = tcp_current_ssthresh(sk);
                 }



--Boundary_(ID_sDKE+jcDjNpCLwSI/nd/pA)
Content-type: application/octet-stream; x-unix-mode=0644;
 name=vegas_ssthreshfix.diff
Content-transfer-encoding: 7bit
Content-disposition: attachment; filename=vegas_ssthreshfix.diff

--- net/ipv4/tcp_vegas.c.orig	2008-12-04 23:51:19.000000000 +0000
+++ net/ipv4/tcp_vegas.c	2008-12-05 00:00:42.000000000 +0000
@@ -328,2 +328,4 @@ static void tcp_vegas_cong_avoid(struct 
 				tp->snd_cwnd = tp->snd_cwnd_clamp;
+
+			tp->snd_ssthresh = tcp_current_ssthresh(sk);
 		}

--Boundary_(ID_sDKE+jcDjNpCLwSI/nd/pA)--
