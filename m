From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] brcmfmac: Fix glob_skb leak in brcmf_sdiod_recv_chain
Date: Fri, 2 Jun 2017 11:48:22 -0700
Message-ID: <867d5fe1-3419-7d7b-6e2a-e79261cf7681@gmail.com>
References: <1496424146-10928-1-git-send-email-housel@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "Peter S. Housel" <housel@acm.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Christian Daudt <csd@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496424146-10928-1-git-send-email-housel@acm.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2017 10:22 AM, Peter S. Housel wrote:
> An earlier change to this function (3bdae810721b) fixed a leak in the
> case of an unsuccessful call to brcmf_sdiod_buffrw(). However, the
> glob_skb buffer, used for emulating a scattering read, is never used
> or referenced after its contents are copied into the destination
> buffers, and therefore always needs to be freed by the end of the
> function.

That looks correct, could you add the relevant Fixes tag for this?

Fixes: 3bdae810721b ("brcmfmac: Fix glob_skb leak in
brcmf_sdiod_recv_chain")
Fixes: a413e39a38573 ("brcmfmac: fix brcmf_sdcard_recv_chain() for host
without sg support")

BTW, you made the same typo that I did, it's actually glom_skb ;)

> 
> Signed-off-by: Peter S. Housel <housel@acm.org>
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> index 9b970dc..4c5064f 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> @@ -727,15 +727,16 @@ int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev *sdiodev,
>  			return -ENOMEM;
>  		err = brcmf_sdiod_buffrw(sdiodev, SDIO_FUNC_2, false, addr,
>  					 glom_skb);
> -		if (err) {
> -			brcmu_pkt_buf_free_skb(glom_skb);
> -			goto done;
> -		}
> +		if (err)
> +			goto free_glom_skb;
>  
>  		skb_queue_walk(pktq, skb) {
>  			memcpy(skb->data, glom_skb->data, skb->len);
>  			skb_pull(glom_skb, skb->len);
>  		}
> +
> +free_glom_skb:
> +		brcmu_pkt_buf_free_skb(glom_skb);
>  	} else
>  		err = brcmf_sdiod_sglist_rw(sdiodev, SDIO_FUNC_2, false, addr,
>  					    pktq);
> 


-- 
Florian
