From: Xin Long <lucien.xin@gmail.com>
Subject: [RFC PATCH net] sctp: ASCONF-ACK with Unresolvable Address should be sent
Date: Sat, 25 Jul 2015 13:08:08 +0800
Message-ID: <1437800888-17413-1-git-send-email-lucien.xin@gmail.com>
Cc: mleitner@redhat.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34515 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbbGYFIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 01:08:14 -0400
Received: by pdbbh15 with SMTP id bh15so23120821pdb.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 22:08:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 5061:
    This is an opaque integer assigned by the sender to identify each
    request parameter.  The receiver of the ASCONF Chunk will copy this
    32-bit value into the ASCONF Response Correlation ID field of the
    ASCONF-ACK response parameter.  The sender of the ASCONF can use this
    same value in the ASCONF-ACK to find which request the response is
    for.  Note that the receiver MUST NOT change this 32-bit value.

    Address Parameter: TLV

    This field contains an IPv4 or IPv6 address parameter, as described
    in Section 3.3.2.1 of [RFC4960].

ASCONF chunk with Error Cause Indication Parameter (Unresolvable Address)
should be sent if the Delete IP Address is not part of the association.

  Endpoint A                           Endpoint B
  (ESTABLISHED)                        (ESTABLISHED)

  ASCONF        ----------------->
  (Delete IP Address)
                <-----------------      ASCONF-ACK
                                        (Unresolvable Address)

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_make_chunk.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 06320c8..6e399f6 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3090,8 +3090,19 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 			sctp_assoc_set_primary(asoc, asconf->transport);
 			sctp_assoc_del_nonprimary_peers(asoc,
 							asconf->transport);
-		} else
-			sctp_assoc_del_peer(asoc, &addr);
+			return SCTP_ERROR_NO_ERROR;
+		}
+
+		/* If the address is not part of the association, the
+		 * ASCONF-ACK with Error Cause Indication Parameter
+		 * which including cause of Unresolvable Address should
+		 * be sent.
+		 */
+		peer = sctp_assoc_lookup_paddr(asoc, &addr);
+		if (!peer)
+			return SCTP_ERROR_DNS_FAILED;
+
+		sctp_assoc_rm_peer(asoc, peer);
 		break;
 	case SCTP_PARAM_SET_PRIMARY:
 		/* ADDIP Section 4.2.4
-- 
2.1.0
