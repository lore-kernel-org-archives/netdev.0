From: David Miller <davem@davemloft.net>
Subject: [PATCH] irda: Correctly clean up self->ias_obj on irda_bind()
 failure.
Date: Mon, 30 Aug 2010 18:38:08 -0700 (PDT)
Message-ID: <20100830.183808.13776839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: taviso@cmpxchg8b.com, torvalds@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756426Ab0HaBhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 21:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If irda_open_tsap() fails, the irda_bind() code tries to destroy the
->ias_obj object by hand, but does so wrongly.

In particular, it fails to a) release the hashbin attached to the
object and b) reset the self->ias_obj pointer to NULL.

Fix both problems by using irias_delete_object() and explicitly
setting self->ias_obj to NULL, just as irda_release() does.

Reported-by: Tavis Ormandy <taviso@cmpxchg8b.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-2.6 and queued up for -stable.

 net/irda/af_irda.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 79986a6..fd55b51 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -824,8 +824,8 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	err = irda_open_tsap(self, addr->sir_lsap_sel, addr->sir_name);
 	if (err < 0) {
-		kfree(self->ias_obj->name);
-		kfree(self->ias_obj);
+		irias_delete_object(self->ias_obj);
+		self->ias_obj = NULL;
 		goto out;
 	}
 
-- 
1.7.2.2

