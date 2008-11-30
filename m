From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 2 of 2] netconsole: add write-only tty driver
Date: Sun, 30 Nov 2008 11:28:57 -0600
Message-ID: <1228066137.3196.64.camel@calx>
References: <1a5d52ff499998079f4b.1227820262@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hollis Blanchard <hollisb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:46087 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937AbYK3R3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Nov 2008 12:29:10 -0500
In-Reply-To: <1a5d52ff499998079f4b.1227820262@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 15:11 -0600, Hollis Blanchard wrote:
> This allows userspace to output to netconsole via the /dev/console device,
> which is very useful to see initscript output, for example. There is only one
> netconsole TTY device, and TTY output goes to all receivers specified for
> console output.
> 
> Input via /dev/console is still not implemented, however.
> 
> Signed-off-by: Hollis Blanchard <hollisb@us.ibm.com>
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -43,6 +43,7 @@
>  #include <linux/netpoll.h>
>  #include <linux/inet.h>
>  #include <linux/configfs.h>
> +#include <linux/tty.h>
>  
>  MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
>  MODULE_DESCRIPTION("Console driver for network interfaces");
> @@ -98,6 +99,8 @@ struct netconsole_target {
>  	int			enabled;
>  	struct netpoll		np;
>  };
> +
> +static struct tty_driver *netconsole_tty_driver;
>  
>  #ifdef	CONFIG_NETCONSOLE_DYNAMIC
>  
> @@ -728,15 +731,74 @@ static void netconsole_write_msg(const c
>  	spin_unlock_irqrestore(&target_list_lock, flags);
>  }
>  
> +static int netconsole_tty_open(struct tty_struct *tty, struct file *filp)
> +{
> +	return 0;
> +}
> +
> +static void netconsole_tty_close(struct tty_struct *tty, struct file *filp)
> +{
> +}
> +
> +static int netconsole_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
> +{
> +	netconsole_write_msg(buf, count);
> +	return count;
> +}
> +
> +static int netconsole_tty_write_room(struct tty_struct *tty)
> +{
> +	return MAX_PRINT_CHUNK;
> +}
> +
> +static const struct tty_operations netconsole_tty_ops = {
> +	.open = netconsole_tty_open,
> +	.close = netconsole_tty_close,
> +	.write = netconsole_tty_write,
> +	.write_room = netconsole_tty_write_room,
> +};
> +
> +static int __init netconsole_tty_init(void)
> +{
> +	netconsole_tty_driver = alloc_tty_driver(1);
> +	if (!netconsole_tty_driver)
> +		return -ENOMEM;
> +
> +	netconsole_tty_driver->owner = THIS_MODULE;
> +	netconsole_tty_driver->driver_name = "netcon";
> +	netconsole_tty_driver->name = "netcon";
> +	netconsole_tty_driver->minor_start = 0;
> +	netconsole_tty_driver->type = TTY_DRIVER_TYPE_SYSTEM;
> +	netconsole_tty_driver->init_termios = tty_std_termios;
> +	netconsole_tty_driver->init_termios.c_cflag = B9600 | CS8 | CREAD | HUPCL;
> +	netconsole_tty_driver->init_termios.c_ispeed = 9600;
> +	netconsole_tty_driver->init_termios.c_ospeed = 9600;
> +	netconsole_tty_driver->flags = TTY_DRIVER_REAL_RAW;
> +	tty_set_operations(netconsole_tty_driver, &netconsole_tty_ops);
> +
> +	if (tty_register_driver(netconsole_tty_driver))
> +		printk(KERN_ERR "Couldn't register netconsole tty driver\n");
> +
> +	return 0;
> +}
> +device_initcall(netconsole_tty_init);

I agree with Evgeniy that this should be merged into the existing init
function. Otherwise there's reader ambiguity about the ordering.
Otherwise this looks good.

-- 
Mathematics is the supreme nostalgia of our time.

