From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: fix the transports round robin issue when init is retransmitted
Date: Thu, 10 Mar 2016 15:31:57 +0800
Message-ID: <8d3cd163c84b30797f1123a7fc8a56f768801a87.1457595117.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34778 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307AbcCJHcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 02:32:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prior to this patch, at the beginning if we have two paths in one assoc,
they may have the same params other than the last_time_heard, it will try
the paths like this:

1st cycle
  try trans1 fail.
  then trans2 is selected.(cause it's last_time_heard is after trans1).

2nd cycle:
  try  trans2 fail
  then trans2 is selected.(cause it's last_time_heard is after trans1).

3rd cycle:
  try  trans2 fail
  then trans2 is selected.(cause it's last_time_heard is after trans1).

....

trans1 will never have change to be selected, which is not what we expect.
we should keeping round robin all the paths if they are just added at the
beginning.

So at first every tranport's last_time_heard should be initialized 0, so
that we ensure they have the same value at the beginning, only by this,
all the transports could get equal chance to be selected.

Then for sctp_trans_elect_best, it should return the trans_next one when
*trans == *trans_next, so that we can try next if it fails,  but now it
always return trans. so we can fix it by exchanging these two params when
we calls sctp_trans_elect_tie().

Fixes: 4c47af4d5eb2 ('net: sctp: rework multihoming retransmission path selection to rfc4960')
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/associola.c | 2 +-
 net/sctp/transport.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2bf8ec9..cd87344 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1263,7 +1263,7 @@ static struct sctp_transport *sctp_trans_elect_best(struct sctp_transport *curr,
 	if (score_curr > score_best)
 		return curr;
 	else if (score_curr == score_best)
-		return sctp_trans_elect_tie(curr, best);
+		return sctp_trans_elect_tie(best, curr);
 	else
 		return best;
 }
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index a431c14..d517153 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -72,7 +72,7 @@ static struct sctp_transport *sctp_transport_init(struct net *net,
 	 */
 	peer->rto = msecs_to_jiffies(net->sctp.rto_initial);
 
-	peer->last_time_heard = ktime_get();
+	peer->last_time_heard = ktime_set(0, 0);
 	peer->last_time_ecne_reduced = jiffies;
 
 	peer->param_flags = SPP_HB_DISABLE |
-- 
2.1.0
