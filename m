From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Wed, 21 Nov 2012 22:47:39 -0500
Message-ID: <50ADA05B.2000308@pobox.com>
References: <20120602235020.2C0A57C006C@ra.kernel.org> <1353517042.26346.130.camel@shinybook.infradead.org> <50AD1972.5080403@pobox.com> <1353529639.26346.164.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:48519 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965018Ab2KVTOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 14:14:08 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so4969124vcm.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 11:14:07 -0800 (PST)
In-Reply-To: <1353529639.26346.164.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2012 03:27 PM, David Woodhouse wrote:
> This fixes (for me) a regression introduced by commit b01af457 ("8139cp:
> set ring address before enabling receiver"). That commit configured the
> descriptor ring addresses earlier in the initialisation sequence, in
> order to avoid the possibility of triggering stray DMA before the
> correct address had been set up.
>
> Unfortunately, it seems that the hardware will scribble garbage into the
> TxRingAddr registers when we enable "plus mode" Tx in the CpCmd
> register. Observed on a Traverse Geos router board.
>
> To deal with this, while not reintroducing the problem which led to the
> original commit, we augment cp_start_hw() to write to the CpCmd register
> *first*, then set the descriptor ring addresses, and then finally to
> enable Rx and Tx in the original 8139 Cmd register. The datasheet
> actually indicates that we should enable Tx/Rx in the Cmd register
> *before* configuring the descriptor addresses, but that would appear to
> re-introduce the problem that the offending commit b01af457 was trying
> to solve. And this variant appears to work fine on real hardware.
>
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Cc: stable@kernel.org [3.5+]
>
> ---
> How about this? I'm still somewhat confused about when it actually
> *does* start doing DMA, given what the datasheet says.

Well, we have three logical code states:

State A:  pre-b01af457, known working
State B:  b01af457, known broken
State C:  dwmw2 proposed fix, tested on 1 hardware, new technique, query 
open with Realtek

State A seems safer for late -rc, which is where we are.  Fix the 
regression by reverting to well-tested, widely deployed state.

Then apply your patch here as an immediate candidate for net-next.

	Jeff
