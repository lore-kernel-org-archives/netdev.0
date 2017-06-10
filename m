From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH v2] brcmfmac: Fix glom_skb leak in brcmf_sdiod_recv_chain
Date: Sat, 10 Jun 2017 21:27:11 +0200
Message-ID: <801f5209-f5a0-7414-f8f4-1500178a680b@broadcom.com>
References: <CA+8PC_e8HdkBw4DfGUPO0BbM-W5wftK=i6_vjwFTmS7=axyFUw@mail.gmail.com>
 <1496442569-11307-1-git-send-email-housel@acm.org>
 <CAHp75VcfK5V42vzsh=L+CnX2ZnF=8UORbOf+f2WfmcNH1DbAsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Franky Lin <franky.lin@broadcom.com>,
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
To: Andy Shevchenko <andy.shevchenko@gmail.com>,
        "Peter S. Housel" <housel@acm.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VcfK5V42vzsh=L+CnX2ZnF=8UORbOf+f2WfmcNH1DbAsw@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03-06-17 17:36, Andy Shevchenko wrote:
> On Sat, Jun 3, 2017 at 1:29 AM, Peter S. Housel <housel@acm.org> wrote:
>> An earlier change to this function (3bdae810721b) fixed a leak in the
>> case of an unsuccessful call to brcmf_sdiod_buffrw(). However, the
>> glom_skb buffer, used for emulating a scattering read, is never used
>> or referenced after its contents are copied into the destination
>> buffers, and therefore always needs to be freed by the end of the
>> function.

[snip]

>> +                       skb_queue_walk(pktq, skb) {
>> +                               memcpy(skb->data, glom_skb->data, skb->len);
>> +                               skb_pull(glom_skb, skb->len);
>> +                       }
>>                 }
> 
>> +               brcmu_pkt_buf_free_skb(glom_skb);
> 
> Can we just add this one line instead or I'm missing something?

I guess. We don't want to walk the packet queue if glom_skb is not
carrying data due to brcmf_sdiod_buffrw() failure.

So I would go with the patch below as brcmu_pkt_buf_free_skb() simply
ignores null pointer.

Regards,
Arend
---
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
index 5bc2ba2..3722f23 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c
@@ -705,7 +705,7 @@ int brcmf_sdiod_recv_pkt(struct brcmf_sdio_dev
*sdiodev, struct sk_buff *pkt)
 int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev *sdiodev,
                           struct sk_buff_head *pktq, uint totlen)
 {
-       struct sk_buff *glom_skb;
+       struct sk_buff *glom_skb = NULL;
        struct sk_buff *skb;
        u32 addr = sdiodev->sbwad;
        int err = 0;
@@ -726,10 +726,8 @@ int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev
*sdiodev,
                        return -ENOMEM;
                err = brcmf_sdiod_buffrw(sdiodev, SDIO_FUNC_2, false, addr,
                                         glom_skb);
-               if (err) {
-                       brcmu_pkt_buf_free_skb(glom_skb);
+               if (err)
                        goto done;
-               }

                skb_queue_walk(pktq, skb) {
                        memcpy(skb->data, glom_skb->data, skb->len);
@@ -740,6 +738,7 @@ int brcmf_sdiod_recv_chain(struct brcmf_sdio_dev
*sdiodev,
                                            pktq);

 done:
+       brcmu_pkt_buf_free_skb(glom_skb);
        return err;
 }
