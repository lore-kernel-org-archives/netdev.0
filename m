From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: RE: PROBLEM: [x86] Running ptpd2 using an Intel 82572EI (e1000e)
 leads to a kernel oops (3.12.26)
Date: Wed, 6 Aug 2014 13:25:11 +0000
Message-ID: <4ad0764f38504a98a272dab1f0ac704f@FE-MBX1012.de.bosch.com>
References: <50f83e65cecd4882b22887858bfdf484@FE-MBX1012.de.bosch.com>
	<CAPDOMVieG6RoOyQM1JG5vCQ1qSgqz-cy37X9GPnkzPUTyRBFBA@mail.gmail.com>
	<ff2e6995521f40268c42d09e92cfe627@FE-MBX1012.de.bosch.com>
	<CAPDOMVgFA-jTL=iDD2vLzPHrsO_=qsupAebTSUm0k0VmmHvX6A@mail.gmail.com>
	<d7c17267f87c4e64a1559fa706cf1ead@FE-MBX1012.de.bosch.com>
 <CAPDOMVjWO9rfZjnHOgK+yB-3MVkmVz_00piBgnDFdf6j=56+GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPDOMVjWO9rfZjnHOgK+yB-3MVkmVz_00piBgnDFdf6j=56+GA@mail.gmail.com>
Content-Language: de-DE
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Nick Krause [mailto:xerofoify@gmail.com]
> Sent: Wednesday, August 06, 2014 2:37 PM
> To: Koehrer Mathias (ETAS/ESW5)
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: PROBLEM: [x86] Running ptpd2 using an Intel 82572EI (e1000e) leads
> to a kernel oops (3.12.26)
> 
> On Wed, Aug 6, 2014 at 8:17 AM, Koehrer Mathias (ETAS/ESW5)
> <mathias.koehrer@etas.com> wrote:
> >> Mathias ,
> >> After tracing this it seems to be either one of two things based on
> >> the warn on messages in
> >> __queue_work. Normally it would be because of this line.
> >> WARN_ON_ONCE(!irqs_disabled());.
> >> However it would also be the second warn on, If you want I can send a
> >> simple patch with
> >> a printk statement to see which one it is.
> >> Regards Nick
> > That would be helpful. I can try to see what's happening.
> >
> > Regards
> >
> > Mathias
> Sorry for the late reply but couldn't figure out how to print the flags.
> Cheers Nick
Hi Nick,
thanks for the patch.
I applied it, however there was no change at all in the output.

My impression is, that it has to do with the network driver as everything works fine if I am using a different NIC.

When I apply the patch

Index: linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c
===================================================================
--- linux-3.12.26.orig/drivers/net/ethernet/intel/e1000e/netdev.c       2014-08-04 10:56:56.000000000 +0200
+++ linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c    2014-08-06 15:15:42.000000000 +0200
@@ -5549,7 +5549,8 @@
        count = e1000_tx_map(tx_ring, skb, first, adapter->tx_fifo_limit,
                             nr_frags);
        if (count) {
-               if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+               if ((adapter->flags & FLAG_HAS_HW_TIMESTAMP) &&
+                        unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
                             !adapter->tx_hwtstamp_skb)) {
                        skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
                        tx_flags |= E1000_TX_FLAGS_HWTSTAMP;

to the e1000e driver it seems to work...
This makes sense as the work queue is only created if  "adapter->flags & FLAG_HAS_HW_TIMESTAMP"  is set.
With this NIC this is *not* the case.


Regards

Mathias

-- 
