From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Thu, 23 Apr 2015 11:06:10 -0700
Message-ID: <CAHA+R7O2p2VkA2KJ0QGaq4qa=BCAUFAYOQL_FByRUi=q1koQ_w@mail.gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
	<5537F9F1.1080008@gmail.com>
	<CAHA+R7PVrxJ41WSqfO4mZSpCTGdJ++Gf757f_kq5z0UeMHXbXg@mail.gmail.com>
	<553802DA.4050709@gmail.com>
	<CAHA+R7PtzNd2asXFtiqsWyzCgeE1k_iF84358cvKg6ZCU-yVkQ@mail.gmail.com>
	<553815DF.4000109@gmail.com>
	<CAHA+R7MMrrBYbQALovxuhcXrbiWjD_XpgohPXxTvNkcd3-R3WA@mail.gmail.com>
	<553821E4.5010901@gmail.com>
	<CAHA+R7MJv7tbHwU_ECbJunXVJ8uo=eQv+Xmw42oR5sKEde35RQ@mail.gmail.com>
	<553869C4.30107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:36363 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030383AbbDWSGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:06:11 -0400
Received: by wgen6 with SMTP id n6so26820160wge.3
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:06:10 -0700 (PDT)
In-Reply-To: <553869C4.30107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 8:40 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 04/22/2015 04:23 PM, Cong Wang wrote:
>> On Wed, Apr 22, 2015 at 3:34 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On 04/22/2015 02:56 PM, Cong Wang wrote:
>>>> On Wed, Apr 22, 2015 at 2:42 PM, Alexander Duyck
>>>> <alexander.duyck@gmail.com> wrote:
>>>>> On 04/22/2015 01:33 PM, Cong Wang wrote:
>>>>>> First, make sure you don't miss the TSIP case right above:
>>>>>>
>>>>>> The frag starting pointer and its size are advanced by:
>>>>>>
>>>>>> skb_frag_size_sub(frag, IGB_TS_HDR_LEN);
>>>>>> ...
>>>>>> va += IGB_TS_HDR_LEN;
>>>>>>
>>>>>> even though we unlikely pull header longer than
>>>>>> IGB_RX_HDR_LEN - IGB_TS_HDR_LEN either.
>>>>> So I believe this is a possible bug, one heck of a corner case to get
>>>>> into though.  It requires timestamp in packet, size 240 - 256, and a
>>>>> malformed header.
>>>>>
>>>>> The proper fix would probably be to pull the timestamp out of the packet
>>>>> before we add it to the frame.  I'll submit a patch to address this.
>>>>>
>>>> Huh? Doesn't my patch already fix this? skb_frag_size() is always
>>>> up to date. Or you mean another different problem?
>>> Your patch has other issues.  I am still NAKing your patch, but there is
>>> an issue with igb that you have pointed out.  The proper fix would be to
>>> deal with the timestamp before we add the page fragment to the skb.
>>>
>> If the first frag is always 2K, then this is not a problem either.
>> IGB_TS_HDR_LEN + IGB_RX_HDR_LEN < 2K.
>
> The problem is skb->tail will get screwed up.
>

Why? We don't copy timestamp into skb header, instead it is saved
in shared_info, why skb->tail matters here in TSIP case?


[...]

>
> The first frag will be 2K in size only if there are multiple frags.  The


Or it doesn't have frags at all since we just copy it to skb header, right?


> problem in the TSIP case is that we will put the size reported by the
> descriptor into the fragment, and then try to pull the size we


That size is saved when adding the frag, in TSIP case we just sub it
by IGB_TS_HDR_LEN, which seems correct.


> determined via eth_get_headlen.  So there is a window where that value
> can be wrong and result in data_len going negative and tail being moved
> beyond the end of the actual data.

This sounds like a different problem if you are saying we should sub
the size in the descriptor too. Therefore I don't see why your patch
could replace mine.
