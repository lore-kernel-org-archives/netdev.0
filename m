From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Fri, 6 Feb 2015 21:53:14 -0800
Message-ID: <CAE4R7bCKGz86m2VaUMCYhQZjUTviZsSQbYey+HG2EWLBtEMbHg@mail.gmail.com>
References: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
	<54D246A7.2020502@cumulusnetworks.com>
	<CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
	<20150204.235308.71797582017426266.davem@davemloft.net>
	<CA+CtxLRaJ+p=y1LCgap48vqH3b4VjxKQO55Yy5cyazng4WtxPw@mail.gmail.com>
	<CAN+pFwJQQMFmmm1f7tSPCmaSr2GE_L8Pua+Rz7tvK9CFnr63Tg@mail.gmail.com>
	<CAE4R7bBKXHfbOz-BT1jW2=+hTi=6hZZHRUVpYUvOj1yF+XEtUw@mail.gmail.com>
	<CAE4R7bDRHwUnt7jzPw_CzwsZfou2B2mRgZ_9t4AfRWe2Z_EtYg@mail.gmail.com>
	<CAN+pFwKAWX+En6zK3Q94q9ejdpqz6WBvnkH=Rp3HBEAeOyNbNw@mail.gmail.com>
	<CAE4R7bDypUjrSAned55XRpcp+iEHNkF7H_8JJy63jt+5Hd3Pzg@mail.gmail.com>
	<CA+CtxLTewFxJNH0OTCqcGb31Ov=TZMwDtz=H11My1NKY=tb9Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: B Viswanath <marichika4@gmail.com>,
	David Miller <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:37193 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbBGFxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 00:53:16 -0500
Received: by mail-we0-f171.google.com with SMTP id k11so17424339wes.2
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 21:53:14 -0800 (PST)
In-Reply-To: <CA+CtxLTewFxJNH0OTCqcGb31Ov=TZMwDtz=H11My1NKY=tb9Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 5, 2015 at 7:27 PM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
> On Fri, Feb 6, 2015 at 7:15 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>> On Thu, Feb 5, 2015 at 10:31 AM, B Viswanath <marichika4@gmail.com> wrote:
>>> On 5 February 2015 at 23:25, Scott Feldman <sfeldma@gmail.com> wrote:
>>> <snip>
>>>>
>>>> CONs
>>>>
>>>> 1) Scale-ability.  The bridge driver can't keep up with ageing many
>>>> (10^5, for example) entries.
>>>> 2) Scale-ability.  Keeping the entries periodically refreshed requires
>>>> a refresh sync from
>>>> the device to the bridge driver, and the bridge driver/kernel can't keep up.
>>>> 3) With the bridge driver, the ageing settings are per-bridge, not per-port.
>>>>
>>>> Did I miss any points?
>>>
>>> There is one more
>>>
>>> 4. On links with wirespeed traffic, software ageing FDB entries
>>> independently without having the knowledge of the traffic means that
>>> CPU will ageout entries it should not. I don't know if this breaks
>>> some RFC, but it can certainly cause big packet loss.
>>
>> SW would only age out expired entries.  An entry not refreshed by HW
>> will expire.  But HW will refresh (to SW) active entries based on
>> traffic seen.  So I'm not seeing how SW will age out entries
>> prematurely.  I'm missing something.
>
> Hardware does not refresh(to SW) active entries based on the traffic
> seen, at least on the switches that I worked on. Even if it were to
> refresh, if the traffic is flowing at line rate(say x packets per
> sec), the refresh rate to SW is equal to x, which is very huge for cpu
> to handle.

I meant refresh as in re-sending learn notification for entry on a
periodic basis, say once a second.  Not refreshing by presenting pkt
to SW...that wouldn't scale at all, as you say.

> There are only two notifications to SW.
>
> 1)learn notification(when packet arrives that has smac which is not in
> hardware's FDB)
> 2)When the hardware ages the entry, it sends a age notification.

I think I'm coming around to your thinking of letting HW manage ageing
on HW-learned FDB entries.  I was hoping to keep ageing in SW for the
PROs I mentioned earlier, but it's not aligning very well with real
HW.  If we modify rocker to work like real HW (that was the point of
rocker in the first place), then we can re-introduce your patch to let
bridge ignore ageing on entries marked with added_by_external_learn.
Let me work on the rocker mods and followup.

-scott
