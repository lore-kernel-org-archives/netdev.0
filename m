From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Wed, 22 Apr 2015 15:34:12 -0700
Message-ID: <553821E4.5010901@gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>	<5537F9F1.1080008@gmail.com>	<CAHA+R7PVrxJ41WSqfO4mZSpCTGdJ++Gf757f_kq5z0UeMHXbXg@mail.gmail.com>	<553802DA.4050709@gmail.com>	<CAHA+R7PtzNd2asXFtiqsWyzCgeE1k_iF84358cvKg6ZCU-yVkQ@mail.gmail.com>	<553815DF.4000109@gmail.com> <CAHA+R7MMrrBYbQALovxuhcXrbiWjD_XpgohPXxTvNkcd3-R3WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32877 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934504AbbDVWeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:34:14 -0400
Received: by paboj16 with SMTP id oj16so685825pab.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 15:34:13 -0700 (PDT)
In-Reply-To: <CAHA+R7MMrrBYbQALovxuhcXrbiWjD_XpgohPXxTvNkcd3-R3WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 02:56 PM, Cong Wang wrote:
> On Wed, Apr 22, 2015 at 2:42 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 04/22/2015 01:33 PM, Cong Wang wrote:
>>> First, make sure you don't miss the TSIP case right above:
>>>
>>> The frag starting pointer and its size are advanced by:
>>>
>>> skb_frag_size_sub(frag, IGB_TS_HDR_LEN);
>>> ...
>>> va += IGB_TS_HDR_LEN;
>>>
>>> even though we unlikely pull header longer than
>>> IGB_RX_HDR_LEN - IGB_TS_HDR_LEN either.
>> So I believe this is a possible bug, one heck of a corner case to get
>> into though.  It requires timestamp in packet, size 240 - 256, and a
>> malformed header.
>>
>> The proper fix would probably be to pull the timestamp out of the packet
>> before we add it to the frame.  I'll submit a patch to address this.
>>
>
> Huh? Doesn't my patch already fix this? skb_frag_size() is always
> up to date. Or you mean another different problem?

Your patch has other issues.  I am still NAKing your patch, but there is
an issue with igb that you have pointed out.  The proper fix would be to
deal with the timestamp before we add the page fragment to the skb.

>
>>> Second, the check you mentioned above is:
>>>
>>> if ((size <= IGB_RX_HDR_LEN) && !skb_is_nonlinear(skb))
>>>
>>> skb is nonlinear _after_ the first igb_add_rx_frag(), a second
>>> igb_add_rx_frag() is possible since igb_is_non_eop() could
>>> return true.
>> I'm not sure this part makes any sense.  We pull the data out of the
>> first fragment always.  If skb_is_nonlinear is set then we should have
>> at least 2K - 16B in the case of igb.  We will never have a second
>> fragment without at least 2K of data being given in the first.
> Apparently my igb knowledge isn't enough to verify this, I just did
> logical analysis.

The logic with igb is that if skb_is_nonlinear it means that a page has
already been added.  The way the hardware works is that it will break a
frame up into 2K segments until the entire frame is written.  So the
only way to get a second page fragment is if the first has used the
entire 2K buffer it was given.

- Alex
