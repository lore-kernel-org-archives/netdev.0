From: jc <jchapman@katalix.com>
Subject: RE: [PATCH] make tg3 NAPI support configurable
Date: Thu, 15 Jan 2004 08:01:42 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074153702.400648e62916f@webmail.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: gnb@melbourne.sgi.com, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com, Robert.Olsson@data.slu.se, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I found that testing if any tx work is done in dev->poll before exiting 
polled mode improves performance by about 7% (max) in a 2-port e100 bridge
forwarding unidirectional test case. If tx work is not considered when 
deciding whether to netif_rx_complete, the transmitting interface sees 
loads of interrupts and hence forwarding throughput is degraded. 

When testing with bidirectional test data, no improvement is seen since 
the dev->poll is kept in polled mode on both interfaces due to
receive work.

Hope this helps.

-jc   

> > >  Furthermore NAPI can be extended to schedule dev->poll even for TX-
> > >  interrupts. There is pacth for e1000 doing this. We see about 5-8% 
> > >  overall system packet improvement with this.

> > I was thinking of a variant JC [jchapman@katalix.com]
> > mentioned on this list some time ago. He also sent me
> > the patch for e1000. A test and the patch is below.
> 
> JC contributed almost the exact patch for the e100 rewrite and it did
> help Tx, but I don't remember how much.  JC, do you remember?  Here is
> the snippet:
> 
> static int e100_poll(struct net_device *netdev, int *budget)
> {
>         struct nic *nic = netdev->priv;
>         unsigned int work_to_do = min(netdev->quota, *budget);
>         unsigned int work_done = 0;
>         int tx_cleaned;
> 
>         e100_rx_clean(nic, &work_done, work_to_do);
>         tx_cleaned = e100_tx_clean(nic);
> 
>         /* If no Rx and Tx cleanup work was done, exit polling mode. */
>         if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev))
>         {
>                 netif_rx_complete(netdev);
>                 e100_enable_irq(nic);
>                 return 0;
>         }
> 
>         *budget -= work_done;
>         netdev->quota -= work_done;
> 
>         return 1;
> }
 




-------------------------------------------------
This mail sent through IMP: http://horde.org/imp/
