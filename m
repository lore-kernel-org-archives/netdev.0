From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix possible memory leak while process INIT chunk with
 AUTH paramters
Date: Thu, 20 Mar 2008 15:09:28 +0800
Message-ID: <47E20DA8.1080805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62120 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753503AbYCTHIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 03:08:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While endpoint received INIT/INIT-ACK chunk with AUTH parameters, such 
as RANDOM, HMAC_ALGO, CHUNKS parameter, if those parameters appear more 
then once, memory for store those parameters will be malloc more then 
once and not free.

This patch change to used the first parameter and ignore the others.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/sctp/sm_make_chunk.c	2008-02-11 17:14:05.000000000 -0500
+++ b/net/sctp/sm_make_chunk.c	2008-02-14 03:57:58.000000000 -0500
@@ -2458,6 +2458,9 @@ static int sctp_process_param(struct sct
 		if (!sctp_auth_enable)
 			goto fall_through;
 
+		if (asoc->peer.peer_random)
+			break;
+
 		/* Save peer's random parameter */
 		asoc->peer.peer_random = kmemdup(param.p,
 					    ntohs(param.p->length), gfp);
@@ -2471,6 +2474,9 @@ static int sctp_process_param(struct sct
 		if (!sctp_auth_enable)
 			goto fall_through;
 
+		if (asoc->peer.peer_hmacs) 
+			break;
+
 		/* Save peer's HMAC list */
 		asoc->peer.peer_hmacs = kmemdup(param.p,
 					    ntohs(param.p->length), gfp);
@@ -2487,6 +2493,9 @@ static int sctp_process_param(struct sct
 		if (!sctp_auth_enable)
 			goto fall_through;
 
+		if (asoc->peer.peer_chunks)
+			break;
+
 		asoc->peer.peer_chunks = kmemdup(param.p,
 					    ntohs(param.p->length), gfp);
 		if (!asoc->peer.peer_chunks)



