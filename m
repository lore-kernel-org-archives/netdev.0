From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcm80211: brcmfmac: Ensure that incoming skb's are
 writable
Date: Sun, 23 Apr 2017 21:34:45 +0200
Message-ID: <e2e5d950-d186-1a27-4b30-4ae2e9838103@broadcom.com>
References: <20170420111651.10213-1-james.hughes@raspberrypi.org>
 <b6891d80-cc5f-3bcd-72aa-1de2d9bb9144@broadcom.com>
 <CAE_XsMKSO=P-h5AyPJy=59zDq=DmLFqBAX8Bqsofey=aAFD5dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:33614 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045158AbdDWTey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 15:34:54 -0400
Received: by mail-it0-f42.google.com with SMTP id 70so8467326ita.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 12:34:54 -0700 (PDT)
In-Reply-To: <CAE_XsMKSO=P-h5AyPJy=59zDq=DmLFqBAX8Bqsofey=aAFD5dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21-4-2017 11:22, James Hughes wrote:
> On 20 April 2017 at 20:48, Arend van Spriel
> <arend.vanspriel@broadcom.com> wrote:
>> + linux-wireless
>>
>> On 4/20/2017 1:16 PM, James Hughes wrote:
>>>
>>> The driver was adding header information to incoming skb
>>> without ensuring the head was uncloned and hence writable.
>>>
>>> skb_cow_head has been used to ensure they are writable, however,
>>> this required some changes to error handling to ensure that
>>> if skb_cow_head failed it was not ignored.
>>>
>>> This really needs to be reviewed by someone who is more familiar
>>> with this code base to ensure any deallocation of skb's is
>>> still correct.
>>>
>>> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
>>> ---
>>>   .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    | 15 ++++++++--
>>>   .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 23 +++++-----------
>>>   .../broadcom/brcm80211/brcmfmac/fwsignal.c         | 32
>>> +++++++++++++++++-----
>>>   .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  7 ++++-
>>>   4 files changed, 51 insertions(+), 26 deletions(-)
>>>
>>
>> [...]
>>
>>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>>> b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>>> index 5eaac13..08272e8 100644
>>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>>> @@ -198,7 +198,7 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct
>>> sk_buff *skb,
>>>         int ret;
>>>         struct brcmf_if *ifp = netdev_priv(ndev);
>>>         struct brcmf_pub *drvr = ifp->drvr;
>>> -       struct ethhdr *eh = (struct ethhdr *)(skb->data);
>>> +       struct ethhdr *eh;
>>>         brcmf_dbg(DATA, "Enter, bsscfgidx=%d\n", ifp->bsscfgidx);
>>>   @@ -212,23 +212,14 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct
>>> sk_buff *skb,
>>>         }
>>>         /* Make sure there's enough room for any header */
>>> -       if (skb_headroom(skb) < drvr->hdrlen) {
>>> -               struct sk_buff *skb2;
>>> -
>>> -               brcmf_dbg(INFO, "%s: insufficient headroom\n",
>>> -                         brcmf_ifname(ifp));
>>> -               drvr->bus_if->tx_realloc++;
>>> -               skb2 = skb_realloc_headroom(skb, drvr->hdrlen);
>>> -               dev_kfree_skb(skb);
>>> -               skb = skb2;
>>> -               if (skb == NULL) {
>>> -                       brcmf_err("%s: skb_realloc_headroom failed\n",
>>> -                                 brcmf_ifname(ifp));
>>> -                       ret = -ENOMEM;
>>> -                       goto done;
>>> -               }
>>
>>
>> What you are throwing away here is code that assures there is sufficient
>> headroom for protocol and bus layer in the tx path, because that is
>> determined by drvr->hdrlen. This is where the skb is handed to the driver so
>> if you could leave the functionality above *and* assure it is writeable that
>> would be the best solution as there is no need for all the other changes
>> down the tx path.
> 
> The skb_cow_head function takes the required headroom as a parameter
> and will ensure that there is enough space, so I don't think this code
> segment is
> required or have I misunderstood what you mean here?

I looked more into what skb_cow_head() and skb_realloc_headroom()
actually do and it seems you are right.

> Is it safe to rely on the _cow_ being done here and not further down
> in the stack?
> Or at least checked further down in the stack. Previous comments from
> another patch
> requested that the _cow_ be done close to the actual addition of the
> header. I presume
> it is unlikely/impossible that the functions that add header
> information  down the stack
> will be called without the above being done first?

It is safe. During probe sequence each layer in the driver stack
increments drvr->hdrlen with headroom it needs. So drvr->hdrlen will
indicate the total headroom needed when .start_xmit() is called. And
yes, the .start_xmit() is the single point of entry in the transmit
path. So the other locations where skb_push() is done are safe.

>>
>>> +       ret = skb_cow_head(skb, drvr->hdrlen);
>>> +       if (ret) {
>>
>>
>> So move the realloc code above here instead of simply freeing the skb.
>>
>>> +               dev_kfree_skb_any(skb);
>>> +               goto done;
>>>         }
>>>   +     eh = (struct ethhdr *)(skb->data);
>>
>>
>> Now this is actually a separate fix so I would like a separate patch for it.
>>
> 
> No problem, but see final paragraph below.

Let me see...

>> I have a RPi3 sitting on my desk so how can I replicate the issue. It was
>> something about broadcast/multicast traffic when using AP mode and a bridge,
>> right?
>>
>> Regards,
>> Arend
> 
> See this issue for details on replication.
> https://github.com/raspberrypi/firmware/issues/673
> 
> The bridge I use is setup using a similar procedure to that described
> here.  https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md
> 
> I'm happy to pass over this work to you guys if you think it is
> appropriate, you are the
> experts on the codebase.

Sure. However, I must say you did an excellent job digging into the
issue and root causing it. We always were under the impression that we
could treat the skb as our own when handed to us in .start_xmit() callback.

Regards,
Arend
