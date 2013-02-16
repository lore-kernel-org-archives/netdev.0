From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [net-next 13/15] ixgbe: implement SFF diagnostic monitoring via ethtool
Date: Sat, 16 Feb 2013 11:53:54 +0100
Message-ID: <CAHXqBFKS9hPg23qAeiLjhk1uYk8BR=T+1+pZ1Pb5RcMr44Zs6Q@mail.gmail.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com> <1361003616-3422-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	=?ISO-8859-1?Q?Aur=E9lien_Guillaume?= <footplus@gmail.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f170.google.com ([209.85.210.170]:53615 "EHLO
	mail-ia0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895Ab3BPKyP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 05:54:15 -0500
Received: by mail-ia0-f170.google.com with SMTP id k20so4056008iak.1
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 02:54:15 -0800 (PST)
In-Reply-To: <1361003616-3422-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/16 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> From: Aur=C3=A9lien Guillaume <footplus@gmail.com>
>
> This patch adds support for reading data from SFP+ modules over i2c.
>
> Signed-off-by: Aur=C3=A9lien Guillaume <footplus@gmail.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 114 +++++++++++++=
++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   4 +
>  3 files changed, 119 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/e=
thernet/intel/ixgbe/ixgbe.h
> index b91f9b6..196002b 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -620,6 +620,7 @@ enum ixgbe_state_t {
>         __IXGBE_DOWN,
>         __IXGBE_SERVICE_SCHED,
>         __IXGBE_IN_SFP_INIT,
> +       __IXGBE_READ_I2C,
>  };
>
>  struct ixgbe_cb {
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drive=
rs/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index 7349a8b..e6cebdc 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -39,6 +39,7 @@
>  #include <linux/uaccess.h>
>
>  #include "ixgbe.h"
> +#include "ixgbe_phy.h"
>
>
>  #define IXGBE_ALL_RAR_ENTRIES 16
> @@ -2839,6 +2840,117 @@ static int ixgbe_set_channels(struct net_devi=
ce *dev,
>         return ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
>  }
>
> +static int ixgbe_get_module_info(struct net_device *dev,
> +                                      struct ethtool_modinfo *modinf=
o)
> +{
> +       struct ixgbe_adapter *adapter =3D netdev_priv(dev);
> +       struct ixgbe_hw *hw =3D &adapter->hw;
> +       u32 status;
> +       u8 sff8472_rev, addr_mode;
> +       int ret_val =3D 0;
> +       bool page_swap =3D false;
> +
> +       /* avoid concurent i2c reads */
> +       while (test_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
> +               msleep(100);
> +
> +       /* used by the service task */
> +       set_bit(__IXGBE_READ_I2C, &adapter->state);

This is racy. Why do you need another bit?

 while (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
       msleep(100);
=2E..
  clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state)

Best Regards,
Micha=C5=82 Miros=C5=82aw
