From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link
 information
Date: Sat, 9 Sep 2017 21:15:24 +0300
Message-ID: <1bde7c3e-1571-a2a2-3308-b42906fbb3d2@cumulusnetworks.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
 <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
 <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
 <5706e1ba-6b85-4f32-a858-b5d87b17eb51@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:46044 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751384AbdIISP2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 14:15:28 -0400
Received: by mail-wm0-f45.google.com with SMTP id f199so18883759wme.0
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2017 11:15:27 -0700 (PDT)
In-Reply-To: <5706e1ba-6b85-4f32-a858-b5d87b17eb51@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/17 20:23, Jamal Hadi Salim wrote:
> On 17-09-09 12:24 PM, Roopa Prabhu wrote:
>> On Fri, Sep 8, 2017 at 2:52 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>> ---
>>>   bridge/link.c | 16 +++++++++++++---
>>>   1 file changed, 13 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/bridge/link.c b/bridge/link.c
>>> index 60200f1..9e4206f 100644
>>> --- a/bridge/link.c
>>> +++ b/bridge/link.c
>>> @@ -461,9 +461,19 @@ static int brlink_show(int argc, char **argv)
>>>                  }
>>>          }
>>>
>>> -       if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
>>> -               perror("Cannon send dump request");
>>> -               exit(1);
>>> +       if (show_details) {
>>> +               if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
>>> +                                            (compress_vlans ?
>>> +                                             RTEXT_FILTER_BRVLAN_COMPRESSED :
>>> +                                             RTEXT_FILTER_BRVLAN)) < 0) {
>>> +                       perror("Cannon send dump request");
>>> +                       exit(1);
>>> +               }
>>
>> vlan information is already available with `bridge vlan show`. any
>> specific reason why you want it in
>> the link dump output ?
>>
>>
>> The problem is this might just make the link dump larger and also add
>> too much clutter into the regular link dump output. iproute2 detailed
>> dump is already a bit hard to interpret. And without compression by
>> default, vlan info can just take over the link dump output. It will be
>> hard to look for other link attributes after that :). We deploy with
>> thousands of vlans and without compression even bridge vlan default
>> output is already hard to interpret.
>>
> 
> Agree we should be turning on this stuff by default. i.e default stays
> compressed; otherwise it a huge dump.

I think this should be dumped with the getlink request only on some additional
flag. The getlink does not include these by default.

> 
> Having said that there is a lot of mess with this stuff.
> The bridge link events _already send this IFLA_AF_SPCE info_
> so not much choice  there but to print it.

Right, on NEWLINK per port notification you'll get the compressed vlan info.

> At minimal we need that part because unfortunately there is no
> vlanfilter event in existence which will send us summaries of just
> vlans added to a port i.e both use XXXLINK.

But let's either add a new flag or use -compressvlans to print it when monitoring/showing
link otherwise people who are monitoring only the port flags will start getting lists
with vlans. Even compressed these can still be quite long and confusing, especially
when monitoring.

> In general, the XXXLINK interface with these master devices (bridge,
> bond etc) continues to get messy. Recently started seeing events with
> devices claiming to be of KIND_slave etc on the bridge and bond devices;
> yet at the same time my wireless card events are also showing up on the
> bridge link even though it is not enslaved there..
> 
> cheers,
> jamal
> 
>> Can you please paste a sample default detailed output with your patch
>> with a few hundred vlans ?
>>
> 
