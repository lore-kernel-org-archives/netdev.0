From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] [SCTP] Do not interleave non-fragments when in partial
 delivery
Date: Wed, 18 Apr 2007 16:52:26 -0400
Message-ID: <4626850A.2060008@hp.com>
References: <46266597.2000705@hp.com> <20070418.132408.15264893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090803040507000205050407"
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:33386 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992683AbXDRUwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 16:52:32 -0400
In-Reply-To: <20070418.132408.15264893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090803040507000205050407
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Wed, 18 Apr 2007 14:38:15 -0400
> 
>> This is a bug fix, but done on top of 2.6.22 tree.  I am trying
>> to minimize the amount of conflict this would cause during merge
>> by doing it this way.  However, if you would rather keep all the bugfixes
>> in net-2.6, I can do that too, but that _will_ give you conflicts.
> 
> I've already determined that I'm destined to deal with tons
> of conclicts anyways :-)
> 
> I'll backport this to net-2.6 unless you beat me to it :-)

attached :)

-vlad

--------------090803040507000205050407
Content-Type: text/plain;
 name="pd.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pd.txt"

>From ebf07dc09049969873b50f594640fe475e1ee294 Mon Sep 17 00:00:00 2001
From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 18 Apr 2007 16:48:24 -0400
Subject: [PATCH] [SCTP] Do not interleave non-fragments when in partial delivery

The way partial delivery is currently implemnted, it is possible to
intereleave a message (either from another steram, or unordered) that
is not part of partial delivery process.  The only way to this is for
a message to not be a fragment and be 'in order' or unorderd for a
given stream.  This will result in bypassing the reassembly/ordering
queues where things live duing partial delivery, and the
message will be delivered to the socket in the middle of partial delivery.

This is a two-fold problem, in that:
1.  the app now must check the stream-id and flags which it may not
be doing.
2.  this clearing partial delivery state from the association and results
in ulp hanging.

This patch is a band-aid over a much bigger problem in that we
don't do stream interleave.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/ulpqueue.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index bfb197e..b29e3e4 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -190,7 +190,14 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	if (!sctp_sk(sk)->pd_mode) {
 		queue = &sk->sk_receive_queue;
 	} else if (ulpq->pd_mode) {
-		if (event->msg_flags & MSG_NOTIFICATION)
+		/* If the association is in partial delivery, we
+		 * need to finish delivering the partially processed
+		 * packet before passing any other data.  This is
+		 * because we don't truly support stream interleaving.
+		 */
+		if ((event->msg_flags & MSG_NOTIFICATION) ||
+		    (SCTP_DATA_NOT_FRAG ==
+			    (event->msg_flags & SCTP_DATA_FRAG_MASK)))
 			queue = &sctp_sk(sk)->pd_lobby;
 		else {
 			clear_pd = event->msg_flags & MSG_EOR;
-- 
1.5.0.3.438.gc49b2


--------------090803040507000205050407--
