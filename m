From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 03/18] net: dsa: mv88e6xxx: move VTU Operation
 accessors
Date: Thu, 27 Apr 2017 20:32:49 +0200
Message-ID: <20170427183249.GE17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43665 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965613AbdD0Scw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 14:32:52 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:21AM -0400, Vivien Didelot wrote:
> Move the helper functions to access the Global 1 VTU Operation register
> to a new global1_vtu.c file, and get rid of the old underscore prefix
> naming convention. This file will be extended will all VTU/STU related
> code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/Makefile      |  1 +
>  drivers/net/dsa/mv88e6xxx/chip.c        | 39 +++++++++------------------------
>  drivers/net/dsa/mv88e6xxx/global1.h     |  3 +++
>  drivers/net/dsa/mv88e6xxx/global1_vtu.c | 33 ++++++++++++++++++++++++++++
>  4 files changed, 47 insertions(+), 29 deletions(-)
>  create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
> index 31d37a90cec7..6edd869c8d6f 100644
> --- a/drivers/net/dsa/mv88e6xxx/Makefile
> +++ b/drivers/net/dsa/mv88e6xxx/Makefile
> @@ -2,5 +2,6 @@ obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
>  mv88e6xxx-objs := chip.o
>  mv88e6xxx-objs += global1.o
>  mv88e6xxx-objs += global1_atu.o
> +mv88e6xxx-objs += global1_vtu.o
>  mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
>  mv88e6xxx-objs += port.o
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index f025d3c22dba..bf0350432337 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -3,9 +3,6 @@
>   *
>   * Copyright (c) 2008 Marvell Semiconductor
>   *
> - * Copyright (c) 2015 CMC Electronics, Inc.
> - *	Added support for VLAN Table Unit operations
> - *
>   * Copyright (c) 2016 Andrew Lunn <andrew@lunn.ch>
>   *
>   * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
> @@ -1266,31 +1263,15 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
>  		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
>  }
>  
> -static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
> -{
> -	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
> -}
> -
> -static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_chip *chip, u16 op)
> -{
> -	int err;
> -
> -	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
> -	if (err)
> -		return err;
> -
> -	return _mv88e6xxx_vtu_wait(chip);
> -}
> -
>  static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_chip *chip)
>  {
>  	int ret;
>  
> -	ret = _mv88e6xxx_vtu_wait(chip);
> +	ret = mv88e6xxx_g1_vtu_op_wait(chip);
>  	if (ret < 0)
>  		return ret;
>  
> -	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_FLUSH_ALL);
> +	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_FLUSH_ALL);
>  }
>  
>  static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
> @@ -1380,11 +1361,11 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
>  	u16 val;
>  	int err;
>  
> -	err = _mv88e6xxx_vtu_wait(chip);
> +	err = mv88e6xxx_g1_vtu_op_wait(chip);
>  	if (err)
>  		return err;
>  
> -	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
> +	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
>  	if (err)
>  		return err;

Hi Vivien

This patch got me for a while. It initially looks like a bad idea. It
is not until you read all the patches, you can see why it is actually
good. It is a simple mechanical translation, which is easy to
review. But it seemed odd to be using these names in chip.c. But later
patches solve that, by moving the code in global1_vtu.c.

	Andrew
