From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting
 Vlan
Date: Fri, 13 Oct 2017 05:15:08 +0300
Message-ID: <ba70b4c0-2bd9-9722-7101-e823d901f09f@cumulusnetworks.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
 <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
 <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
 <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
 <64292550-f043-c1f7-5b0e-004288832887@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:55025 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753291AbdJMCPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 22:15:11 -0400
Received: by mail-wm0-f42.google.com with SMTP id i124so17819155wmf.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 19:15:11 -0700 (PDT)
In-Reply-To: <64292550-f043-c1f7-5b0e-004288832887@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.10.2017 05:03, Jamal Hadi Salim wrote:
> On 17-10-12 02:12 PM, Nikolay Aleksandrov wrote:
>> On 12/10/17 21:07, Roman Mashak wrote:
> 
>>> For example, if you attempt to delete a non-existing vlan on a port,
>>> the current code succeeds and also sends event :
>>>
>>> rtnetlink_rcv_msg
>>>      rtnl_bridge_dellink
>>>         br_dellink
>>>            br_afspec
>>>               br_vlan_info
>>>
>>> int br_dellink(..)
>>> {
>>>    ...
>>>    err = br_afspec()
>>>    if (err == 0)
>>>        br_ifinfo_notify(RTM_NEWLINK, p);
>>> }
>>>
>>> This is misleading, so a proper errcode has to be produced.
>>>
>>
> 
> 
> 
>> True, but you also change the expected behaviour because now a user can
>> clear all vlans with one request (1 - 4094), and after the change that
>> will fail with a partial delete if some vlan was missing.
>>
> 
> The issue is more subtle (per Roman above):
> Try to delete a vlan (that doesnt  exist).
> 1) It says "success".
> 2) Worse: Another process listening (bridge monitor?) gets an _event_
>  that  the vlan has been deleted (when it never existed in the first
>  place).
> 
>> This has been the behaviour forever and some script might depend on it.
>> Also IMO, and as David also mentioned, doing a partial delete is not
>> good.
>>
> 
> I think this is a bug (especially the event part).
> 
> cheers,
> jamal
> 

Fair enough, but after the patch you get the opposite effect too - you
delete a couple of vlans but you don't generate an event because of an
error in the middle. That at least can be taken care of.

I do agree it's a bug, but there might be scripts that rely on it and
don't check the return value when clearing vlans. They will end up with
a partial clear and wrongly assumed state, so maybe leave the
opportunistic delete but count if anything was actually deleted and send
an event only then ?
That should make everyone happy :-)
