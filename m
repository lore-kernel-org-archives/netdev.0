From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/3] net: bcmgenet: fix off-by-one in incrementing
 read pointer
Date: Fri, 10 Oct 2014 10:18:20 -0700
Message-ID: <543814DC.3050303@gmail.com>
References: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>	<1412903197-19193-2-git-send-email-f.fainelli@gmail.com>	<CAGXr9JHBVW9rOiSUCCsVnYp73OPdyynP35xiAnKjRsVCf8fK9Q@mail.gmail.com>	<54380C29.9010704@gmail.com> <CAGXr9JEm4Dmo5QYhsv7ydr8NBujtrJ=gJ9kxSFoiBQ-YVQkGBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:63337 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbaJJRSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 13:18:31 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so2025713pdb.30
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 10:18:30 -0700 (PDT)
In-Reply-To: <CAGXr9JEm4Dmo5QYhsv7ydr8NBujtrJ=gJ9kxSFoiBQ-YVQkGBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 10:17 AM, Petri Gynther wrote:
> On Fri, Oct 10, 2014 at 9:41 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 10/09/2014 11:01 PM, Petri Gynther wrote:
>>> Hi Florian,
>>>
>>> On Thu, Oct 9, 2014 at 6:06 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>> Commit b629be5c8399d7c423b92135eb43a86c924d1cbc ("net: bcmgenet: check
>>>> harder for out of memory conditions") moved the increment of the local
>>>> read pointer *before* reading from the hardware descriptor using
>>>> dmadesc_get_length_status(), which creates an off-by-one situation.
>>>>
>>>> Fix this by moving again the read_ptr increment after we have read the
>>>> hardware descriptor to get both the control block and the read pointer
>>>> back in sync.
>>>>
>>>> Fixes: b629be5c8399 ("net: bcmgenet: check harder for out of memory conditions")
>>>> Reported-by: Jaedon Shin <jaedon.shin@gmail.com>
>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>> ---
>>>>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 +++---
>>>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>>>> index fff2634b6f34..f1bcebcbba80 100644
>>>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>>>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>>>> @@ -1287,9 +1287,6 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>>>>
>>>>                 rxpktprocessed++;
>>>>
>>>> -               priv->rx_read_ptr++;
>>>> -               priv->rx_read_ptr &= (priv->num_rx_bds - 1);
>>>> -
>>>
>>> Wouldn't it be better to move the three lines:
>>> rxpktprocessed++;
>>> priv->rx_read_ptr++;
>>> priv->rx_read_ptr &= (priv->num_rx_bds - 1)
>>>
>>> as the last lines of the while-loop, after the CB refill?
>>
>> That's basically what Jaedon did in his first patch, I don't have strong
>> objections in doing that if you think that makes it look clearer.
>>
> 
> I feel that this would be cleaner approach. First do the work (or skip
> to refill), then increment necessary variables, and go back to the
> while-loop.

Sounds good, I will re-submit shortly, thanks!

> 
>>>
>>> -- Petri
>>>
>>>
>>>>                 /* We do not have a backing SKB, so we do not have a
>>>>                  * corresponding DMA mapping for this incoming packet since
>>>>                  * bcmgenet_rx_refill always either has both skb and mapping or
>>>> @@ -1332,6 +1329,9 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
>>>>                           __func__, p_index, priv->rx_c_index,
>>>>                           priv->rx_read_ptr, dma_length_status);
>>>>
>>>> +               priv->rx_read_ptr++;
>>>> +               priv->rx_read_ptr &= (priv->num_rx_bds - 1);
>>>> +
>>>>                 if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
>>>>                         netif_err(priv, rx_status, dev,
>>>>                                   "dropping fragmented packet!\n");
>>>> --
>>>> 1.9.1
>>>>
>>
