From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [BUG][AX25] Fwd: SMP with AX.25
Date: Thu, 7 Feb 2008 12:07:27 +0000
Message-ID: <20080207120727.GA2628@ff.dom.local>
References: <20080206074529.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
To: Jann Traschewski <jann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:43068 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbYBGMAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 07:00:21 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1063710wah.23
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2008 04:00:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 07:45:29AM +0000, Jarek Poplawski wrote:
...
> From: Jann Traschewski <jann@gmx.de>
> Subject: SMP with AX.25

(testing patch #2)

According to some OOPSes reported by Jann it seems ax25_kick
tries to clone NULL skbs sometimes. Probably there is needed
a sock lock, but until it's checked more this patch should
help to avoid this. There are probably also cases where ax25
->paclen == 0 can happen: let's check for this.

I attach this patch for testing purpose only.

Jarek P.

---

diff -Nurp 2.6.24-/net/ax25/ax25_out.c 2.6.24+/net/ax25/ax25_out.c
--- 2.6.24-/net/ax25/ax25_out.c	2008-01-24 22:58:37.000000000 +0000
+++ 2.6.24+/net/ax25/ax25_out.c	2008-02-07 11:48:39.000000000 +0000
@@ -117,6 +117,12 @@ void ax25_output(ax25_cb *ax25, int pacl
 	unsigned char *p;
 	int frontlen, len, fragno, ka9qfrag, first = 1;
 
+	if (paclen < 16) {
+		WARN_ON_ONCE(1);
+		kfree_skb(skb);
+		return;
+	}
+
 	if ((skb->len - 1) > paclen) {
 		if (*skb->data == AX25_P_TEXT) {
 			skb_pull(skb, 1); /* skip PID */
@@ -263,6 +269,8 @@ void ax25_kick(ax25_cb *ax25)
 	 * Dequeue the frame and copy it.
 	 */
 	skb  = skb_dequeue(&ax25->write_queue);
+	if (!skb)
+		return;
 
 	do {
 		if ((skbn = skb_clone(skb, GFP_ATOMIC)) == NULL) {
