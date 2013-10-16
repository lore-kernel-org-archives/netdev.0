From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 0/5] net:stmmac: fix jumbo frames handling and optimisation
Date: Wed, 16 Oct 2013 22:37:19 +0200
Message-ID: <525EF8FF.2010206@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jimmy Perchet <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:50248 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761983Ab3JPUha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 16:37:30 -0400
In-Reply-To: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jimmy

On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
> Hello,
>
> I began using Synopsys IP few weeks ago and figured out that jumbo frames
> are not well supported by stmmac driver.

I tested jumbo on chips w/o enhanced some time ago, so welcome further
tests as you did (maybe on new chips).

>
> This patch series addresses several issues which prevent them from working
> properly :
> *(1/5) Threshold dma mode is needed on rx path if jumbo frames are expected.

hmm, this depends on the HW. In the past I used HW with a Fifo that is
16KiB for rx buffers and 8KiB for tx.

So this could be managed according to these sizes I guess...

>
> *(2/5) RX buffers are not allocated with the needed size because
> priv->dma_buf_sz is updated too late (i.e. after stmmac_init_rx_buffers call)

I'll look at the patch in detail

>
> *(3/5) On low speed link (10MBit/s), some TX descriptors can remain dirty
> if the tx coalescence timer expires before they were treated. Re-arm timer
> in this case.

hmm not clear to me, let me look at the patch. I hope the link should
not impact... never seen on my side.

>
> *(4/5) There is several confusions regarding descriptor's max buffer size,
> typically the "-1" is often forgotten.

also for this I need to look at the patch

> *(4/5) Jumbo frames' last descriptor is never "closed", resulting in truncated
> frames transfer.

it sounds to be a bug... let me check

> *(4/5) Frags could not be jumbo.
> Regarding these last points, I didn't find simpler way than writing
> new "prepare frame" functions for both ring and chain mode and update
> xmit function accordingly.

it is strange and not clear too. At any rate, both modes must be
supported

>
> The last patch is not related to jumbo frames but concern a possible
> optimisation :
> *(5/5) Tx descriptor's cleanup and preparation are serialized, which is not
> necessary and decrease performance. In addition TX descriptor's cleanup is
> performed on NET_-RX- softirq, this is confusing.
> By taking care of "cur_tx" and "dirty_tx" it is possible to avoid serialization
> and defer cleanup in workqueue.
> On my smp embedded system, with 1Gbit/s link which is cpu bound, it increases
> througput by about 90MBit/s (400MBit/s to 490MBit/s).

This sounds another good point, let me enter in the patch

BR
Peppe

>
>
> Best Regards,
> Jimmy Perchet
>
> Jimmy Perchet (5):
>    net:stmmac: set threshold/store and forward mode according to mtu
>      size.
>    net:stmmac: fix rx buffer allocation.
>    net:stmmac: ensure we reclaim all dirty descriptors.
>    net:stmmac: fix jumbo frame handling.
>    net:stmmac: asynchronous tx_clean
>
>   drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  99 +++++-----
>   drivers/net/ethernet/stmicro/stmmac/common.h      |   6 +
>   drivers/net/ethernet/stmicro/stmmac/descs_com.h   |   8 +-
>   drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   6 +
>   drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   6 +
>   drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |  90 ++++-----
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   6 +-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 219 +++++++++++++---------
>   8 files changed, 233 insertions(+), 207 deletions(-)
>
