From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: [PATCH 0/4] e1000: fixes for 7.1.9-k2
Date: Fri, 14 Jul 2006 17:15:18 -0700
Message-ID: <9929d2390607141715p4b63afafsc0a981384e1a9e7@mail.gmail.com>
References: <20060714232452.22378.32866.stgit@gitlost.site>
	 <20060715000301.GP6908@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>, nhorman@tuxdriver.com,
	jmoyer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:15420 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1945933AbWGOAPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 20:15:20 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1010160ugc
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 17:15:19 -0700 (PDT)
To: "Matt Mackall" <mpm@selenic.com>
In-Reply-To: <20060715000301.GP6908@waste.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/14/06, Matt Mackall <mpm@selenic.com> wrote:
> On Fri, Jul 14, 2006 at 04:24:52PM -0700, Kok, Auke wrote:
> >
> > Jeff,
> >
> > Please pull the following patches from
> >
> > git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes-jgarzik
> > (based on 22e1170310ec6afa41e0dc7ac9dfac735d82dcab)
> >
> > To receive the following fixes for e1000:
> >
> > [01]: Redo netpoll fix
>
> Have I seen this patch? Is there a way to browse it?
>
> --
> Mathematics is the supreme nostalgia of our time.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Matt,
The patch you are referring to is in patch set emails that Auke sent out.

I have also copied the patch below:

The original suggested fix for netpoll was found to be racy on SMP
kernels. While it is highly unlikely that this race would ever be seen
in the real world due to current netpoll usage models, we implemented
this updated fix to address concerns.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   39 ++++++++++++++++-----------------------
 1 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6d3d419..1c6bcad 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3387,8 +3387,8 @@ e1000_intr(int irq, void *data, struct p
               E1000_WRITE_REG(hw, IMC, ~0);
               E1000_WRITE_FLUSH(hw);
       }
-       if (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0])))
-               __netif_rx_schedule(&adapter->polling_netdev[0]);
+       if (likely(netif_rx_schedule_prep(netdev)))
+               __netif_rx_schedule(netdev);
       else
               e1000_irq_enable(adapter);
 #else
@@ -3431,34 +3431,26 @@ e1000_clean(struct net_device *poll_dev,
 {
       struct e1000_adapter *adapter;
       int work_to_do = min(*budget, poll_dev->quota);
-       int tx_cleaned = 0, i = 0, work_done = 0;
+       int tx_cleaned = 0, work_done = 0;

       /* Must NOT use netdev_priv macro here. */
       adapter = poll_dev->priv;

       /* Keep link state information with original netdev */
-       if (!netif_carrier_ok(adapter->netdev))
+       if (!netif_carrier_ok(poll_dev))
               goto quit_polling;

-       while (poll_dev != &adapter->polling_netdev[i]) {
-               i++;
-               BUG_ON(i == adapter->num_rx_queues);
-       }
-
-       if (likely(adapter->num_tx_queues == 1)) {
-               /* e1000_clean is called per-cpu.  This lock protects
-                * tx_ring[0] from being cleaned by multiple cpus
-                * simultaneously.  A failure obtaining the lock means
-                * tx_ring[0] is currently being cleaned anyway. */
-               if (spin_trylock(&adapter->tx_queue_lock)) {
-                       tx_cleaned = e1000_clean_tx_irq(adapter,
-                                                       &adapter->tx_ring[0]);
-                       spin_unlock(&adapter->tx_queue_lock);
-               }
-       } else
-               tx_cleaned = e1000_clean_tx_irq(adapter, &adapter->tx_ring[i]);
+       /* e1000_clean is called per-cpu.  This lock protects
+        * tx_ring[0] from being cleaned by multiple cpus
+        * simultaneously.  A failure obtaining the lock means
+        * tx_ring[0] is currently being cleaned anyway. */
+       if (spin_trylock(&adapter->tx_queue_lock)) {
+               tx_cleaned = e1000_clean_tx_irq(adapter,
+                                               &adapter->tx_ring[0]);
+               spin_unlock(&adapter->tx_queue_lock);
+       }

-       adapter->clean_rx(adapter, &adapter->rx_ring[i],
+       adapter->clean_rx(adapter, &adapter->rx_ring[0],
                         &work_done, work_to_do);

       *budget -= work_done;
@@ -3466,7 +3458,7 @@ e1000_clean(struct net_device *poll_dev,

       /* If no Tx and not enough Rx work done, exit the polling mode */
       if ((!tx_cleaned && (work_done == 0)) ||
-          !netif_running(adapter->netdev)) {
+          !netif_running(poll_dev)) {
 quit_polling:
               netif_rx_complete(poll_dev);
               e1000_irq_enable(adapter);
@@ -4752,6 +4744,7 @@ static void
 e1000_netpoll(struct net_device *netdev)
 {
       struct e1000_adapter *adapter = netdev_priv(netdev);
+
       disable_irq(adapter->pdev->irq);
       e1000_intr(adapter->pdev->irq, netdev, NULL);
       e1000_clean_tx_irq(adapter, adapter->tx_ring);


-- 
Cheers,
Jeff
