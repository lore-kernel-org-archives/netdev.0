From: David Miller <davem@davemloft.net>
Subject: Re: suspect locking in net/irda/iriap.c
Date: Mon, 06 Jun 2011 17:00:56 -0700 (PDT)
Message-ID: <20110606.170056.193694265.davem@davemloft.net>
References: <20110421034057.GA10536@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55883
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752798Ab1FGABZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 20:01:25 -0400
In-Reply-To: <20110421034057.GA10536@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 20 Apr 2011 23:40:58 -0400

> My reading of that comment suggests that the two locks aren't the same,
> so is this just missing a lockdep annotation ?

Dave, I'm going to check in the following to net-2.6 to try and
address this.  Let me know how it works for you.

--------------------
irda: iriap: Use seperate lockdep class for irias_objects->hb_spinlock

The SEQ output functions grab the obj->attrib->hb_spinlock lock of
sub-objects found in the hash traversal.  These locks are in a different
realm than the one used for the irias_objects hash table itself.

So put the latter into it's own lockdep class.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/iriap.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 3647753..f876eed 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -87,6 +87,8 @@ static inline void iriap_start_watchdog_timer(struct iriap_cb *self,
 			 iriap_watchdog_timer_expired);
 }
 
+static struct lock_class_key irias_objects_key;
+
 /*
  * Function iriap_init (void)
  *
@@ -114,6 +116,9 @@ int __init iriap_init(void)
 		return -ENOMEM;
 	}
 
+	lockdep_set_class_and_name(&irias_objects->hb_spinlock, &irias_objects_key,
+				   "irias_objects");
+
 	/*
 	 *  Register some default services for IrLMP
 	 */
-- 
1.7.5.2

