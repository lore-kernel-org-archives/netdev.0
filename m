From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: slow samba performance
Date: Sun, 9 Sep 2007 17:33:12 +0200
Message-ID: <20070909153312.GA29586@electric-eye.fr.zoreil.com>
References: <ec7e30370709090044m55efbbcl3cb9e9489f2d5e6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Madsen <david.madsen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42255 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757594AbXIIPh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Sep 2007 11:37:27 -0400
Content-Disposition: inline
In-Reply-To: <ec7e30370709090044m55efbbcl3cb9e9489f2d5e6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Madsen <david.madsen@gmail.com> :
> >Does "acceptable" mean that there is a noticeable difference when compared
> >to the patch based on a busy-waiting loop ?
> 
> I noticed a somewhat significant difference between patch #0002 and a
> busy wait loop with ndelay(10). Write performance was equivalent in
> both cases as should be the case.  Read perfomance for me maxed out

Do you have some (gross) figure for the write performance ?

> around 150ish megabit whereas switching to the ndelay(10) loop brought
> up average performance around 350ish megabit while reading the same
> files over samba.

Hardly extatic. :o/

Do you see a difference in the system load too, say a few lines of 'vmstat 1' ?

Can you add the patch below on top of #0002 and see if there is some
benefit from it ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b85ab4a..8d8fff3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2457,6 +2457,7 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	smp_wmb();
 
 	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+	RTL_R8(TxPoll);
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);


I'd welcome if you could try the patch below on top of #0002 too:

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b85ab4a..840df3b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2457,6 +2457,17 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	smp_wmb();
 
 	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+{
+	static unsigned int wait_max = 0;
+	unsigned i;
+
+	for (i = 0; (RTL_R8(TxPoll) & NPQ) && (i < 1000); i++)
+		ndelay(10);
+	if (i > wait_max) {
+		wait_max = i;
+		printk(KERN_INFO "%s: wait_max = %d\n", dev->name, wait_max);
+	}
+}
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);

-- 
Ueimor
