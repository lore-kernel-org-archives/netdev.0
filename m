From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 5/6] sctp: implement prsctp RTX policy
Date: Sat,  9 Jul 2016 19:47:44 +0800
Message-ID: <fd515720bebb78f127cc0998887cd96cc458b487.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
 <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
 <2b9ceacb55912e29c2d970772d0267e465c33dff.1468064737.git.lucien.xin@gmail.com>
 <63a9a850836134ba72b9377e8b99694d869e3fba.1468064737.git.lucien.xin@gmail.com>
 <bb59be49cce6ce873c75e43f1ba8f772dd5eed58.1468064737.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34276 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932947AbcGILsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 07:48:15 -0400
In-Reply-To: <bb59be49cce6ce873c75e43f1ba8f772dd5eed58.1468064737.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prsctp RTX policy is a policy to abandon chunks when they are
retransmitted beyond the max count.

This patch uses sent_count to count how many times one chunk has
been sent, and prsctp_param is the max rtx count, which is from
sinfo->sinfo_timetolive in sctp_set_prsctp_policy(). So similar
to TTL policy, if RTX policy is enabled, msg->expire_at won't
work.

Then in sctp_chunk_abandoned, this patch checks if chunk->sent_count
is bigger than chunk->prsctp_param to abandon this chunk.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/chunk.c         | 4 ++++
 net/sctp/sm_make_chunk.c | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 2698d12..b3692b5 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -355,6 +355,10 @@ int sctp_chunk_abandoned(struct sctp_chunk *chunk)
 		else
 			chunk->asoc->abandoned_unsent[SCTP_PR_INDEX(TTL)]++;
 		return 1;
+	} else if (SCTP_PR_RTX_ENABLED(chunk->sinfo.sinfo_flags) &&
+		   chunk->sent_count > chunk->prsctp_param) {
+		chunk->asoc->abandoned_sent[SCTP_PR_INDEX(RTX)]++;
+		return 1;
 	}
 
 	return 0;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 2c431ee..cfde934 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -720,6 +720,8 @@ static void sctp_set_prsctp_policy(struct sctp_chunk *chunk,
 	if (SCTP_PR_TTL_ENABLED(sinfo->sinfo_flags))
 		chunk->prsctp_param =
 			jiffies + msecs_to_jiffies(sinfo->sinfo_timetolive);
+	else if (SCTP_PR_RTX_ENABLED(sinfo->sinfo_flags))
+		chunk->prsctp_param = sinfo->sinfo_timetolive;
 }
 
 /* Make a DATA chunk for the given association from the provided
-- 
2.1.0
