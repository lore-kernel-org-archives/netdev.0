From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Wed, 13 Feb 2008 11:56:07 +0000
Message-ID: <20080213115607.GB2867@ff.dom.local>
References: <20080206074529.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jann Traschewski <jann@gmx.de>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:61589 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134AbYBMLtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 06:49:00 -0500
Received: by fk-out-0910.google.com with SMTP id z23so5292794fkz.5
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 03:48:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is an "official" version of "testing patch #2" from this thread.
The only difference: ax25->vs is changed only after checking skb is
not NULL (plus a comment). IMHO it could be applied.

Thanks,
Jarek P.

---------------->

Subject: [AX25] ax25_out: check skb for NULL in ax25_kick()

According to some OOPS reports ax25_kick tries to clone NULL skbs
sometimes. It looks like a race with ax25_clear_queues(). Probably
there is no need to add more than a simple check for this yet.
Another report suggested there are probably also cases where ax25
->paclen == 0 can happen in ax25_output(); this wasn't confirmed
during testing but let's leave this debugging check for some time.


Reported-and-tested-by: Jann Traschewski <jann@gmx.de>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp 2.6.24-mm1-/net/ax25/ax25_out.c 2.6.24-mm1+/net/ax25/ax25_out.c
--- 2.6.24-mm1-/net/ax25/ax25_out.c	2008-01-24 22:58:37.000000000 +0000
+++ 2.6.24-mm1+/net/ax25/ax25_out.c	2008-02-13 10:43:50.000000000 +0000
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
@@ -251,8 +257,6 @@ void ax25_kick(ax25_cb *ax25)
 	if (start == end)
 		return;
 
-	ax25->vs = start;
-
 	/*
 	 * Transmit data until either we're out of data to send or
 	 * the window is full. Send a poll on the final I frame if
@@ -261,8 +265,13 @@ void ax25_kick(ax25_cb *ax25)
 
 	/*
 	 * Dequeue the frame and copy it.
+	 * Check for race with ax25_clear_queues().
 	 */
 	skb  = skb_dequeue(&ax25->write_queue);
+	if (!skb)
+		return;
+
+	ax25->vs = start;
 
 	do {
 		if ((skbn = skb_clone(skb, GFP_ATOMIC)) == NULL) {
