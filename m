From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/12] bnxt_en: Add XDP support.
Date: Tue, 07 Feb 2017 13:33:34 -0500 (EST)
Message-ID: <20170207.133334.2262808233886440285.davem@davemloft.net>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754951AbdBGTP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:15:56 -0500
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon,  6 Feb 2017 16:55:31 -0500

> The first 10 patches refactor the code (rx/tx code paths and ring logic)
> and add the basic infrastructure to support XDP.  The 11th patch adds
> basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 12th patch
> completes the series with XDP_TX.
> 
> Thanks to Andy Gospodarek for testing and uncovering some bugs.
> 
> v3: Removed Kconfig option.
>     Pass modified offset and length to stack for XDP_PASS.
>     Improved buffer recycling scheme for XDP_TX.
>     Other minor fixes.
> 
> v2: Addressed review comments from Alexei Starovoitov, Jakub Kicinski,
> and David Miller:
> 	- Added missing dma syncs.
> 	- Added XDP headroom support.
> 	- Added tracing in exception path.
> 	- Clarified a parameter change.

Series applied, thanks Michael.

You can probably push the XDP program existance check into an inline
helper to avoid the function call when XDP isn't being used:

bool __bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
		   struct page *page, u8 **data_ptr, unsigned int *len, u8 *event,
		   struct bpf_prog *xdp_prog);

static inline bool __bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
		                 struct page *page, u8 **data_ptr, unsigned int *len, u8 *event)
{
	struct bpf_prog *xdp_prog = READ_ONCE(rxr->xdp_prog);

	if (!xdp_prog)
		return false;
	return bnxt_rx_xdp(bp, rxr, cons, page, data_ptr, len, event, xdp_prog);
}
