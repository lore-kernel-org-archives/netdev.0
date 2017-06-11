From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2] brcmfmac: Fix glom_skb leak in brcmf_sdiod_recv_chain
Date: Sun, 11 Jun 2017 16:49:50 +0300
Message-ID: <CAHp75VfSagtTco5qnMLyNRcmWMcf7h3RAAa9wmgKGCfB3ees_Q@mail.gmail.com>
References: <CA+8PC_e8HdkBw4DfGUPO0BbM-W5wftK=i6_vjwFTmS7=axyFUw@mail.gmail.com>
 <1496442569-11307-1-git-send-email-housel@acm.org> <CAHp75VcfK5V42vzsh=L+CnX2ZnF=8UORbOf+f2WfmcNH1DbAsw@mail.gmail.com>
 <801f5209-f5a0-7414-f8f4-1500178a680b@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Peter S. Housel" <housel@acm.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Christian Daudt <csd@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <801f5209-f5a0-7414-f8f4-1500178a680b@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2017 at 10:27 PM, Arend van Spriel
<arend.vanspriel@broadcom.com> wrote:
> On 03-06-17 17:36, Andy Shevchenko wrote:
>> On Sat, Jun 3, 2017 at 1:29 AM, Peter S. Housel <housel@acm.org> wrote:

The following looks good to me.
Feel free to add
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
> @@ -705,7 +705,7 @@ int brcmf_sdiod_recv_pkt(struct brcmf_sdio_dev
> *sdiodev, struct sk_buff *pkt)
>  int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev *sdiodev,
>                            struct sk_buff_head *pktq, uint totlen)
>  {
> -       struct sk_buff *glom_skb;
> +       struct sk_buff *glom_skb = NULL;
>         struct sk_buff *skb;
>         u32 addr = sdiodev->sbwad;
>         int err = 0;
> @@ -726,10 +726,8 @@ int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev
> *sdiodev,
>                         return -ENOMEM;
>                 err = brcmf_sdiod_buffrw(sdiodev, SDIO_FUNC_2, false, addr,
>                                          glom_skb);
> -               if (err) {
> -                       brcmu_pkt_buf_free_skb(glom_skb);
> +               if (err)
>                         goto done;
> -               }
>
>                 skb_queue_walk(pktq, skb) {
>                         memcpy(skb->data, glom_skb->data, skb->len);
> @@ -740,6 +738,7 @@ int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev
> *sdiodev,
>                                             pktq);
>
>  done:
> +       brcmu_pkt_buf_free_skb(glom_skb);
>         return err;
>  }
>



-- 
With Best Regards,
Andy Shevchenko
