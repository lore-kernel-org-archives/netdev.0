From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 8/8] xen-netback: add support for toeplitz
 hashing
Date: Mon, 26 Oct 2015 17:05:54 +0000
Message-ID: <20151026170554.GH18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-9-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3575 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbbJZRGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 13:06:41 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-9-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:25AM +0100, Paul Durrant wrote:
> This patch adds all the necessary infrastructure to allow a frontend to
> specify toeplitz hashing of network packets on its receive side. (See
> netif.h for details of the xenbus protocol).
> 
> The toeplitz hash algorithm itself was based on pseudo-code provided by
> Microsoft at:
> 
> https://msdn.microsoft.com/en-us/library/windows/hardware/ff570725.aspx
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
[...]
>  
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 0c7da7b..38eee4f 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -142,17 +142,122 @@ void xenvif_wake_queue(struct xenvif_queue *queue)
>  	netif_tx_wake_queue(netdev_get_tx_queue(dev, id));
>  }
>  

I skipped the hash implementation because I don't think I know enough to
tell if it is correct or not, and protocol negotiation because I think
that's going to change in next version.

> +
> +
> +static void xen_net_read_toeplitz_key(struct xenvif *vif,
> +				      const char *node)
> +{
> +	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
> +	char *str, *token;
> +	u8 key[40];

This should use the macro.

> +	unsigned int n, i;
> +
> +	str = xenbus_read(XBT_NIL, node, "key", NULL);
> +	if (IS_ERR(str))
> +		goto fail1;
> +
> +	memset(key, 0, sizeof(key));
> +
> +	n = 0;
> +	while ((token = strsep(&str, ",")) != NULL) {
> +		int rc;
> +
> +		if (n >= ARRAY_SIZE(vif->hash_params.toeplitz.key)) {
> +			pr_err("%s: key too big\n",
> +			       dev->nodename);
> +			goto fail2;
> +		}
> +
> +		rc = kstrtou8(token, 0, &key[n]);
> +		if (rc < 0) {
> +			pr_err("%s: invalid key value (%s at index %u)\n",
> +			       dev->nodename, token, n);
> +			goto fail2;
> +		}
> +
> +		n++;
> +	}
> +
> +	for (i = 0; i < ARRAY_SIZE(vif->hash_params.toeplitz.key); i++)
> +		vif->hash_params.toeplitz.key[i] = key[i];
> +
> +	kfree(str);
> +	return;
> +
> +fail2:
> +	kfree(str);
> +fail1:
> +	vif->hash_params.toeplitz.types = 0;
> +}
> +
[...]
> +
> +static void xen_hash_changed(struct xenbus_watch *watch,
> +			     const char **vec, unsigned int len)
> +{
> +	struct xenvif *vif = container_of(watch, struct xenvif, hash_watch);
> +
> +	xen_net_read_hash(vif);

I think the same question for previous patch applies here, too.

Is there any concern of correctness and security implication that you
just change the hash without stopping the vif?

Wei.
