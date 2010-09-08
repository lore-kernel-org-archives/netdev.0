From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sctp: fix test for end of loop
Date: Wed, 08 Sep 2010 13:37:47 -0700 (PDT)
Message-ID: <20100908.133747.232732909.davem@davemloft.net>
References: <20100906122344.GA2764@bicker>
	<20100908.132420.179918700.davem@davemloft.net>
	<4C87F366.3070002@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, sri@us.ibm.com, yjwei@cn.fujitsu.com,
	cascardo@holoscopio.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602Ab0IHUh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:37:29 -0400
In-Reply-To: <4C87F366.3070002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 08 Sep 2010 16:34:46 -0400

> I would ack this.

So why don't you? :-)

sctp: Fix test for end of loop in sctp_sf_check_restart_addrs().

Based upon a patch by Dan Carpenter.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 8b28443..3d5bbae7 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1241,7 +1241,7 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 				       sctp_cmd_seq_t *commands)
 {
 	struct sctp_transport *new_addr, *addr;
-	int found;
+	int ret = 1;
 
 	/* Implementor's Guide - Sectin 5.2.2
 	 * ...
@@ -1254,31 +1254,28 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
 	/* Search through all current addresses and make sure
 	 * we aren't adding any new ones.
 	 */
-	new_addr = NULL;
-	found = 0;
-
 	list_for_each_entry(new_addr, &new_asoc->peer.transport_addr_list,
 			transports) {
-		found = 0;
 		list_for_each_entry(addr, &asoc->peer.transport_addr_list,
 				transports) {
 			if (sctp_cmp_addr_exact(&new_addr->ipaddr,
-						&addr->ipaddr)) {
-				found = 1;
-				break;
-			}
+						&addr->ipaddr))
+				goto next;
 		}
-		if (!found)
-			break;
-	}
 
-	/* If a new address was added, ABORT the sender. */
-	if (!found && new_addr) {
+		/* 'new_addr' could not be found in the transport address
+		 * list of 'asoc', abort.
+		 */
 		sctp_sf_send_restart_abort(&new_addr->ipaddr, init, commands);
+		ret = 0;
+		break;
+
+	next:
+		;
 	}
 
 	/* Return success if all addresses were found. */
-	return found;
+	return ret;
 }
 
 /* Populate the verification/tie tags based on overlapping INIT
