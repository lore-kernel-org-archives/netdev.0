From: Arend van Spriel <arend@broadcom.com>
Subject: Re: brcmfmac: fix txglomming scatter-gather packet transfers
Date: Thu, 6 Mar 2014 09:51:46 +0100
Message-ID: <53183722.7000301@broadcom.com>
References: <20140305192636.D06AA660D72@gitolite.kernel.org> <20140306060936.GB26578@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <linux-coverity@vger.kernel.org>
To: Dave Jones <davej@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:35742 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbaCFIvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 03:51:50 -0500
In-Reply-To: <20140306060936.GB26578@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2014 07:09 AM, Dave Jones wrote:
> On Wed, Mar 05, 2014 at 07:26:36PM +0000, Linux Kernel wrote:
>  
>  > Commit:     1eb43018673e735ea9cd756970f4e71ca01a5f21
>  > Parent:     21f8aaee0c62708654988ce092838aa7df4d25d8
>  > Author:     Arend van Spriel <arend@broadcom.com>
>  > AuthorDate: Thu Feb 20 18:55:55 2014 +0100
>  > Committer:  John W. Linville <linville@tuxdriver.com>
>  > CommitDate: Thu Feb 20 15:53:20 2014 -0500
>  > 
>  >     brcmfmac: fix txglomming scatter-gather packet transfers
> 
> Coverity just flagged this code.
> 
>  >  	if (skb_tailroom(pkt) < tail_pad && pkt->len > blksize) {
>  > +		pkt_pad = brcmu_pkt_buf_get_skb(tail_pad + tail_chop +
>  > +						bus->head_align);
>  >  		if (pkt_pad == NULL)
>  >  			return -ENOMEM;
>  >  		ret = brcmf_sdio_txpkt_hdalign(bus, pkt_pad);
> 
> Right after this, I think we need the diff below or we leak pkt_pad.
> If this looks right, I'll submit it properly tomorrow.

Looks right to me so go ahead.

Regards,
Arend

> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
> index 119ee6eaf1c3..ddaa9efd053d 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
> @@ -1948,8 +1948,10 @@ static int brcmf_sdio_txpkt_prep_sg(struct brcmf_sdio *bus,
>  		if (pkt_pad == NULL)
>  			return -ENOMEM;
>  		ret = brcmf_sdio_txpkt_hdalign(bus, pkt_pad);
> -		if (unlikely(ret < 0))
> +		if (unlikely(ret < 0)) {
> +			kfree_skb(pkt_pad);
>  			return ret;
> +		}
>  		memcpy(pkt_pad->data,
>  		       pkt->data + pkt->len - tail_chop,
>  		       tail_chop);
> 
