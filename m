From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: Subject: [PATCH 3/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 22 Feb 2010 13:26:18 +0100
Message-ID: <20100222122618.GB2520@dhcp-lab-161.englab.brq.redhat.com>
References: <201002192152.o1JLqcNL031962@blc-10-1.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709Ab0BVM2P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 07:28:15 -0500
Content-Disposition: inline
In-Reply-To: <201002192152.o1JLqcNL031962@blc-10-1.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2010 at 01:52:38PM -0800, Rasesh Mody wrote:
> From: Rasesh Mody <rmody@brocade.com>
> 
> This is patch 3/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Source is based against net-next-2.6.
> 
> We wish this patch to be considered for inclusion in net-next-2.6
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  bfa_cee.c     |  459 +++++++++++++
>  bfa_csdebug.c |   55 +
>  bfa_ioc.c     | 1930 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  bfa_ioc_ct.c  |  416 ++++++++++++
>  bfa_sm.c      |   38 +
>  bna_if.c      |  524 +++++++++++++++
>  bna_iocll.h   |   60 +
>  bna_priv.h    |  472 ++++++++++++++
>  bnad_defs.h   |   37 +
>  cna.h         |   42 +
>  10 files changed, 4033 insertions(+)
[snip]
> +/**
> + * bfa_cee_attach()
> + *
> + *
> + * @param[in] cee - Pointer to the CEE module data structure
> + *            ioc - Pointer to the ioc module data structure
> + *            dev - Pointer to the device driver module data structure
> + *                  The device driver specific mbox ISR functions have
> + *                  this pointer as one of the parameters.
> + *            trcmod -
> + *            logmod -
> + *
> + * @return void
> + */
> +void
> +bfa_cee_attach(struct bfa_cee *cee, struct bfa_ioc *ioc,
> +		void *dev,
> +		struct bfa_trc_mod *trcmod,
> +		struct bfa_log_mod *logmod)
> +{
> +	cee->dev = dev;
> +	cee->trcmod = trcmod;
> +	cee->logmod = logmod;

We do not have trcmod, logmod in this driver anymore, please remove all
references to them.

> +#include "cs/bfa_debug.h"
> +#include "cna.h"
> +#include "cs/bfa_q.h"
> +
> +/**
> + *  cs_debug_api
> + */
> +
> +void
> +bfa_panic(int line, char *file, char *panicstr)
> +{
> +	pr_err("Assertion failure: %s:%d: %s", file, line, panicstr);
> +}
> +
> +void
> +bfa_sm_panic(struct bfa_log_mod *logm, int line, char *file, int event)
> +{
> +	pr_err("SM Assertion failure: %s:%d: event = %d",
> +			file, line, event);
> +}

If this is panic do panic not just print the message. I think you should
use BUG() instead of bfa_{sm_} panic.

> +static void
> +bfa_ioc_sm_hwinit_entry(struct bfa_ioc *ioc)
> +{
> +	mod_timer(&ioc->ioc_timer, jiffies +
> +	msecs_to_jiffies(BFA_IOC_TOV));

Do not break lines or use proper indention.

> +	bfa_ioc_reset(ioc, false);
> +}
> +
> +/**
> + * Hardware is being initialized. Interrupts are enabled.
> + * Holding hardware semaphore lock.
> + */
> +static void
> +bfa_ioc_sm_hwinit(struct bfa_ioc *ioc, enum ioc_event event)
> +{
> +
> +	switch (event) {
> +	case IOC_E_FWREADY:
> +		del_timer(&ioc->ioc_timer);
> +		bfa_fsm_set_state(ioc, bfa_ioc_sm_enabling);
> +		break;
> +
> +	case IOC_E_HWERROR:
> +		del_timer(&ioc->ioc_timer);
> +		/* fall through */
> +
> +	case IOC_E_TIMEOUT:
> +		ioc->retry_count++;
> +		if (ioc->retry_count < BFA_IOC_HWINIT_MAX) {
> +			mod_timer(&ioc->ioc_timer, jiffies +
> +	msecs_to_jiffies(BFA_IOC_TOV));

Here too, and in a few more places.

> +
> +enum bfa_ioc_type
> +bfa_ioc_get_type(struct bfa_ioc *ioc)
> +{
> +	if (!ioc->ctdev || ioc->fcmode)
> +		return BFA_IOC_TYPE_FC;
> +	else if (ioc->ioc_mc == BFI_MC_IOCFC)
> +		return BFA_IOC_TYPE_FCoE;
> +	else if (ioc->ioc_mc == BFI_MC_LL)
> +		return BFA_IOC_TYPE_LL;
> +	else {
> +		BUG_ON(!(ioc->ioc_mc == BFI_MC_LL));

Use BUG().

> +		return BFA_IOC_TYPE_LL;
> +	}
> +}
> +
> +void
> +bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num)
> +{
> +	memset((void *)serial_num, 0, BFA_ADAPTER_SERIAL_NUM_LEN);
> +	memcpy((void *)serial_num,

What for are (void *) casts in memcpy/memset?

> +enum bna_status bna_cleanup(void *bna_dev)

That exactly you should do :-) We are seeing and very appreciate your
current efforts, however more work need to be done regarding cleaning
up this driver (and BTW even more work with bfa).

> +#ifndef PCI_VENDOR_ID_BROCADE
> +#define PCI_VENDOR_ID_BROCADE	0x1657
> +#endif
> +
> +#ifndef PCI_DEVICE_ID_BROCADE_CATAPULT
> +#define PCI_DEVICE_ID_BROCADE_CATAPULT	0x0014
> +#endif

In linux we have include/linux/pci_ids.h files for that.

> +
> +#define PFX "BNA: "
> +#define DPRINTK(klevel, fmt, args...) do {  \
> +	printk(KERN_##klevel PFX fmt, ## args);      \
> +} while (0)

Is this used ?


