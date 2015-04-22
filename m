From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Wed, 22 Apr 2015 14:56:41 -0700
Message-ID: <CAHA+R7MMrrBYbQALovxuhcXrbiWjD_XpgohPXxTvNkcd3-R3WA@mail.gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
	<5537F9F1.1080008@gmail.com>
	<CAHA+R7PVrxJ41WSqfO4mZSpCTGdJ++Gf757f_kq5z0UeMHXbXg@mail.gmail.com>
	<553802DA.4050709@gmail.com>
	<CAHA+R7PtzNd2asXFtiqsWyzCgeE1k_iF84358cvKg6ZCU-yVkQ@mail.gmail.com>
	<553815DF.4000109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38096 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbbDVV4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 17:56:43 -0400
Received: by wiun10 with SMTP id n10so72676314wiu.1
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 14:56:42 -0700 (PDT)
In-Reply-To: <553815DF.4000109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 2:42 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 04/22/2015 01:33 PM, Cong Wang wrote:
>> First, make sure you don't miss the TSIP case right above:
>>
>> The frag starting pointer and its size are advanced by:
>>
>> skb_frag_size_sub(frag, IGB_TS_HDR_LEN);
>> ...
>> va += IGB_TS_HDR_LEN;
>>
>> even though we unlikely pull header longer than
>> IGB_RX_HDR_LEN - IGB_TS_HDR_LEN either.
>
> So I believe this is a possible bug, one heck of a corner case to get
> into though.  It requires timestamp in packet, size 240 - 256, and a
> malformed header.
>
> The proper fix would probably be to pull the timestamp out of the packet
> before we add it to the frame.  I'll submit a patch to address this.
>


Huh? Doesn't my patch already fix this? skb_frag_size() is always
up to date. Or you mean another different problem?

>>
>> Second, the check you mentioned above is:
>>
>> if ((size <= IGB_RX_HDR_LEN) && !skb_is_nonlinear(skb))
>>
>> skb is nonlinear _after_ the first igb_add_rx_frag(), a second
>> igb_add_rx_frag() is possible since igb_is_non_eop() could
>> return true.
>
> I'm not sure this part makes any sense.  We pull the data out of the
> first fragment always.  If skb_is_nonlinear is set then we should have
> at least 2K - 16B in the case of igb.  We will never have a second
> fragment without at least 2K of data being given in the first.

Apparently my igb knowledge isn't enough to verify this, I just did
logical analysis.
