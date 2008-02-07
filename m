From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 3/4] ctcm: infrastructure for replaced ctc driver
Date: Thu, 7 Feb 2008 01:35:34 -0500
Message-ID: <20080207063534.GB27498@infradead.org>
References: <20080206182723.103842000@linux.vnet.ibm.com> <20080206183023.042552000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, Peter Tiedemann <ptiedem@de.ibm.com>
To: Ursula Braun <braunu@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44381 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbYBGGfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 01:35:40 -0500
Content-Disposition: inline
In-Reply-To: <20080206183023.042552000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 07:27:26PM +0100, Ursula Braun wrote:
> From: Peter Tiedemann <ptiedem@de.ibm.com>
> 
> ctcm driver supports the channel-to-channel connections of the
> old ctc driver plus an additional MPC protocol to provide SNA
> connectivity.
> 
> This new ctcm driver replaces the existing ctc driver.
> 
> Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>
> ---
> 
>  drivers/s390/net/Kconfig      |   12 
>  drivers/s390/net/Makefile     |    5 
>  drivers/s390/net/ctcm_dbug.c  |   67 +
>  drivers/s390/net/ctcm_dbug.h  |  158 ++
>  drivers/s390/net/ctcm_fsms.c  | 2338 +++++++++++++++++++++++++++++++++++++++
>  drivers/s390/net/ctcm_fsms.h  |  359 ++++++
>  drivers/s390/net/ctcm_main.c  | 1772 ++++++++++++++++++++++++++++++
>  drivers/s390/net/ctcm_main.h  |  287 ++++
>  drivers/s390/net/ctcm_mpc.c   | 2467 ++++++++++++++++++++++++++++++++++++++++++
>  drivers/s390/net/ctcm_mpc.h   |  239 ++++
>  drivers/s390/net/ctcm_sysfs.c |  210 +++
>  11 files changed, 7906 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6-uschi/drivers/s390/net/Makefile
> ===================================================================
> --- linux-2.6-uschi.orig/drivers/s390/net/Makefile
> +++ linux-2.6-uschi/drivers/s390/net/Makefile
> @@ -2,11 +2,10 @@
>  # S/390 network devices
>  #
>  
> -ctc-objs := ctcmain.o ctcdbug.o
> -
> +ctcm-objs := ctcm_main.o ctcm_fsms.o ctcm_mpc.o ctcm_sysfs.o ctcm_dbug.o

please don't use foo-objs := but always foo-y +=

> Index: linux-2.6-uschi/drivers/s390/net/ctcm_dbug.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6-uschi/drivers/s390/net/ctcm_dbug.c
> @@ -0,0 +1,67 @@
> +/*
> + *	drivers/s390/net/ctcm_dbug.c
> + *
> + *	Copyright IBM Corp. 2001, 2007
> + *	Authors:	Peter Tiedemann (ptiedem@de.ibm.com)
> + *
> + */

Please don't mention filenames in the top of file comments.
On the other hand a little description of what this file
does would be quite useful.  (This comment applies to all
files in this patch)

> +#ifdef DEBUG
> +	#define do_debug 1
> +#else
> +	#define do_debug 0
> +#endif
> +#ifdef DEBUGDATA
> +	#define do_debug_data 1
> +#else
> +	#define do_debug_data 0
> +#endif
> +#ifdef DEBUGCCW
> +	#define do_debug_ccw 1
> +#else
> +	#define do_debug_ccw 0
> +#endif

Please don't indent cpp directives with tabs.  Normally we don't indent
them at all, but if we have to it's just a single space after the # per
indentiation level.

> +static void chx_rxidle(fsm_instance *fi, int event, void *arg);

Please don't put forward declarations in the middle of a file.
If you have to have them please put all somewhere at the top of the
file, but it would be even nicer to re-order the code to avoid
them completely.

> +/**
> + * Initialize connection by sending a __u16 of value 0.
> + *
> + * @param fi	An instance of a channel statemachine.
> + * @param event The event, just happened.
> + * @param arg	Generic pointer, casted from channel * upon call.
> + */

This is not a kerneldoc comment.  Please read
Documentation/kernel-doc-nano-HOWTO.txt for the correct format, and run
it through the extraction script to make sure it's valid.

> +static void chx_firstio(fsm_instance *fi, int event, void *arg)
> +{
> +	struct channel *ch = (struct channel *)arg;

no cast needed when converting to/from void *

> +	struct channel *ch = (struct channel *)arg;
> +	struct channel *ch2;
> +	struct net_device *dev = ch->netdev;
> +
> +	CTCM_DBF_DEV_NAME(TRACE, dev, "Got remote disconnect, re-initializing");
> +	fsm_deltimer(&ch->timer);
> +	if (do_debug)
> +		ctcm_pr_debug("%s: Got remote disconnect, "
> +				"re-initializing ...\n", dev->name);
> +	/*
> +	 * Notify device statemachine
> +	 */
> +	fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_RXDOWN, dev);
> +	fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_TXDOWN, dev);
> +
> +	fsm_newstate(fi, CTC_STATE_DTERM);
> +	ch2 = ((struct ctcm_priv *)dev->priv)->channel[WRITE];

keeping a local variable of type struct ctcm_priv * would be a lot
cleaner than all these casts.  This applies to a lot of functions all
over this patch.

> +	fsm_newstate(ch2->fsm, CTC_STATE_DTERM);
> +
> +	ccw_device_halt(ch->cdev, (unsigned long)ch);
> +	ccw_device_halt(ch2->cdev, (unsigned long)ch2);

what an odd calling convention. Why does ccw_device_halt take an
unsigned long argument that's actually a pointer?

> +	header = kzalloc(TH_HEADER_LENGTH, gfp_type());
> +
> +	if (!header) {
> +		printk(KERN_WARNING "ctcmpc: OUT OF MEMORY IN %s()"
> +		       ": Data Lost \n", __FUNCTION__);
> +		spin_unlock(&ch->collect_lock);
> +		fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
> +				goto done;

odd indentation messup.

> +				min((int)ch->trans_skb->len, 50));

please don't case arguments to min but use min_t instead.


I gave up here for now, but you should probably run this through
checkpatch.pl aswell before resubmitting it.
