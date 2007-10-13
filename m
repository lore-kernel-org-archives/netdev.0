From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH]race between open and disconnect in	irda-usb
Date: Sat, 13 Oct 2007 03:32:10 +0300
Message-ID: <20071013003210.GA8187@sortiz.org>
References: <200710121053.55829.oliver@neukum.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	Nick Fedchik <nick-UvdXiu2sajOKBXSJ/Qx0JQ@public.gmane.org>, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	USB development list <linux-usb-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200710121053.55829.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

On Fri, Oct 12, 2007 at 10:53:55AM +0200, Oliver Neukum wrote:
> Hi,
> 
> it seems to me that irda_usb_net_open() must set self->netopen
> under spinlock or disconnect() may fail to kill all URBs, if it is called
> while an interface is opened.
Makes sense, yes.
I will push it upstream with my next IrDA update.

Cheers,
Samuel.


> Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
> 
> 	Regards
> 		Oliver
> 
> ----
> 
> --- a/drivers/net/irda/irda-usb.c	2007-10-11 17:24:35.000000000 +0200
> +++ b/drivers/net/irda/irda-usb.c	2007-10-11 17:30:30.000000000 +0200
> @@ -1168,6 +1168,7 @@ static int stir421x_patch_device(struct 
>  static int irda_usb_net_open(struct net_device *netdev)
>  {
>  	struct irda_usb_cb *self;
> +	unsigned long flags;
>  	char	hwname[16];
>  	int i;
>  	
> @@ -1177,13 +1178,16 @@ static int irda_usb_net_open(struct net_
>  	self = (struct irda_usb_cb *) netdev->priv;
>  	IRDA_ASSERT(self != NULL, return -1;);
>  
> +	spin_lock_irqsave(&self->lock, flags);
>  	/* Can only open the device if it's there */
>  	if(!self->present) {
> +		spin_unlock_irqrestore(&self->lock, flags);
>  		IRDA_WARNING("%s(), device not present!\n", __FUNCTION__);
>  		return -1;
>  	}
>  
>  	if(self->needspatch) {
> +		spin_unlock_irqrestore(&self->lock, flags);
>  		IRDA_WARNING("%s(), device needs patch\n", __FUNCTION__) ;
>  		return -EIO ;
>  	}
> @@ -1198,6 +1202,7 @@ static int irda_usb_net_open(struct net_
>  	/* To do *before* submitting Rx urbs and starting net Tx queue
>  	 * Jean II */
>  	self->netopen = 1;
> +	spin_unlock_irqrestore(&self->lock, flags);
>  
>  	/* 
>  	 * Now that everything should be initialized properly,
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> irda-users mailing list
> irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> http://lists.sourceforge.net/lists/listinfo/irda-users


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
