From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 006/007] WAN Drivers: Update farsync driver and
 introduce fsflex driver
Date: Wed, 18 Sep 2013 16:56:50 +0100
Message-ID: <1379519810.1522.36.camel@bwh-desktop.uk.level5networks.com>
References: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA5@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"Dermot Smith" <dermot.smith@farsite.com>
To: Kevin Curtis <Kevin.Curtis@farsite.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA5@SOLO.hq.farsitecommunications.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-18 at 11:12 +0100, Kevin Curtis wrote:
> Farsite Communications FarSync driver update
> 
> Patch 6 of 7
> 
> Introduce the fsflex driver.
> This driver is functionally equivalent to the farsync driver, and so
> can be used with the Generic HDLC, and ppp daemon.
> 
> Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>
> 
> ---
> diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/fsflex.c linux-3.10.1_new/drivers/net/wan/fsflex.c
> --- linux-3.10.1/drivers/net/wan/fsflex.c       1970-01-01 01:00:00.000000000 +0100
> +++ linux-3.10.1_new/drivers/net/wan/fsflex.c   2013-09-16 16:30:06.651104873 +0100
> @@ -0,0 +1,5693 @@
> +/*
> + *      FarSync Flex driver for Linux (2.6.x kernel version)

Not exactly...

[...]
> +#define FST_MAX_CARDS           32

I don't think it's acceptable to set a static limit on number of devices
in a new driver.

[...]
> +int fst_txq_low = FST_LOW_WATER_MARK;
> +int fst_txq_high = FST_HIGH_WATER_MARK;
> +int fst_min_dma_len = FST_MIN_DMA_LEN;
> +int fst_dmathr = 0xdd00dd00;
> +int fst_iocinfo_version = FST_VERSION_CURRENT;
> +int fst_max_reads = 7;
> +int fst_excluded_cards;
> +int fst_excluded_list[FST_MAX_CARDS];
> +int fst_num_serials;
> +char *fst_serials[FST_MAX_CARDS];

All of which should be declared static, not implicitly extern.  As
should all static variables and functions in this source file, as it's a
self-contained driver.

> +module_param(fst_txq_low, int, S_IRUGO);
> +module_param(fst_txq_high, int, S_IRUGO);
> +module_param(fst_min_dma_len, int, S_IRUGO);
> +module_param(fst_dmathr, int, S_IRUGO);
> +module_param(fst_iocinfo_version, int, S_IRUGO);
> +module_param(fst_max_reads, int, S_IRUGO);
> +module_param(fst_excluded_cards, int, S_IRUGO);
> +module_param_array(fst_excluded_list, int, NULL, S_IRUGO);
> +module_param_array(fst_serials, charp, &fst_num_serials, S_IRUGO);

Device configuration should be exposed through sysfs or ioctls, not
through module parameters.

[...]
> +#ifdef ARPHRD_RAWHDLC
> +#define ARPHRD_MYTYPE   ARPHRD_RAWHDLC /* Raw frames */
> +#else
> +#define ARPHRD_MYTYPE   ARPHRD_HDLC    /* Cisco-HDLC (keepalives etc) */
> +#endif

#ifdef is not necessary in-tree.

[...]
> +#define usb_buffer_alloc usb_alloc_coherent
> +#define usb_buffer_free usb_free_coherent

Don't make up your own names for USB functions.

[...]
> +static int __init fst_init(void)
> +{
[...]
> +       /* Create the /proc entry for /proc/fsflex
> +        */
> +       proc_create("fsflex", 0, NULL, &farsync_proc_fops);
[...]

Drivers should not be adding to the top level of /proc, and generally
should be adding any magic files under sysfs (per-device) or debugfs.

There is a /proc/driver directory if this information really doesn't fit
into either of those filesystems.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
