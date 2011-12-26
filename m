From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix_diag: Fix incoming connections nla length
Date: Mon, 26 Dec 2011 14:42:45 -0500 (EST)
Message-ID: <20111226.144245.1639855054069401229.davem@davemloft.net>
References: <4EF7804D.4050300@parallels.com>
	<1324928172.2599.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab1LZTmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 14:42:51 -0500
In-Reply-To: <1324928172.2599.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Dec 2011 20:36:12 +0100

> if (peer)
> 	buf[i++] = sock_i_ino(peer);
> 
> So we probably leak kernel memory content to user for the (!peer) case,
> since we did :
> 
> UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS,
> 		sk->sk_receive_queue.qlen * sizeof(u32));

I just commited the following fix for this, it probably takes less
effort to post a patch for this kind of bug than explain it don't
you think? :)

--------------------
unix: If we happen to find peer NULL when diag dumping, write zero.

Otherwise we leave uninitialized kernel memory in there.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/unix/diag.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 39e44c9..c5bdbcb 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -86,8 +86,7 @@ static int sk_diag_dump_icons(struct sock *sk, struct sk_buff *nlskb)
 			 */
 			unix_state_lock_nested(req);
 			peer = unix_sk(req)->peer;
-			if (peer)
-				buf[i++] = sock_i_ino(peer);
+			buf[i++] = (peer ? sock_i_ino(peer) : 0);
 			unix_state_unlock(req);
 		}
 		spin_unlock(&sk->sk_receive_queue.lock);
-- 
1.7.7.4
