From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix kernel panic while received ASCONF chunk with bad
 serial number
Date: Tue, 05 Feb 2008 23:35:04 +0900
Message-ID: <47A87418.30206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65416 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbYBEOfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 09:35:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While recevied ASCONF chunk with serial number less then needed, kernel 
will treat this chunk as a retransmitted ASCONF chunk and find cached 
ASCONF-ACK chunk used sctp_assoc_lookup_asconf_ack(). But this function 
will always return NO-NULL. So response with cached ASCONF-ACKs chunk 
will cause kernel panic.
In function sctp_assoc_lookup_asconf_ack(), if the cached ASCONF-ACKs 
list asconf_ack_list is empty, or if the serial being requested does not 
exists, the function as it currectly stands returns the actuall 
list_head asoc->asconf_ack_list, this is not a cache ASCONF-ACK chunk 
but a bogus pointer.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/sctp/associola.c	2008-01-28 20:31:39.000000000 -0500
+++ b/net/sctp/associola.c	2008-01-28 23:45:20.000000000 -0500
@@ -1525,7 +1525,7 @@ struct sctp_chunk *sctp_assoc_lookup_asc
 					const struct sctp_association *asoc,
 					__be32 serial)
 {
-	struct sctp_chunk *ack = NULL;
+	struct sctp_chunk *ack;
 
 	/* Walk through the list of cached ASCONF-ACKs and find the
 	 * ack chunk whose serial number matches that of the request.
@@ -1533,9 +1533,9 @@ struct sctp_chunk *sctp_assoc_lookup_asc
 	list_for_each_entry(ack, &asoc->asconf_ack_list, transmitted_list) {
 		if (ack->subh.addip_hdr->serial == serial) {
 			sctp_chunk_hold(ack);
-			break;
+			return ack;
 		}
 	}
 
-	return ack;
+	return NULL;
 }


