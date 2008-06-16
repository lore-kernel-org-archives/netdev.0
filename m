From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Mon, 16 Jun 2008 16:59:00 -0700 (PDT)
Message-ID: <20080616.165900.189566405.davem@davemloft.net>
References: <20080613.023208.78649628.davem@davemloft.net>
	<20080613110913.GB9867@elte.hu>
	<20080613114746.GA27811@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752133AbYFPX67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 19:58:59 -0400
In-Reply-To: <20080613114746.GA27811@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 13 Jun 2008 13:47:46 +0200

> this threw the warning below - never saw that before in thousands of 
> bootups and this was the only networking change that happened. config 
> and bootlog attached. Might be unlucky coincidence.

So that we can make forward progress here, please confirm that the
following patch against -tip makes your problems go away for good.

Once you can confirm I will push it to Linus.

Thanks!

tcp: Revert reset of deferred accept changes in 2.6.26

Ingo's system is still seeing strange behavior, and he
reports that is goes away if the rest of the deferred
accept changes are reverted too.

Therefore this reverts e4c78840284f3f51b1896cf3936d60a6033c4d2c
("[TCP]: TCP_DEFER_ACCEPT updates - dont retxmt synack") and
539fae89bebd16ebeafd57a87169bc56eb530d76 ("[TCP]: TCP_DEFER_ACCEPT
updates - defer timeout conflicts with max_thresh").

Just like the other revert, these ideas can be revisited for
2.6.27

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inet_connection_sock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 045e799..ec83448 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -466,9 +466,9 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < (inet_rsk(req)->acked ? max_retries : thresh)) &&
-				    (inet_rsk(req)->acked ||
-				     !req->rsk_ops->rtx_syn_ack(parent, req))) {
+				if ((req->retrans < thresh ||
+				     (inet_rsk(req)->acked && req->retrans < max_retries))
+				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
-- 
1.5.5.1.308.g1fbb5

