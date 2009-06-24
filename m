From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Tue, 23 Jun 2009 20:48:19 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242178EE7807E@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <4A41961B.2090206@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Naohiro Ooiwa'" <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2741 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881AbZFXDsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 23:48:25 -0400
In-Reply-To: <4A41961B.2090206@miraclelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Naohiro Ooiwa wrote:

> Hi Michael
>
> I found a little bug.
>
> When configure in ifcfg-eth* is ONBOOT=no,
> the behavior of ethtool command is wrong.
>
>     # grep ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth2
>     ONBOOT=no
>     # ethtool eth2 | tail -n1
>             Link detected: yes
>
> I think "Link detected" should be "no".
>
> The bnx2 driver should run netif_carrier_off() in initialization
> until bnx2_open() is called.
>
> The following is my patch.
> It move netif_carrier_off() to bnx2_init_one().
> I had already tested this patch. The result is good for me.
>
> Could you please check the my patch ?
>
>
> Best Regards,
> Naohiro Ooiwa
>
>
> Signed-off-by: Naohiro Ooiwa <nooiwa@meriraclelinux.com>

This patch will not work.  Calling netif_carrier_off() will schedule
a link_watch event.  If register_netdev() fails for any reason, the
netdev will be freed but the link_watch event can still be scheduled.

Calling netif_carrier_off() after register_netdev() returns also
will not work because it can then race with ->open() and the interrupt
that indicates link up.

Thanks.

> ---
>  drivers/net/bnx2.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 38f1c33..9eee986 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6151,8 +6151,6 @@ bnx2_open(struct net_device *dev)
>       struct bnx2 *bp = netdev_priv(dev);
>       int rc;
>
> -     netif_carrier_off(dev);
> -
>       bnx2_set_power_state(bp, PCI_D0);
>       bnx2_disable_int(bp);
>
> @@ -8066,6 +8064,9 @@ bnx2_init_one(struct pci_dev *pdev,
> const struct pci_device_id *ent)
>       if (CHIP_NUM(bp) == CHIP_NUM_5709)
>               dev->features |= NETIF_F_TSO6;
>
> +     /* Should set nocarrier until bnx2_open() is called */
> +     netif_carrier_off(dev);
> +
>       if ((rc = register_netdev(dev))) {
>               dev_err(&pdev->dev, "Cannot register net device\n");
>               goto error;
> --
> 1.5.4.1
>
>
>

