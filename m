From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] af_iucv: avoid path quiesce of severed path in shutdown()
Date: Mon, 21 Jul 2014 12:54:44 +0200
Message-ID: <20140721105502.589636932@de.ibm.com>
References: <20140721105442.533889716@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Philipp Hachtmann <phacht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:39628 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634AbaGUKzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 06:55:09 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jul 2014 11:55:07 +0100
Content-Disposition: inline; filename=601-af_iucv-path-quiesce.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

An af_iucv stress test showed -EPIPE results for sendmsg()
calls. They are caused by quiescing a path even though it has
been already severed by peer. For IUCV transport shutdown()
consists of 2 steps:
(1) sending the shutdown message to peer
(2) quiescing the iucv path
If the iucv path between these 2 steps is severed due to peer
closing the path, the quiesce step is no longer needed.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reported-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1542,7 +1542,8 @@ static int iucv_sock_shutdown(struct soc
 
 	sk->sk_shutdown |= how;
 	if (how == RCV_SHUTDOWN || how == SHUTDOWN_MASK) {
-		if (iucv->transport == AF_IUCV_TRANS_IUCV) {
+		if ((iucv->transport == AF_IUCV_TRANS_IUCV) &&
+		    iucv->path) {
 			err = pr_iucv->path_quiesce(iucv->path, NULL);
 			if (err)
 				err = -ENOTCONN;
