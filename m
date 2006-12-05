From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH 4/9] pcmcia: remove prod_id indirection
Date: Wed, 6 Dec 2006 00:35:08 +0100
Message-ID: <20061205233508.GA31463@pingi.kke.suse.de>
References: <20061205015942.GA2624@dominikbrodowski.de> <20061205021250.GE2624@dominikbrodowski.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:48447 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336AbWLEXfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 18:35:15 -0500
To: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
Content-Disposition: inline
In-Reply-To: <20061205021250.GE2624@dominikbrodowski.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 04, 2006 at 09:12:51PM -0500, Dominik Brodowski wrote:
> From: Dominik Brodowski <linux@dominikbrodowski.net>
> Date: Sun, 4 Jun 2006 18:06:13 +0200
> Subject: [PATCH] pcmcia: remove prod_id indirection
> 
> As we read out the product information strings (VERS_1) from the PCMCIA device
> in the PCMCIA core, and device drivers can access those reliably in struct
> pcmcia_device's fields prod_id[], remove additional product information string
> detection logic from PCMCIA device drivers.
> 
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/isdn/hardware/avm/avm_cs.c |   14 +++-----------
>  drivers/isdn/hisax/avma1_cs.c      |   14 +++-----------

Acked-by: Karsten Keil <kkeil@suse.de>
for ISDN.

