From: Tushar Gohad <tgohad@mvista.com>
Subject: [PATCH] XFRM: Fix memory leak in xfrm_state_update
Date: Thu, 7 Jul 2011 18:38:52 -0700 (MST)
Message-ID: <alpine.LFD.1.10.1107071820060.7677@net-test1.az.mvista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, tusharsg@gmail.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:53415 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab1GHBs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 21:48:26 -0400
Received: by pwj7 with SMTP id 7so838052pwj.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 18:48:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Upon "ip xfrm state update ..", xfrm_add_sa() takes an extra reference on 
the user-supplied SA and forgets to drop the reference when 
xfrm_state_update() returns 0.  This leads to a memory leak as the 
parameter SA is never freed.  This change attempts to fix the leak by 
calling __xfrm_state_put() when xfrm_state_update() updates a valid SA 
(err = 0).  The parameter SA is added to the gc list when the final 
reference is dropped by xfrm_add_sa() upon completion.

Signed-off-by: Tushar Gohad <tgohad@mvista.com>
---
  net/xfrm/xfrm_state.c |    2 ++
  1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index d70f85e..9414b9c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1345,6 +1345,8 @@ out:
  			xfrm_state_check_expire(x1);

  		err = 0;
+		x->km.state = XFRM_STATE_DEAD;
+		__xfrm_state_put(x);
  	}
  	spin_unlock_bh(&x1->lock);

-- 
1.6.3.3.202.g91879

