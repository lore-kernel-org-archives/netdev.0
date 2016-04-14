From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
 (Hyper-V)
Date: Thu, 14 Apr 2016 23:01:18 +0000
Message-ID: <5F69AC74-16B9-4EAD-8B4B-21D2EB6B3653@intel.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-2-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4654833827415300103=="
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "intel-wired-lan@linuxonhyperv.com" <intel-wired-lan@linuxonhyperv.com>,
 netdev <netdev@vger.kernel.org>, "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "jackm@mellanox.com" <jackm@mellanox.com>,
 "yevgenyp@mellanox.com" <yevgenyp@mellanox.com>, "Ronciak,
 John" <john.ronciak@intel.com>, "eli@mellanox.com" <eli@mellanox.com>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460678142-30353-2-git-send-email-kys@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

--===============4654833827415300103==
Content-Language: en-US
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E02FA17C-F4DA-41FD-9C24-8DC56A12A313";
	protocol="application/pgp-signature"; micalg=pgp-sha256

--Apple-Mail=_E02FA17C-F4DA-41FD-9C24-8DC56A12A313
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Some comments below:

K. Y. Srinivasan <kys@microsoft.com> wrote:

> On Hyper-V, the VF/PF communication is a via software mediated path
> as opposed to the hardware mailbox. Make the necessary
> adjustments to support Hyper-V.
>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   11 ++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   56 ++++++---
>  drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           |  138 +++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
>  5 files changed, 201 insertions(+), 18 deletions(-)

<snip>

> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c  
> b/drivers/net/ethernet/intel/ixgbevf/vf.c
> index 4d613a4..92397fd 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c

<snip>

> @@ -126,6 +133,23 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
>  }
>
>  /**
> + * Hyper-V variant; the VF/PF communication is through the PCI
> + * config space.
> + */
> +static s32 ixgbevf_hv_reset_hw_vf(struct ixgbe_hw *hw)
> +{
> +	int i;
> +	struct ixgbevf_adapter *adapter = hw->back;

The two lines above should be swapped so that the longer one is first.

> +
> +	for (i = 0; i < 6; i++)
> +		pci_read_config_byte(adapter->pdev,
> +				     (i + IXGBE_HV_RESET_OFFSET),
> +				     &hw->mac.perm_addr[i]);
> +
> +	return 0;
> +}
> +
> +/**
>   *  ixgbevf_stop_hw_vf - Generic stop Tx/Rx units
>   *  @hw: pointer to hardware structure
>   *
> @@ -656,6 +680,68 @@ out:
>  }
>
>  /**
> + * Hyper-V variant; there is no mailbox communication.
> + */
> +static s32 ixgbevf_hv_check_mac_link_vf(struct ixgbe_hw *hw,
> +					ixgbe_link_speed *speed,
> +					bool *link_up,
> +					bool autoneg_wait_to_complete)
> +{
> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
> +	struct ixgbe_mac_info *mac = &hw->mac;
> +	s32 ret_val = 0;

ret_val here is redundant as this is the only assignment to it.
Please delete it and just return 0 at the end.

> +	u32 links_reg;
> +
> +	/* If we were hit with a reset drop the link */
> +	if (!mbx->ops.check_for_rst(hw) || !mbx->timeout)
> +		mac->get_link_status = true;
> +
> +	if (!mac->get_link_status)
> +		goto out;
> +
> +	/* if link status is down no point in checking to see if pf is up */
> +	links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
> +	if (!(links_reg & IXGBE_LINKS_UP))
> +		goto out;
> +
> +	/* for SFP+ modules and DA cables on 82599 it can take up to 500usecs
> +	 * before the link status is correct
> +	 */
> +	if (mac->type == ixgbe_mac_82599_vf) {
> +		int i;
> +
> +		for (i = 0; i < 5; i++) {
> +			udelay(100);
> +			links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
> +
> +			if (!(links_reg & IXGBE_LINKS_UP))
> +				goto out;
> +		}
> +	}
> +
> +	switch (links_reg & IXGBE_LINKS_SPEED_82599) {
> +	case IXGBE_LINKS_SPEED_10G_82599:
> +		*speed = IXGBE_LINK_SPEED_10GB_FULL;
> +		break;
> +	case IXGBE_LINKS_SPEED_1G_82599:
> +		*speed = IXGBE_LINK_SPEED_1GB_FULL;
> +		break;
> +	case IXGBE_LINKS_SPEED_100_82599:
> +		*speed = IXGBE_LINK_SPEED_100_FULL;
> +		break;
> +	}
> +
> +	/* if we passed all the tests above then the link is up and we no
> +	 * longer need to check for link
> +	 */
> +	mac->get_link_status = false;
> +
> +out:
> +	*link_up = !mac->get_link_status;
> +	return ret_val;

Just return 0 above.

> +}
> +
> +/**
>   *  ixgbevf_rlpml_set_vf - Set the maximum receive packet length
>   *  @hw: pointer to the HW structure
>   *  @max_size: value to assign to max frame size

<snip>

> @@ -663,6 +749,19 @@ out:
>  void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size)
>  {
>  	u32 msgbuf[2];
> +	u32 reg;
> +
> +	if (x86_hyper == &x86_hyper_ms_hyperv) {
> +		/*
> +		 * If we are on Hyper-V, we implement

Please format the comment above netdev-style, /* If we are...
as you did elsewhere.

> +		 * this functionality differently.
> +		 */
> +		reg =  IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(0));
> +		/* CRC == 4 */
> +		reg |= ((max_size + 4) | IXGBE_RXDCTL_RLPML_EN);
> +		IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(0), reg);
> +		return;
> +	}
>
>  	msgbuf[0] = IXGBE_VF_SET_LPE;
>  	msgbuf[1] = max_size;
> @@ -679,6 +778,16 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw  
> *hw, int api)
>  	int err;
>  	u32 msg[3];
>
> +	if (x86_hyper == &x86_hyper_ms_hyperv) {
> +		/*
> +		 * Hyper-V only supports api version ixgbe_mbox_api_10

Again, please use netdev-style comment above.

> +		 */
> +		if (api != ixgbe_mbox_api_10)
> +			return IXGBE_ERR_INVALID_ARGUMENT;
> +
> +		return 0;
> +	}
> +
>  	/* Negotiate the mailbox API version */
>  	msg[0] = IXGBE_VF_API_NEGOTIATE;
>  	msg[1] = api;
> @@ -776,22 +885,51 @@ static const struct ixgbe_mac_operations  
> ixgbevf_mac_ops = {
>  	.set_vfta		= ixgbevf_set_vfta_vf,
>  };
>
> +static const struct ixgbe_mac_operations ixgbevf_hv_mac_ops = {
> +	.init_hw		= ixgbevf_init_hw_vf,
> +	.reset_hw		= ixgbevf_hv_reset_hw_vf,
> +	.start_hw		= ixgbevf_start_hw_vf,
> +	.get_mac_addr		= ixgbevf_get_mac_addr_vf,
> +	.stop_adapter		= ixgbevf_stop_hw_vf,
> +	.setup_link		= ixgbevf_setup_mac_link_vf,
> +	.check_link		= ixgbevf_hv_check_mac_link_vf,
> +};

