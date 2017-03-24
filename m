From: Ben Greear <greearb@candelatech.com>
Subject: Re: Performance issue with igb with lots of different src-ip addrs.
Date: Fri, 24 Mar 2017 13:54:08 -0700
Message-ID: <fb63a694-e854-c94a-2e03-8737295775b1@candelatech.com>
References: <58CB165F.7030302@candelatech.com>
 <CAKgT0Ufwo-s0WUKu2kyELdx-CRHgmasEjyg+xnfgSGjo0dV_iQ@mail.gmail.com>
 <f110481e-5c8f-5d03-7fe7-bf9558cb7c1a@candelatech.com>
 <CAKgT0Ud2vhhz5szovyS4HtqdbsH_Ac_ycHrX9WR32j-X1+wocQ@mail.gmail.com>
 <a62952ac-df12-45ca-db0c-e27bce5ddf8a@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
        netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58266 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934714AbdCXUyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:54:10 -0400
In-Reply-To: <a62952ac-df12-45ca-db0c-e27bce5ddf8a@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2017 08:51 PM, Ben Greear wrote:
> I think we can, might take us a day or two to get time to do it.
>
> Thanks,
> Ben
>
> On 03/16/2017 08:05 PM, Alexander Duyck wrote:
>> I'm not really interested in installing a custom version of pktgen.
>> Any chance you can recreate the issue with standard pktgen?
>>
>> You might try running perf to get a snapshot of what is using CPU time
>> on the system.  It will probably give you a pretty good idea where the
>> code is that is eating up all your CPU time.

So, I had time to dig into this today.

Turns out that our tool was reporting drops because of sequence number
gaps, which in turn were caused by out-of-order frames...not actually
dropping frames.

If I force the rss_queues to one, the problem goes away.

Sorry for mis-reporting a bug.

Thanks,
Ben


>>
>> - Alex
>>
>> On Thu, Mar 16, 2017 at 7:46 PM, Ben Greear <greearb@candelatech.com> wrote:
>>> I'm actually using a hacked up version of pktgen nicely driven by our
>>> GUI tool, but the crux is that you need to set min and max src IP to some
>>> large
>>> range.
>>>
>>> We are driving pktgen from a separate machine.  Stock pktgen isn't good at
>>> reporting
>>> received pkts last I checked, so it may be more difficult to easily view the
>>> problem.
>>>
>>> I'll be happy to set up my tool on your Fedora 24 or similar VM or machine
>>> if you
>>> want.
>>>
>>> Thanks,
>>> Ben
>>>
>>>
>>> On 03/16/2017 07:35 PM, Alexander Duyck wrote:
>>>>
>>>> Can you include the pktgen script you are running?
>>>>
>>>> Also when you say you are driving traffic through the bridge are you
>>>> sending from something external on the system or are you actually
>>>> directing the traffic from pktgen into the bridge directly?
>>>>
>>>> - Alex
>>>>
>>>> On Thu, Mar 16, 2017 at 3:49 PM, Ben Greear <greearb@candelatech.com>
>>>> wrote:
>>>>>
>>>>> Hello,
>>>>>
>>>>> We notice that when using two igb ports as a bridge, if we use pktgen to
>>>>> drive traffic through the bridge and randomize (or use a very large
>>>>> range)
>>>>> for the source IP addr in pktgen, then performance of igb is very poor
>>>>> (like
>>>>> 150Mbps
>>>>> throughput instead of 1Gbps).  It runs right at line speed if we use same
>>>>> src/dest
>>>>> IP addr in pktgen.  So, seems it is related to lots of src/dest IP
>>>>> addresses.
>>>>>
>>>>> We see same problem when using pktgen to send to itself, and we see this
>>>>> in
>>>>> several different kernels.  We specifically tested bridge mode in this
>>>>> stock
>>>>> Fedora kernel:
>>>>>
>>>>>  Linux lfo350-59cc 4.9.13-101.fc24.x86_64 #1 SMP Tue Mar 7 23:48:32 UTC
>>>>> 2017
>>>>> x86_64 x86_64 x86_64 GNU/Linux
>>>>>
>>>>> e1000e does not show this problem in our testing.
>>>>>
>>>>> Any ideas what the issue might be and how to fix it?
>>>>>
>>>>> Thanks,
>>>>> Ben
>>>>>
>>>>> --
>>>>> Ben Greear <greearb@candelatech.com>
>>>>> Candela Technologies Inc  http://www.candelatech.com
>>>>>
>>>>
>>>
>>> --
>>> Ben Greear <greearb@candelatech.com>
>>> Candela Technologies Inc  http://www.candelatech.com
>>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
