From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: bridge: add per-port group_fwd_mask with
 less restrictions
Date: Fri, 29 Sep 2017 15:21:59 -0700
Message-ID: <CAJieiUhqPL4XudHYFiAQR2UjV7LSAk44GTtUjkPsq3MDpWRwJA@mail.gmail.com>
References: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170929081420.3b069170@xeon-e3> <e9a70870-9b6b-0ec4-de1e-d41da80fd10f@cumulusnetworks.com>
 <20170929145103.1e30f73c@xeon-e3> <5dd9e4e8-466d-47dc-1257-09823ba783b9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:49072 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752155AbdI2WWB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 18:22:01 -0400
Received: by mail-ua0-f181.google.com with SMTP id v12so575646uaf.5
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 15:22:00 -0700 (PDT)
In-Reply-To: <5dd9e4e8-466d-47dc-1257-09823ba783b9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 3:11 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 30/09/17 00:51, Stephen Hemminger wrote:
>> On Sat, 30 Sep 2017 00:01:24 +0300
>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>
>>> On 29/09/17 18:14, Stephen Hemminger wrote:
>>>> On Wed, 27 Sep 2017 16:12:44 +0300
>>>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>>>
>>>>> We need to be able to transparently forward most link-local frames via
>>>>> tunnels (e.g. vxlan, qinq). Currently the bridge's group_fwd_mask has a
>>>>> mask which restricts the forwarding of STP and LACP, but we need to be able
>>>>> to forward these over tunnels and control that forwarding on a per-port
>>>>> basis thus add a new per-port group_fwd_mask option which only disallows
>>>>> mac pause frames to be forwarded (they're always dropped anyway).
>>>>> The patch does not change the current default situation - all of the others
>>>>> are still restricted unless configured for forwarding.
>>>>> We have successfully tested this patch with LACP and STP forwarding over
>>>>> VxLAN and qinq tunnels.
>>>>>
>>>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>
>>>> LACP is fine, but STP must not be forwarded if STP in user or kernel
>>>> mode is enabled.
>>>>
>>>> Please update this patch or revert it.
>>>>
>>>
>>> The default has not changed, STP is still _not_ forwarded. It can be only if explicitly
>>> requested by the user and that means the port might be participating in STP but not
>>> the bridge's STP, that is explicitly forward all STP frames from that port.
>>> I don't think we have to change anything.
>>>
>>
>> You need to fail if user does something stupid. And DNR.
>>
>
> I get the motivation, but it does not have to be stupid. It may be 802.1q in q, not 802.1ad
> where STP is already forwarded by default, or it may be that the port is participating
> in a different STP. Wouldn't be enough to warn the user that STP forwarding was enabled
> for that port, instead of forcing it off and having it only for 802.1ad ?
> Later when we upstream 802.1Q in q patches we'll have to work around that anyway.
>
>> From 16c42db4852234c13288922c1bffbf7650e08434 Mon Sep 17 00:00:00 2001
>> From: Stephen Hemminger <sthemmin@microsoft.com>
>> Date: Fri, 29 Sep 2017 14:48:17 -0700
>> Subject: [PATCH] bridge: check for attempt to forward STP PDU's with STP
>>  enabled
>>
>> Move validation into set function and do not allow
>> configuring forwarding of STP packets if STP is enabled.
>>
>> Fixes: 5af48b59f35c ("net: bridge: add per-port group_fwd_mask with less restrictions")
>
> What if the user requested explicitly to forward these frames from that port ?
>

exactly and this could be on a provider bridge which is just tunneling
stp frames from a customer.
