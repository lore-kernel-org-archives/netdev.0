From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Wed, 22 Apr 2015 14:42:55 -0700
Message-ID: <553815DF.4000109@gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>	<5537F9F1.1080008@gmail.com>	<CAHA+R7PVrxJ41WSqfO4mZSpCTGdJ++Gf757f_kq5z0UeMHXbXg@mail.gmail.com>	<553802DA.4050709@gmail.com> <CAHA+R7PtzNd2asXFtiqsWyzCgeE1k_iF84358cvKg6ZCU-yVkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35519 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757969AbbDVVm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 17:42:57 -0400
Received: by pdbqd1 with SMTP id qd1so285746656pdb.2
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 14:42:57 -0700 (PDT)
In-Reply-To: <CAHA+R7PtzNd2asXFtiqsWyzCgeE1k_iF84358cvKg6ZCU-yVkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 01:33 PM, Cong Wang wrote:
> On Wed, Apr 22, 2015 at 1:21 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 04/22/2015 01:14 PM, Cong Wang wrote:
>>> On Wed, Apr 22, 2015 at 12:43 PM, Alexander Duyck
>>> <alexander.duyck@gmail.com> wrote:
>>>> On 04/22/2015 10:45 AM, Cong Wang wrote:
>>>>> The second parameter of eth_get_headlen() is the length of
>>>>> the frame buffer, not the header length of skb.
>>>>>
>>>>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>>>> ---
>>>>>  drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
>>>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>>>>> index a0a9b1f..7b3a370 100644
>>>>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>>>>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>>>>> @@ -6852,7 +6852,9 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
>>>>>       /* we need the header to contain the greater of either ETH_HLEN or
>>>>>        * 60 bytes if the skb->len is less than 60 for skb_pad.
>>>>>        */
>>>>> -     pull_len = eth_get_headlen(va, IGB_RX_HDR_LEN);
>>>>> +     pull_len = eth_get_headlen(va, skb_frag_size(frag));
>>>>> +     if (unlikely(pull_len > IGB_RX_HDR_LEN))
>>>>> +             pull_len = IGB_RX_HDR_LEN;
>>>>>
>>>>>       /* align pull length to size of long to optimize memcpy performance */
>>>>>       skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>>>> You have this part right.  The length represents the maximum length we
>>>> are willing to traverse in the buffer.  So if we 100% want to get the
>>>> entire header regardless of what we can copy into then we could follow
>>>> your approach.  However, since the allocated space in the skb is only
>>>> IGB_RX_HDR_LEN we only really want to traverse up to that length.  Then
>>>> that is all we copy out of the header.
>>> But the frag size could be smaller than IGB_RX_HDR_LEN which is
>>> the case this patch tries to fix.
>> No it can't.  We only add frags if the first frag is larger than
>> IGB_RX_HDR_LEN.  Go look at the code where this driver calls
>> add_rx_frag.  You should find there is copybreak code in there that
>> kicks in for anything less than or equal to IGB_RX_HDR_LEN in size on
>> the first frag.  It is there to allow us to avoid having to perform an
>> atomic inc/dec on the page.
>>
> First, make sure you don't miss the TSIP case right above:
>
> The frag starting pointer and its size are advanced by:
>
> skb_frag_size_sub(frag, IGB_TS_HDR_LEN);
> ...
> va += IGB_TS_HDR_LEN;
>
> even though we unlikely pull header longer than
> IGB_RX_HDR_LEN - IGB_TS_HDR_LEN either.

So I believe this is a possible bug, one heck of a corner case to get
into though.  It requires timestamp in packet, size 240 - 256, and a
malformed header.

The proper fix would probably be to pull the timestamp out of the packet
before we add it to the frame.  I'll submit a patch to address this.

>
> Second, the check you mentioned above is:
>
> if ((size <= IGB_RX_HDR_LEN) && !skb_is_nonlinear(skb))
>
> skb is nonlinear _after_ the first igb_add_rx_frag(), a second
> igb_add_rx_frag() is possible since igb_is_non_eop() could
> return true.

I'm not sure this part makes any sense.  We pull the data out of the
first fragment always.  If skb_is_nonlinear is set then we should have
at least 2K - 16B in the case of igb.  We will never have a second
fragment without at least 2K of data being given in the first.

- Alex
