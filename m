From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [PATCH] bluetooth : move children of connection device to NULL
	before connection down
Date: Mon, 21 Jan 2008 12:54:01 +0800
Message-ID: <20080121045401.GB4162@darkstar.te-china.tietoenator.com>
References: <20080121044913.GA4162@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sourceforge.net,
	cornelia.huck@de.ibm.com, gombasg@sztaki.hu, htejun@gmail.com,
	viro@zeniv.linux.org.uk, kay.sievers@vrfy.org, greg@kroah.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:53050 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756943AbYAUEwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 23:52:34 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1694503fga.17
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 20:52:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121044913.GA4162@darkstar.te-china.tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 12:49:13PM +0800, Dave Young wrote:
> The rfcomm tty device will possibly retain even when conn is down,
> and sysfs doesn't support zombie device moving, so this patch
> move the tty device before conn device is destroyed.
> 
> For the bug refered please see :
> http://lkml.org/lkml/2007/12/28/87
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 
> 
> ---
>  net/bluetooth/hci_sysfs.c  |   17 +++++++++++++++++
>  net/bluetooth/rfcomm/tty.c |    3 ++-
>  2 files changed, 19 insertions(+), 1 deletion(-)
> 
> diff -upr linux/net/bluetooth/hci_sysfs.c linux.new/net/bluetooth/hci_sysfs.c
> --- linux/net/bluetooth/hci_sysfs.c	2008-01-21 11:29:34.000000000 +0800
> +++ linux.new/net/bluetooth/hci_sysfs.c	2008-01-21 11:33:46.000000000 +0800
> @@ -316,9 +316,26 @@ void hci_conn_add_sysfs(struct hci_conn 
>  	schedule_work(&conn->work);
>  }
>  
> +static int __match_tty(struct device *dev, void *data)
> +{
> +	/* The rfcomm tty device will possibly retain even when conn
> +	 * is down, and sysfs doesn't support move zombie device,
> +	 * so we should move the device before conn device is destroyed.
> +	 * Due to the only child device of hci_conn dev is rfcomm
> +	 * tty_dev, here just return 1
> +	 */
> +	return 1;
> +}
> +
>  static void del_conn(struct work_struct *work)
>  {
> +	struct device *dev;
>  	struct hci_conn *conn = container_of(work, struct hci_conn, work);
> +
> +	while (dev = device_find_child(&conn->dev, NULL, __match_tty)) {
> +		device_move(dev, NULL);
> +		put_device(dev);
> +	}
>  	device_del(&conn->dev);
>  	put_device(&conn->dev);
>  }
> diff -upr linux/net/bluetooth/rfcomm/tty.c linux.new/net/bluetooth/rfcomm/tty.c
> --- linux/net/bluetooth/rfcomm/tty.c	2008-01-21 11:30:44.000000000 +0800
> +++ linux.new/net/bluetooth/rfcomm/tty.c	2008-01-21 11:32:23.000000000 +0800
> @@ -696,7 +696,8 @@ static void rfcomm_tty_close(struct tty_
>  	BT_DBG("tty %p dev %p dlc %p opened %d", tty, dev, dev->dlc, dev->opened);
>  
>  	if (--dev->opened == 0) {
> -		device_move(dev->tty_dev, NULL);
> +		if (dev->tty_dev->parent)
> +			device_move(dev->tty_dev, NULL);
>  
>  		/* Close DLC and dettach TTY */
>  		rfcomm_dlc_close(dev->dlc, 0);

Add people missed in cc-list.
