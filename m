From: kaber@trash.net
Subject: [PATCH 13/13] netfilter: nf_ct_tcp: fix out of sync scenario while in SYN_RECV
Date: Wed,  2 Mar 2011 13:12:53 +0100
Message-ID: <1299067973-15977-14-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32942 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757297Ab1CBMNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 07:13:02 -0500
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch fixes the out of sync scenarios while in SYN_RECV state.

Quoting Jozsef, what it happens if we are out of sync if the
following:

> > b. conntrack entry is outdated, new SYN received
> >    - (b1) we ignore it but save the initialization data from it
> >    - (b2) when the reply SYN/ACK receives and it matches the saved data,
> >      we pick up the new connection
This is what it should happen if we are in SYN_RECV state. Initially,
the SYN packet hits b1, thus we save data from it. But the SYN/ACK
packet is considered a retransmission given that we're in SYN_RECV
state. Therefore, we never hit b2 and we don't get in sync. To fix
this, we ignore SYN/ACK if we are in SYN_RECV. If the previous packet
was a SYN, then we enter the ignore case that get us in sync.

This patch helps a lot to conntrackd in stress scenarios (assumming a
client that generates lots of small TCP connections). During the failover,
consider that the new primary has injected one outdated flow in SYN_RECV
state (this is likely to happen if the conntrack event rate is high
because the backup will be a bit delayed from the primary). With the
current code, if the client starts a new fresh connection that matches
the tuple, the SYN packet will be ignored without updating the state
tracking, and the SYN+ACK in reply will blocked as it will not pass
checkings III or IV (since all state tracking in the original direction
is not initialized because of the SYN packet was ignored and the ignore
case that get us in sync is not applied).

I posted a couple of patches before this one. Changli Gao spotted
a simpler way to fix this problem. This patch implements his idea.

Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 6f38d0e..37bf943 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -227,11 +227,11 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sCL -> sIV
  */
 /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
-/*synack*/ { sIV, sSR, sSR, sIG, sIG, sIG, sIG, sIG, sIG, sSR },
+/*synack*/ { sIV, sSR, sIG, sIG, sIG, sIG, sIG, sIG, sIG, sSR },
 /*
  *	sSS -> sSR	Standard open.
  *	sS2 -> sSR	Simultaneous open
- *	sSR -> sSR	Retransmitted SYN/ACK.
+ *	sSR -> sIG	Retransmitted SYN/ACK, ignore it.
  *	sES -> sIG	Late retransmitted SYN/ACK?
  *	sFW -> sIG	Might be SYN/ACK answering ignored SYN
  *	sCW -> sIG
-- 
1.7.4

