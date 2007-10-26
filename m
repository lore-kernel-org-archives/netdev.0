From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.24-rc1 fails with lockup - /sbin/ifconfig / inet_ioctl() /
 dev_close() / rtl8169_down()
Date: Fri, 26 Oct 2007 09:48:33 -0700
Message-ID: <20071026094833.539a69aa@freepuppy.rosehill>
References: <alpine.LFD.0.999.0710232057080.30120@woody.linux-foundation.org>
	<1193232344.32208.0.camel@localhost>
	<20071024142759.GA13657@elte.hu>
	<1193241191.14314.8.camel@localhost>
	<20071024155521.GA16690@elte.hu>
	<1193242267.6914.6.camel@twins>
	<1193378269.17910.4.camel@localhost>
	<20071026063733.GA12426@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Romano Giannetti <romanol@upcomillas.es>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50795 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049AbXJZQt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 12:49:57 -0400
In-Reply-To: <20071026063733.GA12426@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Oct 2007 08:37:33 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Romano Giannetti <romanol@upcomillas.es> wrote:
> 
> > > Does this help?
> > 
> > I tried this, but although I have the D-state processes, I cannot see 
> > any debug trace now. Results are at:
> > 
> > http://www.dea.icai.upcomillas.es/romano/linux/info/2624rc1_3/
> > 
> > Can I try anything more? This is quite a show-stopper for me... and 
> > before trying to bisect 11Mbyte of patches...
> 
> hm, from your log it appears that lockdep did not find anything, still 
> the hang does trigger.
> 
> it's /sbin/ifconfig and inet_ioctl() / dev_close() / rtl8169_down() that 
> seems to be hanging. I've extracted the relevant backtrace below. I've 
> Cc:-ed people who might have a better idea about what's going on.
> 
> 	Ingo

Are you building with NAPI enabled or not. Looks like the following
might help the non-napi case.

--- a/drivers/net/r8169.c	2007-10-24 21:38:43.000000000 -0700
+++ b/drivers/net/r8169.c	2007-10-26 09:46:07.000000000 -0700
@@ -2989,13 +2989,16 @@ static void rtl8169_down(struct net_devi
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int poll_locked = 0;
 	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_R8169_NAPI
+	napi_disable(&tp->napi);
+#endif
+
 core_down:
 	spin_lock_irq(&tp->lock);
 
@@ -3009,11 +3012,6 @@ core_down:
 
 	synchronize_irq(dev->irq);
 
-	if (!poll_locked) {
-		napi_disable(&tp->napi);
-		poll_locked++;
-	}
-
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
 




-- 
Stephen Hemminger <shemminger@linux-foundation.org>
