From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 14:16:24 +0400
Message-ID: <20080718101624.GA7107@2ka.mipt.ru>
References: <20080717214222.GA29449@elte.hu> <20080718054626.GA3338@2ka.mipt.ru> <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:53662 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbYGRKQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 06:16:54 -0400
Content-Disposition: inline
In-Reply-To: <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pekka.

On Fri, Jul 18, 2008 at 12:02:26PM +0300, Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> > Out of curiosity, why does it scream at allocation time?
> 
> Because it's checking for use-after-free errors. The object is
> poisoned with POISON_FREE when it's free'd and we verify the poison
> values at allocation time.

Does it also scream on double free event? Just to closer guilty
circles... 0x9c offset is somewhere at the very end of the skbuff
structure, likely skb->users.

Can you also check in some kind of this patch to catch freed skb freeing
for testing?

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3666216..dda96bf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -419,6 +419,14 @@ void kfree_skb(struct sk_buff *skb)
 {
 	if (unlikely(!skb))
 		return;
+
+	{
+		u8 *ptr = (u8 *)(&skb->users);
+
+		if (*ptr == POISON_FREE || *ptr == POISON_INUSE || *ptr == POISON_END)
+			BUG();
+	}
+
 	if (likely(atomic_read(&skb->users) == 1))
 		smp_rmb();
 	else if (likely(!atomic_dec_and_test(&skb->users)))

-- 
	Evgeniy Polyakov
