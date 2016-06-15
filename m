From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 14 Jun 2016 23:23:36 -0700
Message-ID: <20160615062336.GA26911@u54ee753d2d1854bda401.ant.amazon.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <20160614.222516.1192717052949905017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netanel@annapurnalabs.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:29002 "EHLO
	smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbcFOGXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 02:23:47 -0400
Content-Disposition: inline
In-Reply-To: <20160614.222516.1192717052949905017.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 10:25:16PM -0700, David Miller wrote:
> From: Netanel Belgazal <netanel@annapurnalabs.com>
> Date: Mon, 13 Jun 2016 11:46:13 +0300
> 
> > +#define ena_trc_dbg(format, arg...) \
> > +	pr_debug("[ENA_COM: %s] " format, __func__, ##arg)
> > +#define ena_trc_info(format, arg...) \
> > +	pr_info("[ENA_COM: %s] " format, __func__, ##arg)
> > +#define ena_trc_warn(format, arg...) \
> > +	pr_warn("[ENA_COM: %s] " format, __func__, ##arg)
> > +#define ena_trc_err(format, arg...) \
> > +	pr_err("[ENA_COM: %s] " format, __func__, ##arg)
> 
> These custom tracing macros are quite inappropriate.
> 
> We have the function tracer in the kernel when that is needed.  So spitting
> out __func__ all over the place is not something that should be found in
> drivers these days.

Point taken, though existing drivers (even fairly popular ones) also
aren't as clean as you might like. A quick look around...

msw@carbon:~/git/upstream/linux$ git grep -B1 '__func__' drivers/net/ethernet/ | grep -A1 '#define' 
drivers/net/ethernet/broadcom/bnx2x/bnx2x.h-#define BNX2X_ERROR(fmt, ...)	    			    	     \
drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:	    pr_err("[%s:%d]" fmt, __func__, __LINE__, ##__VA_ARGS__)
[...]
drivers/net/ethernet/intel/ixgb/ixgb_osdep.h:#define ENTER() pr_debug("%s\n", __func__);

Like many other network drivers, some of this is common code used for
non-Linux systems, and that's why there is some overlap with Linux
facilities. For example, here's the common ENA parts as it's situated
in DPDK as a PMD:

   http://dpdk.org/browse/dpdk/tree/drivers/net/ena/base/ena_com.c

When you compare to the DPDK version you can see that the common code
has already been contextualized for Linux in this patch in
anticipation of this type of feedback. (e.g., ENA_SPINLOCK_LOCK() ->
spin_lock_irqsave(), etc., as that would obviously never fly).

The Linux-specific bits (ena_netdev.c, ena_ethtool.c, etc.) don't make
use of any of the overlapping functionality needed for the common
code.

> And one can modify pr_fmt do make pr_debug et al. have whatever prefix
> one wants.

Yup, that's an easy improvement.

> I suspect there will be several rounds of review to weed out things
> like this.  You can preempt a lot of that by removing as much in your
> driver that the kernel has existing facilities for.

Are there other things that jump out at you? I felt like this was
pretty good for an initial submission in terms of striking a balance
between using a portable core while avoiding a lot of compatibility
shims.

--msw
