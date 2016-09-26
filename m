From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 4/5] ISDN-Gigaset: Release memory in gigaset_initcs()
 after an allocation failure
Date: Mon, 26 Sep 2016 23:13:54 +0200
Message-ID: <1474924434.8546.29.camel@tiscali.nl>
References: <566ABCD9.1060404@users.sourceforge.net>
         <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
         <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Markus,

On Mon, 2016-09-26 at 17:43 +0200, SF Markus Elfring wrote:
> Memory was not released (as it would be expected) when one call
> of further resource reservations failed.

This was the only thing in this series that triggered more than a, very
uninspired, "meh" on first read.

> * Split a condition check for memory allocation failures so that
>   each pointer from these function calls will be checked immediately.
> 
>   See also background information:
>   Topic "CWE-754: Improper check for unusual or exceptional conditions"
>   Link: https://cwe.mitre.org/data/definitions/754.html

A quick scan of that link suggests we can do without the above
"background information" in the commit explanation.

> * Adjust jump targets according to the Linux coding style convention.

Another "meh".

> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/isdn/gigaset/common.c | 20 ++++++++++++--------
>  1 file changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/isdn/gigaset/common.c
> b/drivers/isdn/gigaset/common.c
> index c05a2a4..2e9382f 100644
> --- a/drivers/isdn/gigaset/common.c
> +++ b/drivers/isdn/gigaset/common.c
> @@ -710,10 +710,13 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
>  	cs->mode = M_UNKNOWN;
>  	cs->mstate = MS_UNINITIALIZED;
>  	cs->bcs = kmalloc_array(channels, sizeof(*cs->bcs), GFP_KERNEL);
> +	if (!cs->bcs)
> +		goto report_failure;
> +
>  	cs->inbuf = kmalloc(sizeof(*cs->inbuf), GFP_KERNEL);
> -	if (!cs->bcs || !cs->inbuf) {
> -		goto error;
> -	}
> +	if (!cs->inbuf)
> +		goto free_bcs;
> +
>  	++cs->cs_init;
>  
>  	gig_dbg(DEBUG_INIT, "setting up at_state");
> @@ -737,14 +740,14 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
>  	gig_dbg(DEBUG_INIT, "setting up iif");
>  	if (gigaset_isdn_regdev(cs, modulename) < 0) {
>  		pr_err("error registering ISDN device\n");
> -		goto error;
> +		goto free_bcs;
>  	}
>  
>  	make_valid(cs, VALID_ID);
>  	++cs->cs_init;
>  	gig_dbg(DEBUG_INIT, "setting up hw");
>  	if (cs->ops->initcshw(cs) < 0)
> -		goto error;
> +		goto free_bcs;
>  
>  	++cs->cs_init;
>  
> @@ -759,7 +762,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
>  		gig_dbg(DEBUG_INIT, "setting up bcs[%d]", i);
>  		if (gigaset_initbcs(cs->bcs + i, cs, i) < 0) {
>  			pr_err("could not allocate channel %d data\n", i);
> -			goto error;
> +			goto free_bcs;
>  		}
>  	}
>  
> @@ -772,8 +775,9 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
>  
>  	gig_dbg(DEBUG_INIT, "cs initialized");
>  	return cs;
> -
> -error:
> +free_bcs:
> +	kfree(cs->bcs);
> +report_failure:
>  	gig_dbg(DEBUG_INIT, "failed");
>  	gigaset_freecs(cs);

gigaset_freecs() is not a function I look at for the fun of it. But
still, in it we find:

	case 0: /* error in basic setup */
		[...]
		kfree(cs->inbuf);
		kfree(cs->bcs);

As far as I can tell we will call those two kfree()'s if we jump to
"error". So, contrary to your analysis, I don't think we leak cs->bcs.

>  	return NULL;


Paul Bolle
