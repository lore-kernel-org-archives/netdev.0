From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Mon, 2 Nov 2009 16:26:21 -0800
Message-ID: <9929d2390911021626j4a2e4a96neaba49ffd8775dc9@mail.gmail.com>
References: <4AEC05E8.40600@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, davem@davemloft.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, svaidy@linux.vnet.ibm.com,
	e1000-devel@lists.sourceforge.net
To: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:49895 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbZKCA0Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 19:26:16 -0500
Received: by pwj9 with SMTP id 9so2178962pwj.21
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 16:26:21 -0800 (PST)
In-Reply-To: <4AEC05E8.40600@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/10/31 Naohiro Ooiwa <nooiwa@miraclelinux.com>:
> Hi All
>
> I resend my patch.
> Sorry, my previous mail lacked an explanation.
>
>
> The e1000 driver doesn't let the power down when running ifdown comma=
nd.
> So, I set to the D3hot state of a PCI device at the end of e1000_clos=
e().
>
> With this modification, e1000 driver reduces power by ifdown.
> It's about 6 watts when I measured a total power of one server machin=
e
> in my environment.
>
> I tested this patch. The result is good enough to me.
>
> Could you please check my patch ?
> If I should have other considerations, please tell me.
>
>
> Thanks you.
> Naohiro Ooiwa
>
>
>
> Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
> ---
> =C2=A0drivers/net/e1000/e1000_main.c | =C2=A0 32 ++++++++++++++++++++=
++++++++++++
> =C2=A01 files changed, 32 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000=
_main.c
> index bcd192c..12e1a42 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -26,6 +26,11 @@
>
> =C2=A0***************************************************************=
****************/
>
> +/*
> + * define this if you want pci save power while ifdown.
> + */
> +#define E1000_PCI_POWER_SAVE
> +
> =C2=A0#include "e1000.h"
> =C2=A0#include <net/ip6_checksum.h>
>
> @@ -1248,6 +1253,23 @@ static int e1000_open(struct net_device *netde=
v)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_hw *hw =3D &adapter->hw;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>
> +#ifdef E1000_PCI_POWER_SAVE
> + =C2=A0 =C2=A0 =C2=A0 struct pci_dev *pdev =3D adapter->pdev;
> +
> + =C2=A0 =C2=A0 =C2=A0 pci_set_power_state(pdev, PCI_D0);
> + =C2=A0 =C2=A0 =C2=A0 pci_restore_state(pdev);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (adapter->need_ioport)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable=
_device(pdev);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable=
_device_mem(pdev);
> + =C2=A0 =C2=A0 =C2=A0 if (err) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR "e=
1000: Cannot enable PCI device from power-save\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return err;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 pci_set_master(pdev);
> +#endif
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* disallow open during test */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (test_bit(__E1000_TESTING, &adapter->fl=
ags))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EBUSY;
> @@ -1265,6 +1287,7 @@ static int e1000_open(struct net_device *netdev=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_setup=
_rx;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_power_up_phy(adapter);
> + =C2=A0 =C2=A0 =C2=A0 e1000_reset(adapter);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->mng_vlan_id =3D E1000_MNG_VLAN_NO=
NE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((hw->mng_cookie.status &
> @@ -1341,6 +1364,15 @@ static int e1000_close(struct net_device *netd=
ev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_vlan_rx_=
kill_vid(netdev, adapter->mng_vlan_id);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> +#ifdef E1000_PCI_POWER_SAVE
> +#ifdef CONFIG_PM
> + =C2=A0 =C2=A0 =C2=A0 pci_save_state(adapter->pdev);
> +#endif
> + =C2=A0 =C2=A0 =C2=A0 pci_disable_device(adapter->pdev);
> + =C2=A0 =C2=A0 =C2=A0 pci_wake_from_d3(adapter->pdev, true);
> + =C2=A0 =C2=A0 =C2=A0 pci_set_power_state(adapter->pdev, PCI_D3hot);
> +#endif
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>

I have added this patch to my tree for testing.  This patch requires a
fair amount of regression testing, so once its passed testing I will
push the patch to David/netdev.

--=20
Cheers,
Jeff
