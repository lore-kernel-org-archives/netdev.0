From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: do not trigger BUG_ON in sctp_cmd_delete_tcb
Date: Thu, 31 Oct 2013 09:13:32 +0100
Message-ID: <1383207212-21658-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417Ab3JaINl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 04:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced in f9e42b853523 ("net: sctp: sideeffect: throw BUG if
primary_path is NULL"), we intended to find a buggy assoc that's
part of the assoc hash table with a primary_path that is NULL.
However, we better remove the BUG_ON for now and find a more
suitable place to assert for these things as Mark reports that
this also triggers the bug when duplication cookie processing
happens, and the assoc is not part of the hash table (so all
good in this case). Such a situation can for example easily be
reproduced by:

  tc qdisc add dev eth0 root handle 1: prio bands 2 priomap 1 1 1 1 1 1
  tc qdisc add dev eth0 parent 1:2 handle 20: netem loss 20%
  tc filter add dev eth0 protocol ip parent 1: prio 2 u32 match ip \
            protocol 132 0xff match u8 0x0b 0xff at 32 flowid 1:2

This drops 20% of COOKIE-ACK packets. After some follow-up
discussion with Vlad we came to the conclusion that for now we
should still better remove this BUG_ON() assertion, and come up
with two follow-ups later on, that is, i) find a more suitable
place for this assertion, and possibly ii) have a special
allocator/initializer for such kind of temporary assocs.

Reported-by: Mark Thomas <Mark.Thomas@metaswitch.com>
Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/sm_sideeffect.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 666c668..1a6eef3 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -860,7 +860,6 @@ static void sctp_cmd_delete_tcb(sctp_cmd_seq_t *cmds,
 	    (!asoc->temp) && (sk->sk_shutdown != SHUTDOWN_MASK))
 		return;
 
-	BUG_ON(asoc->peer.primary_path == NULL);
 	sctp_unhash_established(asoc);
 	sctp_association_free(asoc);
 }
-- 
1.8.3.1
