From: Miguel Freitas <miguel@cetuc.puc-rio.br>
Subject: [Fwd: [patch] fix slot clash in sch_sfq.c]
Date: Wed, 11 Feb 2004 18:47:41 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076532461.19204.50.camel@pitanga.ldhs.cetuc.puc-rio.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-kIJdkkgwUcfHpT4f9oCD"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-kIJdkkgwUcfHpT4f9oCD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I better send a copy of this one to the mailing list...

please cc me, i'm not subscribed.

regards,

Miguel


--=-kIJdkkgwUcfHpT4f9oCD
Content-Disposition: inline
Content-Description: Forwarded message - [patch] fix slot clash in sch_sfq.c
Content-Type: message/rfc822

Subject: [patch] fix slot clash in sch_sfq.c
From: Miguel Freitas <miguel@cetuc.puc-rio.br>
To: kuznet@ms2.inr.ac.ru
Cc: davem@redhat.com
Content-Type: multipart/mixed; boundary="=-IhvvO/pwTB7MEDV3my7O"
Message-Id: <1076508824.19201.25.camel@pitanga.ldhs.cetuc.puc-rio.br>
Mime-Version: 1.0
X-Mailer: Ximian Evolution 1.4.5 (1.4.5-7) 
Date: Wed, 11 Feb 2004 12:13:45 -0200


--=-IhvvO/pwTB7MEDV3my7O
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Alexey, Hi David,

I've found a slot "leak" in sch_sfq.c that occurs with current 2.4 and
2.6 kernels. After dequeueing the last skb from a given slot, this slot
might be reused by a different hash (say new_hash). However the old hash
(q->ht[old_hash]) still points to the (now) reused slot. When new skb's
arrive with old_hash they will be enqueued at the same slot as new_hash
skb's (that is, q->ht[old_hash] == q->ht[new_hash]).

This produce a "slot clash" (opposed to a "hash clash"), severely
affecting the effectiveness of SFQ to provide fairness.

The attached one line patch fixes it, freeing the slot when last skb is
dequeued.

Note: I've noticed this problem while testing a fixed hash function of
the IP. the number of active slots didn't matched the number of active
IP clients. I have created a small standalone application, using
sch_sfq.c, to reproduce and debug this problem. I may provide this
application and a small data set (sequence of enqueues/dequeues) that
trigger the problem, let me know if you need it.

regards,

Miguel Freitas


--=-IhvvO/pwTB7MEDV3my7O
Content-Disposition: attachment; filename=sfq-slot-clash-fix.patch
Content-Type: text/x-patch; name=sfq-slot-clash-fix.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- sch_sfq.orig	2004-02-09 11:10:43.000000000 -0200
+++ sch_sfq.c	2004-02-11 02:32:06.000000000 -0200
@@ -338,6 +338,7 @@
 
 	/* Is the slot empty? */
 	if (q->qs[a].qlen == 0) {
+		q->ht[q->hash[a]] = SFQ_DEPTH;
 		a = q->next[a];
 		if (a == old_a) {
 			q->tail = SFQ_DEPTH;

--=-IhvvO/pwTB7MEDV3my7O--


--=-kIJdkkgwUcfHpT4f9oCD--
