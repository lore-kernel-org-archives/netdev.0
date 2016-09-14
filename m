From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH] xen-netback: fix error handling on netback_probe()
Date: Wed, 14 Sep 2016 11:10:23 +0100
Message-ID: <20160914101023.GY15958@citrix.com>
References: <1473768687-27384-1-git-send-email-filipe.manco@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
        Xen-devel <xen-devel@lists.xenproject.org>
To: Filipe Manco <filipe.manco@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:22992 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcINKK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 06:10:26 -0400
Content-Disposition: inline
In-Reply-To: <1473768687-27384-1-git-send-email-filipe.manco@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC xen-devel as well.

On Tue, Sep 13, 2016 at 02:11:27PM +0200, Filipe Manco wrote:
> In case of error during netback_probe() (e.g. an entry missing on the
> xenstore) netback_remove() is called on the new device, which will set
> the device backend state to XenbusStateClosed by calling
> set_backend_state(). However, the backend state wasn't initialized by
> netback_probe() at this point, which will cause and invalid transaction
> and set_backend_state() to BUG().
> 
> Initialize the backend state at the beginning of netback_probe() to
> XenbusStateInitialising, and create a new valid state transaction on
> set_backend_state(), from XenbusStateInitialising to XenbusStateClosed.
> 
> Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>

There is a state machine right before set_backend_state. You would also
need to update that.

According to the definition of XenbusStateInitialising, this patch looks
plausible to me.

Wei.

> ---
>  drivers/net/xen-netback/xenbus.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 6a31f2610c23..c0e5f6994d01 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -270,6 +270,7 @@ static int netback_probe(struct xenbus_device *dev,
>  
>  	be->dev = dev;
>  	dev_set_drvdata(&dev->dev, be);
> +	be->state = XenbusStateInitialising;
>  
>  	sg = 1;
>  
> @@ -515,6 +516,15 @@ static void set_backend_state(struct backend_info *be,
>  {
>  	while (be->state != state) {
>  		switch (be->state) {
> +		case XenbusStateInitialising:
> +			switch (state) {
> +			case XenbusStateClosed:
> +				backend_switch_state(be, XenbusStateClosed);
> +				break;
> +			default:
> +				BUG();
> +			}
> +			break;
>  		case XenbusStateClosed:
>  			switch (state) {
>  			case XenbusStateInitWait:
> -- 
> 2.7.4
> 
