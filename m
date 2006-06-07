From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 07 Jun 2006 11:25:29 -0700
Message-ID: <44871A19.7080805@intel.com>
References: <20060605231125.12584.17039.stgit@gitlost.site> <20060606135217.GA21969@hmsreliant.homelinux.net> <1149611965.13635.19.camel@strongmad> <20060606170513.GB21969@hmsreliant.homelinux.net> <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040100080706090100030202"
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:6547 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751072AbWFGSaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 14:30:14 -0400
To: Matt Mackall <mpm@selenic.com>, "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060607164801.GX24227@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040100080706090100030202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Matt Mackall wrote:
> On Wed, Jun 07, 2006 at 11:05:22AM -0400, Neil Horman wrote:
>>>  
>>>> Matt, any ideas on this?
>>> Not at the moment.
>> how about this for a solution?  It doesn't make netpoll any more robust, but I
>> think in the interests of efficiency it would be fair to require that, when
>> netpolled, a driver must receive frames on the same net device for which it was
>> polled.  With this patch we detect that condition and handle it accordingly in
>> e1000_intr.  This eliminates the need for us to call the clean_rx method from
>> the poll_controller when napi is configured, instead allowing the poll method to
>> be called from napi_poll, as the netpoll model currently does.  This fixes the
>> netdump regression, and eliminates the layering violation and the potential race
>> that we've been discussing.  I've just tested it with netdump here and it works
>> quite well.
>>
>> Thoughts appreciated.
> 
> This looks pretty reasonable, mostly from the perspective that it
> doesn't put any further ugliness in netpoll. We might want to add a
> comment somewhere in netpoll of the new rule we're now observing.
> I'll let the e1000 guys comment on the particulars of the driver change.

Hi,

we're not too happy with this as it puts a branch right in the regular receive 
path. We haven't ran the numbers on it yet but it is likely that this will 
lower performance significantly during normal receives for something that is 
not common use.

Attached below a (revised) patch that adds proper locking around the rx_clean 
to prevent the race.

Cheers,

Auke

---

e1000: fix netpoll with NAPI

This fixes netpoll when using NAPI, and protects against a rare race condition
in the netpoll routine, while staying out of our ways from the normal hotpath.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---
  e1000_main.c |   17 ++++++++++++++++-
  1 file changed, 16 insertions(+), 1 deletion(-)


--------------040100080706090100030202
Content-Type: text/x-patch;
 name="e1000_netpoll_napi-r2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_netpoll_napi-r2.patch"

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index bd709e5..876251c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4584,10 +4584,25 @@ static void
 e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_E1000_NAPI
+	int budget = 0;
+
+	disable_irq(adapter->pdev->irq);
+	if (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0]))) {
+		if (spin_trylock(&adapter->tx_queue_lock)) {
+			e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
+			spin_unlock(&adapter->tx_queue_lock);
+		}
+		adapter->clean_rx(adapter, adapter->rx_ring,
+				&budget, netdev->weight);
+		clear_bit(__LINK_STATE_RX_SCHED,
+				&adapter->polling_netdev[0].state);
+	}
+#else
+
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev, NULL);
 	e1000_clean_tx_irq(adapter, adapter->tx_ring);
-#ifndef CONFIG_E1000_NAPI
 	adapter->clean_rx(adapter, adapter->rx_ring);
 #endif
 	enable_irq(adapter->pdev->irq);

--------------040100080706090100030202--
