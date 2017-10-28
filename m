From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 3/4] sctp: fix a type cast warnings that causes a_rwnd gets the wrong value
Date: Sat, 28 Oct 2017 19:43:56 +0800
Message-ID: <3d8cee6216e261609ec6307fc17fd6f5d6d28e5f.1509190967.git.lucien.xin@gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
 <d85747d7d1af0972a00b8d4594a84f2afe97aac8.1509190967.git.lucien.xin@gmail.com>
 <ddda2f5b5825a379793ac6f2ffff4c7ab9aa64e5.1509190967.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:50127 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdJ1Loa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 07:44:30 -0400
In-Reply-To: <ddda2f5b5825a379793ac6f2ffff4c7ab9aa64e5.1509190967.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1509190967.git.lucien.xin@gmail.com>
References: <cover.1509190967.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These warnings were found by running 'make C=2 M=net/sctp/'.

Commit d4d6fb5787a6 ("sctp: Try not to change a_rwnd when faking a
SACK from SHUTDOWN.") expected to use the peers old rwnd and add
our flight size to the a_rwnd. But with the wrong Endian, it may
not work as well as expected.

So fix it by converting to the right value.

Fixes: d4d6fb5787a6 ("sctp: Try not to change a_rwnd when faking a SACK from SHUTDOWN.")
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_sideeffect.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index e6a2974..8f2762b 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1680,8 +1680,8 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 		case SCTP_CMD_PROCESS_CTSN:
 			/* Dummy up a SACK for processing. */
 			sackh.cum_tsn_ack = cmd->obj.be32;
-			sackh.a_rwnd = asoc->peer.rwnd +
-					asoc->outqueue.outstanding_bytes;
+			sackh.a_rwnd = htonl(asoc->peer.rwnd +
+					     asoc->outqueue.outstanding_bytes);
 			sackh.num_gap_ack_blocks = 0;
 			sackh.num_dup_tsns = 0;
 			chunk->subh.sack_hdr = &sackh;
-- 
2.1.0