Please add a blank line between these two structures as you have
done elsewhere.

>  const struct ixgbevf_info ixgbevf_82599_vf_info = {
>  	.mac = ixgbe_mac_82599_vf,
>  	.mac_ops = &ixgbevf_mac_ops,
>  };
>
> +const struct ixgbevf_info ixgbevf_82599_vf_hv_info = {
> +	.mac = ixgbe_mac_82599_vf,
> +	.mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
>  const struct ixgbevf_info ixgbevf_X540_vf_info = {
>  	.mac = ixgbe_mac_X540_vf,
>  	.mac_ops = &ixgbevf_mac_ops,
>  };
>
> +const struct ixgbevf_info ixgbevf_X540_vf_hv_info = {
> +	.mac = ixgbe_mac_X540_vf,
> +	.mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
>  const struct ixgbevf_info ixgbevf_X550_vf_info = {
>  	.mac = ixgbe_mac_X550_vf,
>  	.mac_ops = &ixgbevf_mac_ops,
>  };
>
> +const struct ixgbevf_info ixgbevf_X550_vf_hv_info = {
> +	.mac = ixgbe_mac_X550_vf,
> +	.mac_ops = &ixgbevf_hv_mac_ops,
> +};
> +
>  const struct ixgbevf_info ixgbevf_X550EM_x_vf_info = {
>  	.mac = ixgbe_mac_X550EM_x_vf,
>  	.mac_ops = &ixgbevf_mac_ops,
>  };
> +
> +const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info = {
> +	.mac = ixgbe_mac_X550EM_x_vf,
> +	.mac_ops = &ixgbevf_hv_mac_ops,
> +};
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h  
> b/drivers/net/ethernet/intel/ixgbevf/vf.h
> index ef9f773..7242a97 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
> @@ -32,7 +32,9 @@
>  #include <linux/interrupt.h>
>  #include <linux/if_ether.h>
>  #include <linux/netdevice.h>
> +#include <asm/hypervisor.h>
>
> +#include <asm/hypervisor.h>

Surely you didn't mean to include the same file twice!

>  #include "defines.h"
>  #include "regs.h"
>  #include "mbx.h"

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_E02FA17C-F4DA-41FD-9C24-8DC56A12A313
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJXECE9AAoJEDwO/+eO4+5ur+0P/AypfPXKuHxSkCr6T6JXxM+u
Z7xcHHftvIyfYD+KtTSh4JLxxL38NZNWMBMlR2zWGyKhNnn3Rx+hBTR3d1Xyvfzp
iw9hPDVGpknTNC4Wlmzj8WupvWHlXuXdVCPIZVLwSCv/BJ+x/DkWE/B2FnV78Feb
5Vf5gXUS99nLiqWG3M+Vnh9nQB+beuh6x0umMr22YcbgXhY4wjcl5zqru/++Jt19
jYOSAFKK+01D9oSqQFqs9/KkfJRLybaT3zLV/U1aLJRHjEYpxfQtN0e6rjHbnz4J
+iSxK5phxiBFyiZjG/VKduVfSfhluPC/tLgSCBpIjwFhaWI24heIA9BiSVqJbINi
DFdIv7FfzafM+8wtbxl6jCz9Nc8w7ghXct4agXpiXDvc5vE/AmvmTuJWb/ng7m+v
3QXS9hjeqmLB8jUCB1KlEIXpnt1XiFPE3xsk8NpK1clQy+F4B+AgIq8KQ2hdCIZg
+XoTNqqjpTs3GFTv5guJXdobxcqUuQiHqVvULclE5+odLUR4JGY6/b0D9fXrO8Ir
LDCx4YlS0Zh75PgmioUg4e/qemjMukirFQAW59Ci8ztoWvuR0HRRx1xU4QzmA0zm
DvZ0ltytqIxjzQIUrCIoxkJ+SDnu0jJJYKJ4QKoOp195hbVfVvkaxSSeQw/RyItD
9KkfITzmqLmpAMwNjOXU
=fPYh
-----END PGP SIGNATURE-----

--Apple-Mail=_E02FA17C-F4DA-41FD-9C24-8DC56A12A313--

--===============4654833827415300103==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============4654833827415300103==--
