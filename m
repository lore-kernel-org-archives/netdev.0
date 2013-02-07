From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC PATCH] tg3: Convert chip type macros to inline
 functions
Date: Wed, 6 Feb 2013 16:41:11 -0800
Message-ID: <1360197671.796.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1360194298.12464.35.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Hauke Mehrtens" <hauke@hauke-m.de>, mcarlson@broadcom.com,
	nsujir@broadcom.com
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4034 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247Ab3BGAlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 19:41:18 -0500
In-Reply-To: <1360194298.12464.35.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 15:44 -0800, Joe Perches wrote:
> There are several macros that are used for
> chip identification.
> 
> Perhaps it'd be better to use static inlines
> instead of these macros as the code becomes a
> bit more readable with less uppercase use.
> 
> It's neater, shorter, and maybe less error prone.
> 
> GET_ASIC_REV(tp->pci_chip_rev_id)       -> tg3_asic_rev(tp)
> GET_CHIP_REV(tp->pci_chip_rev_id)       -> tg3_chip_rev(tp)
> GET_METAL_REV(tp->pci_chip_rev_id)      -> tg3_metal_rev(tp) (unused)
> 
> For example:
> 
> #define GET_ASIC_REV(CHIP_REV_ID)       ((CHIP_REV_ID) >> 12)
> 
> becomes:
> 
> static inline u32 tg3_asic_rev(const struct tg3 *tp)
> {
>         return tp->pci_chip_rev_id >> 12;
> }
> 
> (this macro is only used as GET_ASIC_REV(tp->pci_chip_rev_id))
> 
> To me the negative to these conversions is at
> least for gcc 4.7.2, the overall code size
> increases
> 
> $ size drivers/net/ethernet/broadcom/tg3.o*
>    text    data     bss     dec     hex filename
>  203426   13446   55744  272616
> 428e8 drivers/net/ethernet/broadcom/tg3.o.new
>  202135   13446   55144  270725
> 42185 drivers/net/ethernet/broadcom/tg3.o.old
> 
> I'm not sure why gcc doesn't do the optimization
> and code generation the same way.  I expected it
> to and also tried __always_inline with the same
> compiled object size.  Looking at the .lst files
> doesn't give much clue _why_ these objects are
> different. 

I think these don't have to be inline.  there is only one call in the
fast path that I can see (tg3_start_xmit), and we can easily change that
to test for a flag instead.  I wonder if that will make it smaller.
