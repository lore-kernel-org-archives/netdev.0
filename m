From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: bridge: suppress broadcast when multicast flood is
 disabled
Date: Tue, 25 Apr 2017 17:03:55 +0300
Message-ID: <2dacca17-9c69-d4d2-df79-d9b5c8974e80@cumulusnetworks.com>
References: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
 <5266c6fd-54e9-01c7-2379-0b7f11a3cde3@cumulusnetworks.com>
 <a96ddd28-6d99-84d0-563a-2493a09a9e60@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        roopa <roopa@cumulusnetworks.com>
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38248 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1431412AbdDYOEE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:04:04 -0400
Received: by mail-wm0-f41.google.com with SMTP id r190so97479212wme.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 07:04:03 -0700 (PDT)
In-Reply-To: <a96ddd28-6d99-84d0-563a-2493a09a9e60@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/17 16:32, Mike Manning wrote:
> On 24/04/17 20:52, Nikolay Aleksandrov wrote:
>> On 24/04/17 17:09, Mike Manning wrote:
>>> Flood suppression for packets that are not unicast needs to be handled
>>> consistently by also not flooding broadcast packets. As broadcast is a
>>> special case of multicast, the same kernel parameter should be used to
>>> suppress flooding for both of these packet types.
>>>
>>> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
>>> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>>> ---
>>>  net/bridge/br_forward.c | 17 ++++++++++-------
>>>  1 file changed, 10 insertions(+), 7 deletions(-)
>>>
>>
>> I do not agree that this is a bug fix, the behaviour was intentional and is close to how HW
>> handles this flag. It has been like that for a few releases and changing it may impact setups
>> that use the flag since up until now they've seen the broadcast but not multicast packets and
>> suddenly their broadcast will stop.
>>
>> I think it would be better to introduce a third flag for bcast in net-next and use that to
>> filter it since that would give us the ability to program HW that can distinguish these
>> and have both options available, moreover it will not break any user setups relying on
>> the current flag behaviour and we have such setups.
>>
>> Thanks,
>>  Nik
>>
>>
> 
> Hi Nik,
> What is the usecase for flooding broadcast but not multicast please? Is the lack of flood
> suppression for broadcast just something that has not been explicitly tested for in those
> setups? This is the case for us, the bug raised only at this stage of the release cycle.
> While adding another kernel param is an option, I would only do so if absolutely necessary
> so as to avoid proliferation of params. Also to justify adding such a flag for broadcast
> suppression, I would need to add a comment to explain that while broadcast is a subset of
> multicast, the multicast flood suppression flag excludes broadcast.
> 
> Thanks
> Mike
> 

Hi Mike,
Stopping non-locally originating ARP requests is a pretty serious change
that affects many setups and changes the intended behaviour of this
option which was introduced specifically for unknown multicast flooding.
There're other options - you could filter the broadcast at the firewall
level, at least now you have that option but with this patch applied it
will be gone. Most network vendors differentiate the same types of
traffic as the ones listed below and allow to control them separately
which is much more flexible, I would like to keep it that way.

Currently the bridge differentiates intentionally between:
- known/unknown unicast controlled via fdbs/BR_FLOOD respectively
- known/unknown multicast controlled via mdbs/BR_MCAST_FLOOD respectively
- broadcast controlled only via firewall at this point

Fortunately the broadcast traffic doesn't have any dependent internal
state and can easily be controlled via the firewall thus rendering such
option unnecessary indeed, but I don't mind having it for completeness.
As for the comment, feel free to add it, I've actually added the exact
same comment some time ago in commit 8addd5e7d3a5 ("net: bridge: change
unicast boolean to exact pkt_type").

Cheers,
 Nik
