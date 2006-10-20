From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e100_shutdown: netif_poll_disable hang
Date: Fri, 20 Oct 2006 13:51:44 -0700
Message-ID: <453936E0.1010204@intel.com>
References: <20061020182820.978932000@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26235 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1946497AbWJTUxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 16:53:37 -0400
To: Daniel Walker <dwalker@mvista.com>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061020182820.978932000@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Walker wrote:
> My machine annoyingly hangs while rebooting. I tracked it down
> to e100-fix-reboot-f-with-netconsole-enabled.patch in 2.6.18-rc2-mm2
> 
> I review the changes and it seemed to be calling netif_poll_disable
> one too many time. Once in e100_down(), and again in e100_shutdown().
> 
> The second one in e100_shutdown() caused the hang. So this patch
> removes it. 
> 
> Signed-Off-By: Daniel Walker <dwalker@mvista.com>
> 
> ---
>  drivers/net/e100.c |    1 -
>  1 files changed, 1 deletion(-)
> 
> Index: linux-2.6.18/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.18.orig/drivers/net/e100.c
> +++ linux-2.6.18/drivers/net/e100.c
> @@ -2709,7 +2709,6 @@ static void e100_shutdown(struct pci_dev
>  	struct net_device *netdev = pci_get_drvdata(pdev);
>  	struct nic *nic = netdev_priv(netdev);
>  
> -	netif_poll_disable(nic->netdev);
>  	del_timer_sync(&nic->watchdog);
>  	netif_carrier_off(nic->netdev);
>  
> --

this won't help netconsole shutdown/reboot -f, probably locking it up again!

NAK

Also missing is the NAPI conditional, which I left out. Also missing is the same code 
for suspend.

Here's a better approach, allowing both normal shutdown code path and reboot -f to 
disable polling.

Cheers,

Auke
---

e100: disable polling only when up during suspend and shutdown

Signed-off-by: Auke Kok <auke-jan.h.kok>
Cc: Daniel Walker <dwalker@mvista.com>
Cc: Andrew Morton <akpm@osdl.org>

---
  drivers/net/e100.c |   10 ++++++++--
  1 file changed, 8 insertions(+), 2 deletions(-)

---
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index d4a2572..815eb29 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2719,7 +2719,10 @@ static int e100_suspend(struct pci_dev *
  	struct net_device *netdev = pci_get_drvdata(pdev);
  	struct nic *nic = netdev_priv(netdev);

-	netif_poll_disable(nic->netdev);
+#ifdef CONFIG_E100_NAPI
+	if (netif_running(netdev))
+		netif_poll_disable(nic->netdev);
+#endif
  	del_timer_sync(&nic->watchdog);
  	netif_carrier_off(nic->netdev);

@@ -2763,7 +2766,10 @@ static void e100_shutdown(struct pci_dev
  	struct net_device *netdev = pci_get_drvdata(pdev);
  	struct nic *nic = netdev_priv(netdev);

-	netif_poll_disable(nic->netdev);
+#ifdef CONFIG_E100_NAPI
+	if (netif_running(netdev))
+		netif_poll_disable(nic->netdev);
+#endif
  	del_timer_sync(&nic->watchdog);
  	netif_carrier_off(nic->netdev);
