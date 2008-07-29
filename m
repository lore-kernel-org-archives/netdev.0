From: Karsten Keil <kkeil@suse.de>
Subject: Re: [RFC] [PATCH 5/7] pcmcia: use pcmcia_loop_config in ISDN pcmcia drivers
Date: Tue, 29 Jul 2008 17:45:19 +0200
Message-ID: <20080729154519.GB19963@pingi.kke.suse.de>
References: <20080729071539.GB27385@comet.dominikbrodowski.net> <20080729072025.GH27385@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:33355 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756137AbYG2PpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 11:45:22 -0400
Content-Disposition: inline
In-Reply-To: <20080729072025.GH27385@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 09:20:25AM +0200, Dominik Brodowski wrote:
> Use the config loop helper in ISDN pcmcia drivers.
> 

Acked-by: Karsten Keil <kkeil@suse.de>

> CC: isdn4linux@listserv.isdn4linux.de
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/isdn/hardware/avm/avm_cs.c |   80 ++++++++++-------------------------
>  drivers/isdn/hisax/avma1_cs.c      |   76 +++++++++-------------------------
>  drivers/isdn/hisax/elsa_cs.c       |   71 ++++++++++----------------------
>  drivers/isdn/hisax/teles_cs.c      |   71 ++++++++++----------------------
>  4 files changed, 87 insertions(+), 211 deletions(-)
> 
> diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
> index a5b941c..7a1ead1 100644
> --- a/drivers/isdn/hardware/avm/avm_cs.c
> +++ b/drivers/isdn/hardware/avm/avm_cs.c
> @@ -154,78 +154,44 @@ static void avmcs_detach(struct pcmcia_device *link)
>      
>  ======================================================================*/
>  
> -static int get_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -		     cisparse_t *parse)
> +static int avmcs_configcheck(struct pcmcia_device *p_dev,
> +			     cistpl_cftable_entry_t *cf,
> +			     void *priv_data)
>  {
> -    int i = pcmcia_get_tuple_data(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return pcmcia_parse_tuple(handle, tuple, parse);
> -}
> -
> -static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -		     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_first_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> -}
> -
> -static int next_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -		     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_next_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> +	if (cf->io.nwin <= 0)
> +		return -ENODEV;
> +
> +	p_dev->conf.ConfigIndex = cf->index;
> +	p_dev->io.BasePort1 = cf->io.win[0].base;
> +	p_dev->io.NumPorts1 = cf->io.win[0].len;
> +	p_dev->io.NumPorts2 = 0;
> +	printk(KERN_INFO "avm_cs: testing i/o %#x-%#x\n",
> +	       p_dev->io.BasePort1,
> +	       p_dev->io.BasePort1+p_dev->io.NumPorts1-1);
> +	return pcmcia_request_io(p_dev, &p_dev->io);
>  }
>  
>  static int avmcs_config(struct pcmcia_device *link)
>  {
> -    tuple_t tuple;
> -    cisparse_t parse;
> -    cistpl_cftable_entry_t *cf = &parse.cftable_entry;
>      local_info_t *dev;
>      int i;
> -    u_char buf[64];
>      char devname[128];
>      int cardtype;
>      int (*addcard)(unsigned int port, unsigned irq);
>  
>      dev = link->priv;
>  
> -    do {
> -	devname[0] = 0;
> -	if (link->prod_id[1])
> -		strlcpy(devname, link->prod_id[1], sizeof(devname));
> -
> -	/*
> -         * find IO port
> -         */
> -	tuple.TupleData = (cisdata_t *)buf;
> -	tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
> -	tuple.Attributes = 0;
> -	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
> -	i = first_tuple(link, &tuple, &parse);
> -	while (i == CS_SUCCESS) {
> -	    if (cf->io.nwin > 0) {
> -		link->conf.ConfigIndex = cf->index;
> -		link->io.BasePort1 = cf->io.win[0].base;
> -		link->io.NumPorts1 = cf->io.win[0].len;
> -		link->io.NumPorts2 = 0;
> -                printk(KERN_INFO "avm_cs: testing i/o %#x-%#x\n",
> -			link->io.BasePort1,
> -		        link->io.BasePort1+link->io.NumPorts1-1);
> -		i = pcmcia_request_io(link, &link->io);
> -		if (i == CS_SUCCESS) goto found_port;
> -	    }
> -	    i = next_tuple(link, &tuple, &parse);
> -	}
> +    devname[0] = 0;
> +    if (link->prod_id[1])
> +	    strlcpy(devname, link->prod_id[1], sizeof(devname));
>  
> -found_port:
> -	if (i != CS_SUCCESS) {
> -	    cs_error(link, RequestIO, i);
> -	    break;
> -	}
> +    /*
> +     * find IO port
> +     */
> +    if (pcmcia_loop_config(link, avmcs_configcheck, NULL))
> +	    return -ENODEV;
>  
> +    do {
>  	/*
>  	 * allocate an interrupt line
>  	 */
> diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
> index fc6cc2c..8142d9f 100644
> --- a/drivers/isdn/hisax/avma1_cs.c
> +++ b/drivers/isdn/hisax/avma1_cs.c
> @@ -174,38 +174,28 @@ static void avma1cs_detach(struct pcmcia_device *link)
>      
>  ======================================================================*/
>  
> -static int get_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -		     cisparse_t *parse)
> +static int avma1cs_configcheck(struct pcmcia_device *p_dev,
> +			     cistpl_cftable_entry_t *cf,
> +			     void *priv_data)
>  {
> -    int i = pcmcia_get_tuple_data(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return pcmcia_parse_tuple(handle, tuple, parse);
> +	if (cf->io.nwin <= 0)
> +		return -ENODEV;
> +
> +	p_dev->conf.ConfigIndex = cf->index;
> +	p_dev->io.BasePort1 = cf->io.win[0].base;
> +	p_dev->io.NumPorts1 = cf->io.win[0].len;
> +	p_dev->io.NumPorts2 = 0;
> +	printk(KERN_INFO "avma1_cs: testing i/o %#x-%#x\n",
> +	       p_dev->io.BasePort1,
> +	       p_dev->io.BasePort1+p_dev->io.NumPorts1-1);
> +	return pcmcia_request_io(p_dev, &p_dev->io);
>  }
>  
> -static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -		     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_first_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> -}
> -
> -static int next_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -		     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_next_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> -}
>  
>  static int avma1cs_config(struct pcmcia_device *link)
>  {
> -    tuple_t tuple;
> -    cisparse_t parse;
> -    cistpl_cftable_entry_t *cf = &parse.cftable_entry;
>      local_info_t *dev;
>      int i;
> -    u_char buf[64];
>      char devname[128];
>      IsdnCard_t	icard;
>      int busy = 0;
> @@ -214,40 +204,14 @@ static int avma1cs_config(struct pcmcia_device *link)
>  
>      DEBUG(0, "avma1cs_config(0x%p)\n", link);
>  
> -    do {
> -	devname[0] = 0;
> -	if (link->prod_id[1])
> -		strlcpy(devname, link->prod_id[1], sizeof(devname));
> +    devname[0] = 0;
> +    if (link->prod_id[1])
> +	    strlcpy(devname, link->prod_id[1], sizeof(devname));
>  
> -	/*
> -         * find IO port
> -         */
> -	tuple.TupleData = (cisdata_t *)buf;
> -	tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
> -	tuple.Attributes = 0;
> -	tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
> -	i = first_tuple(link, &tuple, &parse);
> -	while (i == CS_SUCCESS) {
> -	    if (cf->io.nwin > 0) {
> -		link->conf.ConfigIndex = cf->index;
> -		link->io.BasePort1 = cf->io.win[0].base;
> -		link->io.NumPorts1 = cf->io.win[0].len;
> -		link->io.NumPorts2 = 0;
> -		printk(KERN_INFO "avma1_cs: testing i/o %#x-%#x\n",
> -			link->io.BasePort1,
> -			link->io.BasePort1+link->io.NumPorts1 - 1);
> -		i = pcmcia_request_io(link, &link->io);
> -		if (i == CS_SUCCESS) goto found_port;
> -	    }
> -	    i = next_tuple(link, &tuple, &parse);
> -	}
> +    if (pcmcia_loop_config(link, avma1cs_configcheck, NULL))
> +	    return -ENODEV;
>  
> -found_port:
> -	if (i != CS_SUCCESS) {
> -	    cs_error(link, RequestIO, i);
> -	    break;
> -	}
> -	
> +    do {
>  	/*
>  	 * allocate an interrupt line
>  	 */
> diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
> index db7e644..b85b07d 100644
> --- a/drivers/isdn/hisax/elsa_cs.c
> +++ b/drivers/isdn/hisax/elsa_cs.c
> @@ -203,68 +203,41 @@ static void elsa_cs_detach(struct pcmcia_device *link)
>      device available to the system.
>  
>  ======================================================================*/
> -static int get_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -                     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_tuple_data(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return pcmcia_parse_tuple(handle, tuple, parse);
> -}
>  
> -static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -                     cisparse_t *parse)
> +static int elsa_cs_configcheck(struct pcmcia_device *p_dev,
> +			       cistpl_cftable_entry_t *cf,
> +			       void *priv_data)
>  {
> -    int i = pcmcia_get_first_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> -}
> +	int j;
>  
> -static int next_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -                     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_next_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> +        if ( (cf->io.nwin > 0) && cf->io.win[0].base) {
> +		printk(KERN_INFO "(elsa_cs: looks like the 96 model)\n");
> +		p_dev->conf.ConfigIndex = cf->index;
> +		p_dev->io.BasePort1 = cf->io.win[0].base;
> +		if (!pcmcia_request_io(p_dev, &p_dev->io))
> +			return 0;
> +        } else {
> +		printk(KERN_INFO "(elsa_cs: looks like the 97 model)\n");
> +		p_dev->conf.ConfigIndex = cf->index;
> +		for (j = 0x2f0; j > 0x100; j -= 0x10) {
> +			p_dev->io.BasePort1 = j;
> +			if (!pcmcia_request_io(p_dev, &p_dev->io))
> +				return 0;
> +		}
> +        }
> +	return -ENODEV;
>  }
>  
>  static int elsa_cs_config(struct pcmcia_device *link)
>  {
> -    tuple_t tuple;
> -    cisparse_t parse;
>      local_info_t *dev;
> -    int i, j, last_fn;
> -    u_short buf[128];
> -    cistpl_cftable_entry_t *cf = &parse.cftable_entry;
> +    int i, last_fn;
>      IsdnCard_t icard;
>  
>      DEBUG(0, "elsa_config(0x%p)\n", link);
>      dev = link->priv;
>  
> -    tuple.TupleData = (cisdata_t *)buf;
> -    tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
> -    tuple.Attributes = 0;
> -    tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
> -    i = first_tuple(link, &tuple, &parse);
> -    while (i == CS_SUCCESS) {
> -        if ( (cf->io.nwin > 0) && cf->io.win[0].base) {
> -            printk(KERN_INFO "(elsa_cs: looks like the 96 model)\n");
> -            link->conf.ConfigIndex = cf->index;
> -            link->io.BasePort1 = cf->io.win[0].base;
> -            i = pcmcia_request_io(link, &link->io);
> -            if (i == CS_SUCCESS) break;
> -        } else {
> -          printk(KERN_INFO "(elsa_cs: looks like the 97 model)\n");
> -          link->conf.ConfigIndex = cf->index;
> -          for (i = 0, j = 0x2f0; j > 0x100; j -= 0x10) {
> -            link->io.BasePort1 = j;
> -            i = pcmcia_request_io(link, &link->io);
> -            if (i == CS_SUCCESS) break;
> -          }
> -          break;
> -        }
> -        i = next_tuple(link, &tuple, &parse);
> -    }
> -
> +    i = pcmcia_loop_config(link, elsa_cs_configcheck, NULL);
>      if (i != CS_SUCCESS) {
>  	last_fn = RequestIO;
>  	goto cs_failed;
> diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
> index ab4bd45..fc4d024 100644
> --- a/drivers/isdn/hisax/teles_cs.c
> +++ b/drivers/isdn/hisax/teles_cs.c
> @@ -193,68 +193,41 @@ static void teles_detach(struct pcmcia_device *link)
>      device available to the system.
>  
>  ======================================================================*/
> -static int get_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -                     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_tuple_data(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return pcmcia_parse_tuple(handle, tuple, parse);
> -}
>  
> -static int first_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -                     cisparse_t *parse)
> +static int teles_cs_configcheck(struct pcmcia_device *p_dev,
> +				cistpl_cftable_entry_t *cf,
> +				void *priv_data)
>  {
> -    int i = pcmcia_get_first_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> -}
> +	int j;
>  
> -static int next_tuple(struct pcmcia_device *handle, tuple_t *tuple,
> -                     cisparse_t *parse)
> -{
> -    int i = pcmcia_get_next_tuple(handle, tuple);
> -    if (i != CS_SUCCESS) return i;
> -    return get_tuple(handle, tuple, parse);
> +        if ( (cf->io.nwin > 0) && cf->io.win[0].base) {
> +		printk(KERN_INFO "(teles_cs: looks like the 96 model)\n");
> +		p_dev->conf.ConfigIndex = cf->index;
> +		p_dev->io.BasePort1 = cf->io.win[0].base;
> +		if (!pcmcia_request_io(p_dev, &p_dev->io))
> +			return 0;
> +        } else {
> +		printk(KERN_INFO "(teles_cs: looks like the 97 model)\n");
> +		p_dev->conf.ConfigIndex = cf->index;
> +		for (j = 0x2f0; j > 0x100; j -= 0x10) {
> +			p_dev->io.BasePort1 = j;
> +			if (!pcmcia_request_io(p_dev, &p_dev->io))
> +				return 0;
> +		}
> +        }
> +	return -ENODEV;
>  }
>  
>  static int teles_cs_config(struct pcmcia_device *link)
>  {
> -    tuple_t tuple;
> -    cisparse_t parse;
>      local_info_t *dev;
> -    int i, j, last_fn;
> -    u_short buf[128];
> -    cistpl_cftable_entry_t *cf = &parse.cftable_entry;
> +    int i, last_fn;
>      IsdnCard_t icard;
>  
>      DEBUG(0, "teles_config(0x%p)\n", link);
>      dev = link->priv;
>  
> -    tuple.TupleData = (cisdata_t *)buf;
> -    tuple.TupleOffset = 0; tuple.TupleDataMax = 255;
> -    tuple.Attributes = 0;
> -    tuple.DesiredTuple = CISTPL_CFTABLE_ENTRY;
> -    i = first_tuple(link, &tuple, &parse);
> -    while (i == CS_SUCCESS) {
> -        if ( (cf->io.nwin > 0) && cf->io.win[0].base) {
> -            printk(KERN_INFO "(teles_cs: looks like the 96 model)\n");
> -            link->conf.ConfigIndex = cf->index;
> -            link->io.BasePort1 = cf->io.win[0].base;
> -            i = pcmcia_request_io(link, &link->io);
> -            if (i == CS_SUCCESS) break;
> -        } else {
> -          printk(KERN_INFO "(teles_cs: looks like the 97 model)\n");
> -          link->conf.ConfigIndex = cf->index;
> -          for (i = 0, j = 0x2f0; j > 0x100; j -= 0x10) {
> -            link->io.BasePort1 = j;
> -            i = pcmcia_request_io(link, &link->io);
> -            if (i == CS_SUCCESS) break;
> -          }
> -          break;
> -        }
> -        i = next_tuple(link, &tuple, &parse);
> -    }
> -
> +    i = pcmcia_loop_config(link, teles_cs_configcheck, NULL);
>      if (i != CS_SUCCESS) {
>  	last_fn = RequestIO;
>  	goto cs_failed;
> -- 
> 1.5.4.3

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
