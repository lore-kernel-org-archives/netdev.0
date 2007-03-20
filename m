From: Deepak Saxena <dsaxena@plexity.net>
Subject: [PATCH -rt] Fix initialization of spinlock in irttp_dup()
Date: Tue, 20 Mar 2007 12:22:33 -0700
Message-ID: <20070320192233.GA14543@plexity.net>
Reply-To: dsaxena@plexity.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Ingo Molnar <mingo@elte.hu>, Daniel Walker <dwalker@mvista.com>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc11.comcast.net ([63.240.77.81]:40697 "EHLO
	sccrmhc11.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934064AbXCTUWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 16:22:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was found around the 2.6.10 timeframe when testing with the -rt patch
and I believe is still is an issue. irttp_dup() does a memcpy() of the tsap_cb 
structure causing the spinlock protecting various fields in the structure to be 
duped.  This works OK in the non-RT case but in the RT case we end up with two 
mutexes pointing to the same wait_list and leading to an OOPS. Fix is to simply
initialize the spinlock after the memcpy().

Signed-off-by: Deepak Saxena <dsaxena@mvista.com>

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index a7486b3..df2b2f7 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -1441,6 +1441,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb
 	}
 	/* Dup */
 	memcpy(new, orig, sizeof(struct tsap_cb));
+	spin_lock_init(&new->lock);
 
 	/* We don't need the old instance any more */
 	spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);


-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

In the end, they will not say, "those were dark times,"  they will ask
"why were their poets silent?" - Bertolt Brecht
