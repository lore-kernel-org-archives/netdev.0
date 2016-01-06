From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 2/2] geneve: break dependency to network drivers
Date: Wed, 6 Jan 2016 13:01:28 -0800
Message-ID: <CAEh+42gOhXgB=M-nxQcGN6yGwnk3vwFEOwkAKdfE3vpLQ=LZ5w@mail.gmail.com>
References: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org>
 <1452094903-12934-3-git-send-email-hannes@stressinduktion.org>
 <CAEh+42j2w6t7+WNN9y0k6M5Ld+14B2txCkfLw6zwrR04+i8Xqw@mail.gmail.com>
 <568D6188.4090705@stressinduktion.org> <CAEh+42iA+ReWfxLHHXOx5cYCDhrFyRkFwvPqrMfbGj+UK-nxYw@mail.gmail.com>
 <568D782D.4000602@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37643 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbcAFVBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 16:01:48 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 90BCE2017E
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 21:01:47 +0000 (UTC)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 051AD20172
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 21:01:44 +0000 (UTC)
Received: by mail-qk0-f178.google.com with SMTP id h11so21283009qke.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 13:01:43 -0800 (PST)
In-Reply-To: <568D782D.4000602@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 12:25 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 06.01.2016 20:52, Jesse Gross wrote:
>> On Wed, Jan 6, 2016 at 10:48 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> On 06.01.2016 19:00, Jesse Gross wrote:
>>>> Unfortunately, I don't think that we can assume that RTNL is held
>>>> here. It actually is for the drivers that implement Geneve at this
>>>> point but not in all cases for VXLAN. For example, ixgbe refreshes the
>>>> offloads in a service task in addition to when it is opened. There's
>>>> only a couple instances of things like this, so I guess it's probably
>>>> not too hard to through and make sure that we hold RTNL in those
>>>> cases.
>>>
>>>
>>>
>>> Hmm, I am tempted to switch over to the netevent atomic notifier chain
>>> and
>>> install those events there. It does not need rtnl lock at all, so we can
>>> preserve the current semantics. What do you think?
>>
>>
>> I think that holding RTNL while we do these updates is actually the
>> right thing to do. The current situation of having calls from
>> different protocols protected by different locks is not really a great
>> model given that at the driver level these are usually shared data
>> structures. RTNL is already held in the majority of cases already, so
>> I think it is better to just convert the rest.
>
>
> The refreshes from each module are completely synchronous and don't get
> interleaved, so as long as the driver is correctly handling the locking
> internally rtnl lock shouldn't be needed. But as I don't know too much about
> driver developing I can revisit this.
>
> As a advantage I see that the driver developers don't need to worry about
> the rtnl lock at all when adding new events. Is this realistic?

I don't think that there is much savings to be had by avoiding RTNL
since the majority of interactions that the driver has with the stack
involve holding it anyways.

In order to do this safely without RTNL we need to have a lock in each
driver. I don't think that this is safely handled in all cases today
and is likely to get worse in the future. I also noticed that Geneve
actually doesn't hold any special lock while calling into drivers from
geneve_get_rx_port() so it is de-facto relying on RTNL. All other
operations in the Geneve driver are protected by RTNL currently, so we
would need to introduce a new lock to handle this as well. In effect,
it seems like people are implicitly assuming that these operations are
covered by RTNL since most similar things are.
