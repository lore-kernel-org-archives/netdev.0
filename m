From: Peter Kjellstroem <cap@nsc.liu.se>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Fri, 21 Jan 2005 08:41:08 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0501210825360.25351-100000@papput.nsc.liu.se>
References: <468F3FDA28AA87429AD807992E22D07E037ED6A3@orsmsx408>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <sfeldma@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E037ED6A3@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Venkatesan, Ganesh wrote:
> Hi Peter:
>
> Thanks for the thorough analysis. I will have to perform a set of tests
> with your patch included in our latest version of the driver. I will
> respond to you after I am done with my tests.
>
> Ganesh.

Hello,

*waking up ooold thread*

I've done some more testing with the patch discussed in this thread, 
rediffed for newer kernels and fixed the oubvious typo. The fix has been 
extensively tested on two kernels (RHEL-2.4.20-20 and 2.4.28 from 
kernel.org) and two types of hardware (Dell 750 and Supermircro P4SCi).

Further, the original fix (taken out in 2.4.27-pre1) was for all 82547 
(which didn't work that well for Scott I think) while this is only for 
rev2 (82547GI). Worth to notice is that this fix is for non-NAPI cases. 
With NAPI the problem persists and I don't know how to implement an 
equivalent fix.

Lastly, to repeat some background, we allways have to run e1000 with 
InterruptThrottleRate=0 to get resonable cluster performance (MPI). This 
is not possible with 82547 without this patch (it feels bad and keeps 
resetting (netdev watchdog timeout reset ... something...)).

Here follows patches against 2.4.29 and 2.6.10. I have not tested it with 
2.6.x but it's really driver local and should not care about the kernel 
version.

Regards,
 Peter

--- linux-2.4.29/drivers/net/e1000/e1000_main.c Thu Jan 20 19:57:29 2005
+++ linux-2.4.29-patched/drivers/net/e1000/e1000_main.c Fri Jan 21 00:00:19 2005
@@ -2132,10 +2132,19 @@ e1000_intr(int irq, void *data, struct p
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
+       if(hw->mac_type == e1000_82547_rev_2)
+               e1000_irq_enable(adapter);
 #endif

        return IRQ_HANDLED;









--- linux-2.6.10/drivers/net/e1000/e1000_main.c Fri Dec 24 22:35:50 2004
+++ linux-2.6.10-patched/drivers/net/e1000/e1000_main.c Fri Jan 21 00:01:34 2005
@@ -2139,10 +2139,19 @@ e1000_intr(int irq, void *data, struct p
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
+       if(hw->mac_type == e1000_82547_rev_2)
+               e1000_irq_enable(adapter);
 #endif

        return IRQ_HANDLED;



-- 
------------------------------------------------------------
  Peter Kjellstroem              | E-mail: cap@nsc.liu.se
  National Supercomputer Centre  |
  Sweden                         | http://www.nsc.liu.se
