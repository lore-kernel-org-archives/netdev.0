From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: validate chunk len before actually using it
Date: Tue, 25 Oct 2016 14:27:39 -0200
Message-ID: <06d1d4f21f959784823d7c7e31c3ea7e7360cb99.1477410525.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
        edumazet@google.com, dvyukov@google.com, andreyknvl@google.com,
        marcelo.leitner@gmail.com
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932543AbcJYQ14 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 12:27:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey Konovalov reported that KASAN detected that SCTP was using a slab
beyond the boundaries. It was caused because when handling out of the
blue packets in function sctp_sf_ootb() it was checking the chunk len
only after already processing the first chunk, validating only for the
2nd and subsequent ones.

The fix is to just move the check upwards so it's also validated for the
1st chunk.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Hi. Please consider this to -stable too. Thanks

 net/sctp/sm_statefuns.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 026e3bca4a94bd34b418d5e6947f7182c1512358..8ec20a64a3f8055a0c3576627c5ec5dad7e99ca8 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3422,6 +3422,12 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
+		/* Report violation if chunk len overflows */
+		ch_end = ((__u8 *)ch) + SCTP_PAD4(ntohs(ch->length));
+		if (ch_end > skb_tail_pointer(skb))
+			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
+						  commands);
+
 		/* Now that we know we at least have a chunk header,
 		 * do things that are type appropriate.
 		 */
@@ -3453,12 +3459,6 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 			}
 		}
 
-		/* Report violation if chunk len overflows */
-		ch_end = ((__u8 *)ch) + SCTP_PAD4(ntohs(ch->length));
-		if (ch_end > skb_tail_pointer(skb))
-			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
-						  commands);
-
 		ch = (sctp_chunkhdr_t *) ch_end;
 	} while (ch_end < skb_tail_pointer(skb));
 
-- 
2.7.4