>  drivers/net/pcmcia/3c574_cs.c      |    9 +++------
>  drivers/net/pcmcia/smc91c92_cs.c   |   27 ++++++++-------------------
>  drivers/net/pcmcia/xirc2ps_cs.c    |   19 ++++---------------
>  drivers/net/wireless/ray_cs.c      |   15 +++++----------
>  drivers/telephony/ixj_pcmcia.c     |   30 ++++++++++++++----------------
>  7 files changed, 40 insertions(+), 88 deletions(-)
> 
> diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
> index 7bbfd85..db3755b 100644
> --- a/drivers/isdn/hardware/avm/avm_cs.c
> +++ b/drivers/isdn/hardware/avm/avm_cs.c
> @@ -217,18 +217,10 @@ static int avmcs_config(struct pcmcia_de
>      }
>  
>      do {
> -
> -	tuple.Attributes = 0;
> -	tuple.TupleData = buf;
> -	tuple.TupleDataMax = 254;
> -	tuple.TupleOffset = 0;
> -	tuple.DesiredTuple = CISTPL_VERS_1;
> -
>  	devname[0] = 0;
> -	if( !first_tuple(link, &tuple, &parse) && parse.version_1.ns > 1 ) {
> -	    strlcpy(devname,parse.version_1.str + parse.version_1.ofs[1], 
> -			sizeof(devname));
> -	}
> +	if (link->prod_id[1])
> +		strlcpy(devname, link->prod_id[1], sizeof(devname));
> +
>  	/*
>           * find IO port
>           */
> diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
> index ac28e32..40c9b02 100644
> --- a/drivers/isdn/hisax/avma1_cs.c
> +++ b/drivers/isdn/hisax/avma1_cs.c
> @@ -239,18 +239,10 @@ static int avma1cs_config(struct pcmcia_
>      }
>  
>      do {
> -
> -	tuple.Attributes = 0;
> -	tuple.TupleData = buf;
> -	tuple.TupleDataMax = 254;
> -	tuple.TupleOffset = 0;
> -	tuple.DesiredTuple = CISTPL_VERS_1;
> -
>  	devname[0] = 0;
> -	if( !first_tuple(link, &tuple, &parse) && parse.version_1.ns > 1 ) {
> -	    strlcpy(devname,parse.version_1.str + parse.version_1.ofs[1], 
> -			sizeof(devname));
> -	}
> +	if (link->prod_id[1])
> +		strlcpy(devname, link->prod_id[1], sizeof(devname));
> +
>  	/*
>           * find IO port
>           */
> diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
> index 0460099..420f70b 100644
> --- a/drivers/net/pcmcia/3c574_cs.c
> +++ b/drivers/net/pcmcia/3c574_cs.c
> @@ -397,12 +397,9 @@ static int tc574_config(struct pcmcia_de
>  			goto failed;
>  		}
>  	}
> -	tuple.DesiredTuple = CISTPL_VERS_1;
> -	if (pcmcia_get_first_tuple(link, &tuple) == CS_SUCCESS &&
> -		pcmcia_get_tuple_data(link, &tuple) == CS_SUCCESS &&
> -		pcmcia_parse_tuple(link, &tuple, &parse) == CS_SUCCESS) {
> -		cardname = parse.version_1.str + parse.version_1.ofs[1];
> -	} else
> +	if (link->prod_id[1])
> +		cardname = link->prod_id[1];
> +	else
>  		cardname = "3Com 3c574";
>  
>  	{
> diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
> index ae024bf..bf40848 100644
> --- a/drivers/net/pcmcia/smc91c92_cs.c
> +++ b/drivers/net/pcmcia/smc91c92_cs.c
> @@ -560,16 +560,8 @@ static int mhz_setup(struct pcmcia_devic
>  
>      /* Read the station address from the CIS.  It is stored as the last
>         (fourth) string in the Version 1 Version/ID tuple. */
> -    tuple->DesiredTuple = CISTPL_VERS_1;
> -    if (first_tuple(link, tuple, parse) != CS_SUCCESS) {
> -	rc = -1;
> -	goto free_cfg_mem;
> -    }
> -    /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
> -    if (next_tuple(link, tuple, parse) != CS_SUCCESS)
> -	first_tuple(link, tuple, parse);
> -    if (parse->version_1.ns > 3) {
> -	station_addr = parse->version_1.str + parse->version_1.ofs[3];
> +    if (link->prod_id[3]) {
> +	station_addr = link->prod_id[3];
>  	if (cvt_ascii_address(dev, station_addr) == 0) {
>  		rc = 0;
>  		goto free_cfg_mem;
> @@ -744,15 +736,12 @@ static int smc_setup(struct pcmcia_devic
>  	}
>      }
>      /* Try the third string in the Version 1 Version/ID tuple. */
> -    tuple->DesiredTuple = CISTPL_VERS_1;
> -    if (first_tuple(link, tuple, parse) != CS_SUCCESS) {
> -	rc = -1;
> -	goto free_cfg_mem;
> -    }
> -    station_addr = parse->version_1.str + parse->version_1.ofs[2];
> -    if (cvt_ascii_address(dev, station_addr) == 0) {
> -	rc = 0;
> -	goto free_cfg_mem;
> +    if (link->prod_id[2]) {
> +	station_addr = link->prod_id[2];
> +	if (cvt_ascii_address(dev, station_addr) == 0) {
> +		rc = 0;
> +		goto free_cfg_mem;
> +	}
>      }
>  
>      rc = -1;
> diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
> index f3914f5..d627361 100644
> --- a/drivers/net/pcmcia/xirc2ps_cs.c
> +++ b/drivers/net/pcmcia/xirc2ps_cs.c
> @@ -707,22 +707,11 @@ set_card_type(struct pcmcia_device *link
>   * Returns: true if this is a CE2
>   */
>  static int
> -has_ce2_string(struct pcmcia_device * link)
> +has_ce2_string(struct pcmcia_device * p_dev)
>  {
> -    tuple_t tuple;
> -    cisparse_t parse;
> -    u_char buf[256];
> -
> -    tuple.Attributes = 0;
> -    tuple.TupleData = buf;
> -    tuple.TupleDataMax = 254;
> -    tuple.TupleOffset = 0;
> -    tuple.DesiredTuple = CISTPL_VERS_1;
> -    if (!first_tuple(link, &tuple, &parse) && parse.version_1.ns > 2) {
> -	if (strstr(parse.version_1.str + parse.version_1.ofs[2], "CE2"))
> -	    return 1;
> -    }
> -    return 0;
> +	if (p_dev->prod_id[2] && strstr(p_dev->prod_id[2], "CE2"))
> +		return 1;
> +	return 0;
>  }
>  
>  /****************
> diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
> index 7fbfc9e..75cdc3e 100644
> --- a/drivers/net/wireless/ray_cs.c
> +++ b/drivers/net/wireless/ray_cs.c
> @@ -433,16 +433,11 @@ static int ray_config(struct pcmcia_devi
>  
>      /* Determine card type and firmware version */
>      buf[0] = buf[MAX_TUPLE_SIZE - 1] = 0;
> -    tuple.DesiredTuple = CISTPL_VERS_1;
> -    CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
> -    tuple.TupleData = buf;
> -    tuple.TupleDataMax = MAX_TUPLE_SIZE;
> -    tuple.TupleOffset = 2;
> -    CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
> -
> -    for (i=0; i<tuple.TupleDataLen - 4; i++) 
> -        if (buf[i] == 0) buf[i] = ' ';
> -    printk(KERN_INFO "ray_cs Detected: %s\n",buf);
> +    printk(KERN_INFO "ray_cs Detected: %s%s%s%s\n",
> +	   link->prod_id[0] ? link->prod_id[0] : " ",
> +	   link->prod_id[1] ? link->prod_id[1] : " ",
> +	   link->prod_id[2] ? link->prod_id[2] : " ",
> +	   link->prod_id[3] ? link->prod_id[3] : " ");
>  
>      /* Now allocate an interrupt line.  Note that this does not
>         actually assign a handler to the interrupt.
> diff --git a/drivers/telephony/ixj_pcmcia.c b/drivers/telephony/ixj_pcmcia.c
> index dda0ca4..3f88978 100644
> --- a/drivers/telephony/ixj_pcmcia.c
> +++ b/drivers/telephony/ixj_pcmcia.c
> @@ -69,25 +69,21 @@ do { last_fn = (fn); if ((last_ret = (re
>  
>  static void ixj_get_serial(struct pcmcia_device * link, IXJ * j)
>  {
> -	tuple_t tuple;
> -	u_short buf[128];
>  	char *str;
> -	int last_ret, last_fn, i, place;
> +	int i, place;
>  	DEBUG(0, "ixj_get_serial(0x%p)\n", link);
> -	tuple.TupleData = (cisdata_t *) buf;
> -	tuple.TupleOffset = 0;
> -	tuple.TupleDataMax = 80;
> -	tuple.Attributes = 0;
> -	tuple.DesiredTuple = CISTPL_VERS_1;
> -	CS_CHECK(GetFirstTuple, pcmcia_get_first_tuple(link, &tuple));
> -	CS_CHECK(GetTupleData, pcmcia_get_tuple_data(link, &tuple));
> -	str = (char *) buf;
> -	printk("PCMCIA Version %d.%d\n", str[0], str[1]);
> -	str += 2;
> +
> +	str = link->prod_id[0];
> +	if (!str)
> +		goto cs_failed;
>  	printk("%s", str);
> -	str = str + strlen(str) + 1;
> +	str = link->prod_id[1];
> +	if (!str)
> +		goto cs_failed;
>  	printk(" %s", str);
> -	str = str + strlen(str) + 1;
> +	str = link->prod_id[2];
> +	if (!str)
> +		goto cs_failed;
>  	place = 1;
>  	for (i = strlen(str) - 1; i >= 0; i--) {
>  		switch (str[i]) {
> @@ -122,7 +118,9 @@ static void ixj_get_serial(struct pcmcia
>  		}
>  		place = place * 0x10;
>  	}
> -	str = str + strlen(str) + 1;
> +	str = link->prod_id[3];
> +	if (!str)
> +		goto cs_failed;
>  	printk(" version %s\n", str);
>        cs_failed:
>  	return;
> -- 
> 1.4.4
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Karsten Keil
SuSE Labs
ISDN development
