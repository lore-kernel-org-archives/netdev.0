From: Bruce Cole <bacole@gmail.com>
Subject: Re: [RFT] r8169 changes against 2.6.23-rc3
Date: Tue, 21 Aug 2007 22:51:50 -0700
Message-ID: <46CBCEF6.5080806@gmail.com>
References: <46CB3DE4.4060107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Gundersen <gundy@iinet.net.au>, bacole@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.228]:42726 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbXHVFxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 01:53:47 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1101860qbe
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 22:53:46 -0700 (PDT)
In-Reply-To: <46CB3DE4.4060107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So I did some experimenting with locking, but eventually found that this 
chunk:

@@ -2677,10 +2681,18 @@ static void rtl8169_tx_interrupt(struct 
net_device *dev,

     if (tp->dirty_tx != dirty_tx) {
         tp->dirty_tx = dirty_tx;
- -        smp_wmb();
- -        if (netif_queue_stopped(dev) &&
- -            (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
- -            netif_wake_queue(dev);
+        smp_mb();
+        if (unlikely(netif_queue_stopped(dev))) {
+            netif_tx_lock(dev);
+                if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+                netif_wake_queue(dev);
+            if (dirty_tx != tp->cur_tx)
+                RTL_W8(TxPoll, NPQ);
+            netif_tx_unlock(dev);
+        } else if (dirty_tx != tp->cur_tx) {
+            netif_tx_lock(dev);
+            RTL_W8(TxPoll, NPQ);
+            netif_tx_unlock(dev);
         }
     }
 }

from the patch in http://www.spinics.net/lists/netdev/msg33960.html
was sufficient to fix the stuck TX queue bug without the busy-wait.  
Actually
just the else portion of the above chunk was sufficient in my testing, 
without
the barrier change or the if statement change.

David Gundersen pointed me to this potential fix days ago, but I didn't
consider it first since the change had (presumably intentionally) been 
dropped from
the set of diffs Francois pointed me to.  Given that I had reported the same
problem as David Gundersen (and Dirk, and other samba users...) I 
thought this
patch had been ruled out.  Apparently not.  Hopefully this can be dusted off
and made into a fairly high priority fix as it has been biting realtek users
since last year at least.

