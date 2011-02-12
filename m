From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-26 4/5] cxgb4vf: Quiesce Virtual Interfaces on
 shutdown ...
Date: Fri, 11 Feb 2011 23:17:55 -0800
Message-ID: <F12A7E83-6F8D-4558-A7B5-174D9509891C@qlogic.com>
References: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
 <1297472423-15672-5-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:18087
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751355Ab1BLHSw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Feb 2011 02:18:52 -0500
In-Reply-To: <1297472423-15672-5-git-send-email-leedom@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 11, 2011, at 5:00 PM, Casey Leedom wrote:

> When a Virtual Machine is rebooted, KVM currently fails to issue a Function
> Level Reset against any "Attached PCI Devices" (AKA "PCI Passthrough").  In
> addition to leaving the attached device in a random state in the next booted
> kernel (which sort of violates the entire idea of a reboot reseting hardware
> state), this leaves our peer thinking that the link is still up.  (Note that
> a bug has been filed with the KVM folks, #25332, but there's been no
> response on that as of yet.)  So, we add a "->shutdown()" method for the
> Virtual Function PCI Device to handle administrative shutdowns like a
> reboot.
>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> ---
> drivers/net/cxgb4vf/cxgb4vf_main.c |   41 ++++++++++++++++++++++++++++++++++++
> 1 files changed, 41 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
> index daac6ed..f78d6e1 100644
> --- a/drivers/net/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
> @@ -2886,6 +2886,46 @@ static void __devexit cxgb4vf_pci_remove(struct pci_dev *pdev)
> }
>
> /*
> + * "Shutdown" quiesce the device, stopping Ingress Packet and Interrupt
> + * delivery.
> + */
> +static void __devexit cxgb4vf_pci_shutdown(struct pci_dev *pdev)
> +{
> +     struct adapter *adapter;
> +     int pidx;
> +
> +     adapter = pci_get_drvdata(pdev);
> +     if (!adapter)
> +             return;
> +
> +     /*
> +      * Disable all Virtual Interfaces.  This will shut down the
> +      * delivery of all ingress packets into the chip for these
> +      * Virtual Interfaces.
> +      */
> +     for_each_port(adapter, pidx) {
> +             struct net_device *netdev;
> +             struct port_info *pi;
> +
> +             if (!test_bit(pidx, &adapter->registered_device_map))
> +                     continue;
> +
> +             netdev = adapter->port[pidx];
> +             if (!netdev)
> +                     continue;
> +
> +             pi = netdev_priv(netdev);
> +             t4vf_enable_vi(adapter, pi->viid, false, false);
> +     }
> +
> +     /*
> +      * Free up all Queues which will prevent further DMA and
> +      * Interrupts allowing various internal pathways to drain.
> +      */
> +     t4vf_free_sge_resources(adapter);
> +}
> +
> +/*
>  * PCI Device registration data structures.
>  */
> #define CH_DEVICE(devid, idx) \
> @@ -2918,6 +2958,7 @@ static struct pci_driver cxgb4vf_driver = {
>       .id_table       = cxgb4vf_pci_tbl,
>       .probe          = cxgb4vf_pci_probe,
>       .remove         = __devexit_p(cxgb4vf_pci_remove),
> +     .shutdown       = __devexit_p(cxgb4vf_pci_shutdown),
> };
>
> /*
> --
> 1.7.0.4


You could invoke pci_reset_function as an alternative, that would make sure FLR happens.

-Anirban


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

