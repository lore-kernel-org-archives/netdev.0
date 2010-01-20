From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH net-next-2.6 13/13] net-caif-driver: add CAIF serial
 driver (ldisc)
Date: Wed, 20 Jan 2010 15:36:00 -0800
Message-ID: <20100120153600.6e7ce0b2.randy.dunlap@oracle.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	<1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:17009 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab0ATXgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:36:47 -0500
In-Reply-To: <1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 23:55:30 +0100 sjur.brandeland@stericsson.com wrote:

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Add CAIF Serial driver. This driver is implemented as a line discipline.
> The TTY is opened from inside the kernel module.
> 
> caif_serial uses the following module parameters:
> ser_ttyname - specifies the tty name.
> ser_use_stx - specifies if STart of frame eXtension is in use.
> ser_loop    - sets the interface in loopback mode.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> ---
>  drivers/net/Kconfig            |    2 +
>  drivers/net/Makefile           |    1 +
>  drivers/net/caif/Kconfig       |   15 ++
>  drivers/net/caif/Makefile      |   14 ++
>  drivers/net/caif/caif_serial.c |  420 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/tty.h            |    4 +-
>  6 files changed, 454 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/net/caif/Kconfig
>  create mode 100644 drivers/net/caif/Makefile
>  create mode 100644 drivers/net/caif/caif_serial.c

> diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
> new file mode 100644
> index 0000000..01784a0
> --- /dev/null
> +++ b/drivers/net/caif/Makefile
> @@ -0,0 +1,14 @@
> +ifeq ($(CONFIG_CAIF_DEBUG),1)
> +CAIF_DBG_FLAGS := -DDEBUG
> +endif
> +
> +KBUILD_EXTRA_SYMBOLS=net/caif/Module.symvers
> +
> +ccflags-y := $(CAIF_FLAGS) $(CAIF_DBG_FLAGS)
> +clean-dirs:= .tmp_versions
> +clean-files:= Module.symvers modules.order *.cmd *~ \
> +
> +# Serial interface
> +obj-$(CONFIG_CAIF_TTY) += caif_serial.o
> +
> +
> diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
> new file mode 100644
> index 0000000..7d6636b
> --- /dev/null
> +++ b/drivers/net/caif/caif_serial.c
> @@ -0,0 +1,420 @@
> +/*
> + * Copyright (C) ST-Ericsson AB 2010
> + * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
> + * License terms: GNU General Public License (GPL) version 2
> + */
> +
> +#include <linux/init.h>
> +#include <linux/version.h>
> +#include <linux/module.h>
> +#include <linux/device.h>
> +#include <linux/types.h>
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +#include <linux/rtnetlink.h>
> +#include <linux/tty.h>
> +#include <linux/file.h>
> +#include <linux/if_arp.h>
> +#include <net/caif/caif_device.h>
> +#include <net/caif/generic/caif_layer.h>
> +#include <net/caif/generic/cfcnfg.h>
> +#include <linux/err.h>
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Sjur Brendeland<sjur.brandeland@stericsson.com>");
> +MODULE_DESCRIPTION("CAIF serial device TTY line discipline");
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS_LDISC(N_CAIF);
> +
> +#define CAIF_SENDING	1
> +#define CAIF_UART_TX_COMPLETED	2
> +#define CAIF_FLOW_OFF_SENT	4
> +#define MAX_WRITE_CHUNK	     4096
> +#define ON 1
> +#define OFF 0
> +#define CAIF_MAX_MTU 4096
> +
> +struct net_device *device;
> +char *ser_ttyname = "/dev/ttyS0";
> +module_param(ser_ttyname, charp, S_IRUGO);
> +MODULE_PARM_DESC(ser_ttyname, "TTY to open.");
> +

Can't a lot of these data items be static?  (above & below)

> +int ser_loop;
> +module_param(ser_loop, bool, S_IRUGO);
> +MODULE_PARM_DESC(ser_loop, "Run in simulated loopback mode.");
> +
> +int ser_use_stx;
> +module_param(ser_use_stx, bool, S_IRUGO);
> +MODULE_PARM_DESC(ser_use_stx, "STX enabled or not.");
> +
> +int ser_write_chunk = MAX_WRITE_CHUNK;
> +module_param(ser_write_chunk, int, S_IRUGO);
> +
> +MODULE_PARM_DESC(ser_write_chunk, "Maximum size of data written to UART.");
> +
> +
> +static int caif_net_open(struct net_device *dev);
> +static int caif_net_close(struct net_device *dev);
> +
> +struct ser_device {
> +	struct caif_dev_common common;
> +	struct net_device *dev;
> +	struct sk_buff_head head;
> +	int xoff;
> +	struct tty_struct *tty;
> +	bool tx_started;
> +	unsigned long state;
> +	struct file *file;
> +	char *tty_name;
> +};
> +
> +static int ser_phy_tx(struct ser_device *ser, struct sk_buff *skb);
> +static void caifdev_setup(struct net_device *dev);
> +static void ser_tx_wakeup(struct tty_struct *tty);
> +

...

> +
> +static int start_ldisc(struct ser_device *ser)
> +{
> +	struct file *f;
> +	mm_segment_t oldfs;
> +	struct termios tio;
> +	int ldiscnr = N_CAIF;
> +	int ret;
> +	f = filp_open(ser->tty_name, 0, 0);
> +	if (IS_ERR(f)) {
> +		dev_err(&ser->dev->dev, "CAIF cannot open:%s\n", ser->tty_name);
> +		ret = -EINVAL;
> +		goto error;
> +	}
> +	if (f == NULL || f->f_op == NULL || f->f_op->unlocked_ioctl == NULL) {
> +		dev_err(&ser->dev->dev, "TTY cannot do IOCTL:%s\n",
> +			ser->tty_name);
> +		ret = -EINVAL;

I'm thinking that the errcode should be (negative) ENOTTY...

> +		goto error;
> +	}
> +
> +	ser->file = f;
> +	oldfs = get_fs();
> +	set_fs(KERNEL_DS);
> +
> +	f->f_op->unlocked_ioctl(f, TCFLSH, 0x2);
> +	memset(&tio, 0, sizeof(tio));
> +	tio.c_cflag = B115200 | CRTSCTS | CS8 | CLOCAL | CREAD;
> +	f->f_op->unlocked_ioctl(f, TCSETS, (long unsigned int)&tio);
> +	f->f_op->unlocked_ioctl(f, TIOCSETD, (long unsigned int)&ldiscnr);
> +	set_fs(oldfs);
> +	return 0;
> +error:
> +	oldfs = get_fs();
> +	set_fs(KERNEL_DS);
> +	return ret;
> +}


---
~Randy
