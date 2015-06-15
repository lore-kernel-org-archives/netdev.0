From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH] ethernet/sfc: mark state UNINIT after unregister
Date: Mon, 15 Jun 2015 14:49:18 +0100
Message-ID: <557ED7DE.7080407@solarflare.com>
References: <1434135061-42521-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:50462 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752139AbbFONtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 09:49:24 -0400
In-Reply-To: <1434135061-42521-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/15 19:51, Jarod Wilson wrote:
> Without this change, modprobe -r sfc hits the BUG_ON() in
> efx_pci_remove_main(). Best as I can tell, this was just an oversight,
> efx->state gets set to STATE_UNINIT in the error path of
> efx_register_netdev() just after unregister_netdevice(), and the same
> should happen in efx_unregister_netdev() after its unregister_netdevice()
> call. Now I can load and unload no problem.
>
> CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  drivers/net/ethernet/sfc/efx.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index 0c42ed9..f3eaade 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -2448,6 +2448,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
>  #endif
>  		device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
>  		unregister_netdev(efx->net_dev);
> +		efx->state = STATE_UNINIT;
>  	}
>  }
>  
This isn't quite the right place, efx->state changes are supposed to be serialised by the RTNL lock.
Our out-of-tree driver has this in efx_pci_remove, just after the efx_disable_interrupts(efx) call and before rtnl_unlock() (see patch below).  I'd suggest that's the change we should make, but I haven't tested it yet.

For reference, the "oversight" was in my e7fef9b45ae188066bb6eb3dde8310d33c2f7d5e "sfc: add sysfs entry to control MCDI tracing" which accidentally took our out-of-tree version of efx_unregister_netdev().  Before that the code was as in Jarod's patch.

-Ed

----8<----

sfc: mark state UNINIT after unregister

Without this change, modprobe -r sfc hits the BUG_ON() in
efx_pci_remove_main().

Reported-by: Jarod Wilson <jarod@redhat.com>
Fixes: e7fef9b45ae188066bb6eb3dde8310d33c2f7d5e
---
 drivers/net/ethernet/sfc/efx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0c42ed9..67bdaf3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2920,6 +2920,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
     efx_dissociate(efx);
     dev_close(efx->net_dev);
     efx_disable_interrupts(efx);
+    efx->state = STATE_UNINIT;
     rtnl_unlock();
 
     if (efx->type->sriov_fini)
