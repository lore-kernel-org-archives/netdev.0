From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/2] XFRM: Drop packets when replay counter would overflow
Date: Fri, 21 Dec 2007 09:15:00 -0500
Message-ID: <20071221141500.11660.12287.stgit@flek.lan>
References: <20071221141334.11660.9191.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:32847
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbXLUOaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:30:24 -0500
In-Reply-To: <20071221141334.11660.9191.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to RFC4303, section 3.3.3 we need to drop outgoing packets which
cause the replay counter to overflow:

   3.3.3.  Sequence Number Generation

   The sender's counter is initialized to 0 when an SA is established.
   The sender increments the sequence number (or ESN) counter for this
   SA and inserts the low-order 32 bits of the value into the Sequence
   Number field.  Thus, the first packet sent using a given SA will
   contain a sequence number of 1.

   If anti-replay is enabled (the default), the sender checks to ensure
   that the counter has not cycled before inserting the new value in the
   Sequence Number field.  In other words, the sender MUST NOT send a
   packet on an SA if doing so would cause the sequence number to cycle.
   An attempt to transmit a packet that would result in sequence number
   overflow is an auditable event.  The audit log entry for this event
   SHOULD include the SPI value, current date/time, Source Address,
   Destination Address, and (in IPv6) the cleartext Flow ID.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/xfrm/xfrm_output.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 0951444..d73003c 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -57,8 +57,11 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
-			if (unlikely(x->replay.oseq == 0))
+			if (unlikely(x->replay.oseq == 0)) {
+				x->replay.oseq--;
 				xfrm_audit_state_replay_overflow(x, skb);
+				goto error;
+			}
 			if (xfrm_aevent_is_on())
 				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}

