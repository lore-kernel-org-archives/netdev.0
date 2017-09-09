From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link
 information
Date: Sat, 9 Sep 2017 13:23:19 -0400
Message-ID: <5706e1ba-6b85-4f32-a858-b5d87b17eb51@mojatatu.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
 <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
 <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35325 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdIIRX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 13:23:28 -0400
Received: by mail-it0-f65.google.com with SMTP id b76so2399879itb.2
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2017 10:23:27 -0700 (PDT)
In-Reply-To: <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-09-09 12:24 PM, Roopa Prabhu wrote:
> On Fri, Sep 8, 2017 at 2:52 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>> ---
>>   bridge/link.c | 16 +++++++++++++---
>>   1 file changed, 13 insertions(+), 3 deletions(-)
>>
>> diff --git a/bridge/link.c b/bridge/link.c
>> index 60200f1..9e4206f 100644
>> --- a/bridge/link.c
>> +++ b/bridge/link.c
>> @@ -461,9 +461,19 @@ static int brlink_show(int argc, char **argv)
>>                  }
>>          }
>>
>> -       if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
>> -               perror("Cannon send dump request");
>> -               exit(1);
>> +       if (show_details) {
>> +               if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
>> +                                            (compress_vlans ?
>> +                                             RTEXT_FILTER_BRVLAN_COMPRESSED :
>> +                                             RTEXT_FILTER_BRVLAN)) < 0) {
>> +                       perror("Cannon send dump request");
>> +                       exit(1);
>> +               }
> 
> vlan information is already available with `bridge vlan show`. any
> specific reason why you want it in
> the link dump output ?
> 
 >
> The problem is this might just make the link dump larger and also add
> too much clutter into the regular link dump output. iproute2 detailed
> dump is already a bit hard to interpret. And without compression by
> default, vlan info can just take over the link dump output. It will be
> hard to look for other link attributes after that :). We deploy with
> thousands of vlans and without compression even bridge vlan default
> output is already hard to interpret.
>

Agree we should be turning on this stuff by default. i.e default stays
compressed; otherwise it a huge dump.

Having said that there is a lot of mess with this stuff.
The bridge link events _already send this IFLA_AF_SPCE info_
so not much choice  there but to print it.
At minimal we need that part because unfortunately there is no
vlanfilter event in existence which will send us summaries of just
vlans added to a port i.e both use XXXLINK.
In general, the XXXLINK interface with these master devices (bridge,
bond etc) continues to get messy. Recently started seeing events with
devices claiming to be of KIND_slave etc on the bridge and bond devices;
yet at the same time my wireless card events are also showing up on the
bridge link even though it is not enslaved there..

cheers,
jamal

> Can you please paste a sample default detailed output with your patch
> with a few hundred vlans ?
> 
