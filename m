From: Peter Kjellstroem <cap@nsc.liu.se>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sun, 5 Dec 2004 22:52:18 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0412052249470.13794-100000@papput.nsc.liu.se>
References: <Pine.LNX.4.44.0412052230410.13794-100000@papput.nsc.liu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
In-Reply-To: <Pine.LNX.4.44.0412052230410.13794-100000@papput.nsc.liu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Peter Kjellstroem wrote:

> On Sun, 5 Dec 2004, Scott Feldman wrote:
> 
> > On Sun, 2004-12-05 at 06:04, Peter Kjellstroem wrote:
> > >  *
> > >  * 5.2.39       3/12/04
> > >  * ...
> > >  *   o Back out the CSA fix for 82547 as it continues to cause
> > >  *     systems lock-ups with production systems.
> > 
> 
> Yes I found that out and verified it earlier today. The fix in question is 
> basically if'ed irq_enable/disable around a small chunk of code like this:
> 
>         if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
>                 e1000_irq_disable(adapter);
> 
> this is the original fix and triggers for both e1000_82547 (your 547EI 
> right?) and e1000_82547_rev_2 (my 547GI). If your NIC can't stand the fix 
> and mine needs it isn't the obvious solution the following?
> 
>         if(hw->mac_type == e1000_82547_rev_2)
>                 e1000_irq_disable(adapter);
> 

And here's a trivial patch for it (against 2.4.28):

/Peter


--- linux-2.4.28-cap1p/drivers/net/e1000/e1000_main.c   Wed Nov 17 12:54:21 2004
+++ linux-2.4.28-cap5p/drivers/net/e1000/e1000_main.c   Sun Dec  5 22:47:57 2004
@@ -2124,10 +2124,19 @@ e1000_intr(int irq, void *data, struct p
                __netif_rx_schedule(netdev);
        }
 #else
+       /* e1000_irq_disable/enable pair added back (removed in 2.4.27-pre1) */
+       /* fixed needed for 82547GI (e1000_82547_rev_2) Dell 750, P4SCi */
+       /* reliable operation with ITR=0 */
+       if(hw->mac_type == e1000_82547_rev_2)
+               e1000_irq_disable(adapter);
+
        for(i = 0; i < E1000_MAX_INTR; i++)
                if(unlikely(!e1000_clean_rx_irq(adapter) &
                   !e1000_clean_tx_irq(adapter)))
                        break;
+
+       if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+               e1000_irq_enable(adapter);
 #endif
 
        return IRQ_HANDLED;
