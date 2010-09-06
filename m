From: Dan Carpenter <error27@gmail.com>
Subject: [patch] sctp: fix test for end of loop
Date: Mon, 6 Sep 2010 14:26:39 +0200
Message-ID: <20100906122344.GA2764@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52620 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab0IFM1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 08:27:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"new_addr" is the list cursor here and it's always non-NULL.

We're trying to test if we exited because the loop ended or we hit the
break statement.  Really testing !found is enough so long as 
"new_asoc->peer.transport_addr_list" is not empty and I believe it never
is empty at this point.  So this is never really a bug with the current
code.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Compile tested only.

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 24b2cd5..cb76d2e 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1254,7 +1254,6 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 	/* Search through all current addresses and make sure
 	 * we aren't adding any new ones.
 	 */
-	new_addr = NULL;
 	found = 0;
 
 	list_for_each_entry(new_addr, &new_asoc->peer.transport_addr_list,
@@ -1273,7 +1272,8 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 	}
 
 	/* If a new address was added, ABORT the sender. */
-	if (!found && new_addr) {
+	if (!found &&
+	    &new_addr->transports != &new_asoc->peer.transport_addr_list) {
 		sctp_sf_send_restart_abort(&new_addr->ipaddr, init, commands);
 	}
 
