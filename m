From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG][AX25] spinlock lockup
Date: Sun, 24 Feb 2008 20:51:01 +0100
Message-ID: <20080224195101.GA2961@ami.dom.local>
References: <001a01c87692$cfca8d00$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, 'Ralf Baechle' <ralf@linux-mips.org>
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:56569 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbYBXTpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 14:45:01 -0500
Received: by ug-out-1314.google.com with SMTP id z38so514808ugc.16
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2008 11:45:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <001a01c87692$cfca8d00$453c822c@dg8ngn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2008 at 04:10:29AM +0100, Jann Traschewski wrote:
> Hello,

Hi!

> I got a "spinlock lockup" using the latest Kernel 2.6.24.2 with recent
> patches from Jarek Poplawski applied.
...
>  ppp_deflate nf_nat zlib_deflateBUG: unable to handle kernel NULL pointer
> dereference zlib_inflate nf_conntrack_ipv4 bsd_comp slhc ppp_async xt_state
...
> EIP is at skb_append+0x1b/0x30
...
> 00000010 BUG: spinlock lockup on CPU#1, bcm/12213, f40846b8

Looks like 2 in 1: NULL pointer dereference and (later?) lockup.

There is only one function in AX25 calling skb_append(), and it really
looks suspicious: appends skb after previously enqueued one, but in
the meantime this previous skb could be removed from the queue.

Here is a patch for testing: it fixes this simple way, so this is not
fully compatible with the current method, but let's check if this could
be a problem?

Regards,
Jarek P.

(testing patch #1)

---

 net/ax25/ax25_subr.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
index d8f2157..034aa10 100644
--- a/net/ax25/ax25_subr.c
+++ b/net/ax25/ax25_subr.c
@@ -64,20 +64,15 @@ void ax25_frames_acked(ax25_cb *ax25, unsigned short nr)
 
 void ax25_requeue_frames(ax25_cb *ax25)
 {
-	struct sk_buff *skb, *skb_prev = NULL;
+	struct sk_buff *skb;
 
 	/*
 	 * Requeue all the un-ack-ed frames on the output queue to be picked
 	 * up by ax25_kick called from the timer. This arrangement handles the
 	 * possibility of an empty output queue.
 	 */
-	while ((skb = skb_dequeue(&ax25->ack_queue)) != NULL) {
-		if (skb_prev == NULL)
-			skb_queue_head(&ax25->write_queue, skb);
-		else
-			skb_append(skb_prev, skb, &ax25->write_queue);
-		skb_prev = skb;
-	}
+	while ((skb = skb_dequeue_tail(&ax25->ack_queue)) != NULL)
+		skb_queue_head(&ax25->write_queue, skb);
 }
 
 /*
