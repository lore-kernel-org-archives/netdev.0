From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/6][SCTP]: Limit association max_retrans setting in
	setsockopt
Date: Thu, 15 Jun 2006 15:46:12 -0700
Message-ID: <1150411572.6028.31.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:65227 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750709AbWFOWrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 18:47:00 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5FMkxX5030297
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:46:59 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5FMkx3A280634
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:46:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5FMkxeR009758
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:46:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please apply the following 6 SCTP patches to 2.6 tree.

Thanks
Sridhar
---------------------------------------------------------------------
[SCTP]: Limit association max_retrans setting in setsockopt.

When using ASSOCINFO socket option, we need to limit the number of
maximum association retransmissions to be no greater than the sum
of all the path retransmissions. This is specified in Section 7.1.2
of the SCTP socket API draft.
However, we only do this if the association has multiple paths. If
there is only one path, the protocol stack will use the
assoc_max_retrans setting when trying to retransmit packets.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/socket.c |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2530,8 +2530,32 @@ static int sctp_setsockopt_associnfo(str
 
 	/* Set the values to the specific association */
 	if (asoc) {
-		if (assocparams.sasoc_asocmaxrxt != 0)
+		if (assocparams.sasoc_asocmaxrxt != 0) {
+			__u32 path_sum = 0;
+			int   paths = 0;
+			struct list_head *pos;
+			struct sctp_transport *peer_addr;
+
+			list_for_each(pos, &asoc->peer.transport_addr_list) {
+				peer_addr = list_entry(pos,
+						struct sctp_transport,
+						transports);
+				path_sum += peer_addr->pathmaxrxt;
+				paths++;
+			}
+
+			/* Only validate asocmaxrxt if we have more then
+			 * one path/transport.  We do this because path
+			 * retransmissions are only counted when we have more
+			 * then one path.
+			 */
+			if (paths > 1 &&
+			    assocparams.sasoc_asocmaxrxt > path_sum)
+				return -EINVAL;
+
 			asoc->max_retrans = assocparams.sasoc_asocmaxrxt;
+		}
+
 		if (assocparams.sasoc_cookie_life != 0) {
 			asoc->cookie_life.tv_sec =
 					assocparams.sasoc_cookie_life / 1000;


