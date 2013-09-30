From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH V5 net-next 2/3] net: huawei_cdc_ncm: Introduce the
 huawei_cdc_ncm driver
Date: Mon, 30 Sep 2013 11:07:53 +0200
Message-ID: <1380532073.1484.15.camel@linux-fkkt.site>
References: <1380516609-31242-1-git-send-email-mrkiko.rs@gmail.com>
	 <1380516609-31242-3-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert de Vries <rhdv@xs4all.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	Freddy Xin <freddy@asix.com.tw>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Liu Junliang <liujunliang_ljl@163.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:USB NETWORKING DR..." <linux-usb@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	ModemManager-devel@lists.freedesktop.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380516609-31242-3-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-09-30 at 04:50 +0000, Enrico Mioso wrote:

> +static int huawei_cdc_ncm_manage_power(struct usbnet *usbnet_dev, int on)
> +{
> +	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
> +	int rv = 0;
> +
> +	if ((on && atomic_add_return(1, &drvstate->pmcount) == 1) ||
> +			(!on && atomic_dec_and_test(&drvstate->pmcount))) {
> +		rv = usb_autopm_get_interface(usbnet_dev->intf);
> +		if (rv < 0)
> +			goto err;

The error case corrupts drvstate->pmcount

> +		usbnet_dev->intf->needs_remote_wakeup = on;
> +		usb_autopm_put_interface(usbnet_dev->intf);
> +	}
> +err:
> +	return rv;
> +}


> +static int huawei_cdc_ncm_suspend(struct usb_interface *intf, pm_message_t message)
> +{
> +	int ret = 0;
> +	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
> +	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
> +
> +	if (ctx == NULL) {
> +		ret = -1;

That is not a valid way to indicate an error.

> +		goto error;
> +	}
> +
> +	ret = usbnet_suspend(intf, message);
> +	if (ret < 0)
> +		goto error;
> +
> +	if (intf == ctx->control &&
> +		drvstate->subdriver &&
> +		drvstate->subdriver->suspend)
> +		ret = drvstate->subdriver->suspend(intf, message);
> +	if (ret < 0)
> +		usbnet_resume(intf);
> +
> +error:
> +	return ret;
> +}
> +
> +static int huawei_cdc_ncm_resume(struct usb_interface *intf)
> +{
> +	int ret = 0;
> +	struct usbnet *usbnet_dev = usb_get_intfdata(intf);
> +	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
> +	bool callsub;
> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
> +
> +	/* should we call subdriver's resume function? */
> +	callsub =
> +		(intf == ctx->control &&
> +		drvstate->subdriver &&
> +		drvstate->subdriver->resume);
> +
> +	if (callsub)
> +		ret = drvstate->subdriver->resume(intf);
> +	if (ret < 0)
> +		goto err;
> +	ret = usbnet_resume(intf);
> +	if (ret < 0 && callsub && drvstate->subdriver->suspend)

You really want drivers with a resume() but no suspend() method?

> +		drvstate->subdriver->suspend(intf, PMSG_SUSPEND);
> +err:
> +	return ret;
> +}

	Regards
		Oliver
