From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [PATCH 0/6] Configuring traffic classes via new hardware offload
 mechanism in tc/mqprio
Date: Fri, 14 Jul 2017 03:31:01 -0700
Message-ID: <42d0cfed-2f47-2d81-9654-aa9f017860ac@intel.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
 <13371d93-6362-b56f-3655-a85b37f5667e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com,
        Roman Mashak <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:60386 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753567AbdGNKbD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 06:31:03 -0400
In-Reply-To: <13371d93-6362-b56f-3655-a85b37f5667e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/14/2017 12:56 AM, Jamal Hadi Salim wrote:
> Hi Amritha,
>
> On 17-07-11 06:18 AM, Amritha Nambiar wrote:
>> The following series introduces a new hardware offload mode in
>> tc/mqprio where the TCs, the queue configurations and
>> bandwidth rate limits are offloaded to the hardware. The existing
>> mqprio framework is extended to configure the queue counts and
>> layout and also added support for rate limiting. This is achieved
>> by setting the value 2 for the "hw" mode. Legacy devices can fall
>> back to the existing setup supporting hw mode 1 where only the
>> TCs are offloaded, however if hw mode 2 is specified, then this
>> type of offload fails to initialize if the requested mode is not
>> supported. The i40e driver enables the new mqprio hardware offload
>> mechanism factoring the TCs, queue configuration and bandwidth
>> rates by creating HW channel VSIs.
>>
>> In this new mode, the priority to traffic class mapping and the
>> user specified queue ranges are used to configure the traffic
>> class when the 'hw' option is set to 2. This is achieved by
>> creating HW channels(VSI). A new channel is created for each
>> of the traffic class configuration offloaded via mqprio
>> framework except for the first TC (TC0) which is for the main
>> VSI. TC0 for the main VSI is also reconfigured as per user
>> provided queue parameters. Finally, bandwidth rate limits are
>> set on these traffic classes through the mqprio offload
>> framework by sending these rates in addition to the number of
>> TCs and the queue configurations.
>>
>> Example:
>> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>>    queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
>>
>> To dump the bandwidth rates:
>>
>> # tc qdisc show dev eth0
>>    qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>>                 queues:(0:3) (4:7)
>>                 min rates:0bit 0bit
>>                 max rates:55Mbit 60Mbit
>
> My only concern is usability. Was already cryptic with hw "1" and
> now we introduce another magic number "2". Could we not have two
> have some human friendly nouns? I know 1 means offload qos and two
> mean offload rate (+qos?).

I agree this could be less friendly, I was trying to retain the existing
conventions. Yes, hw "2" offloads qos and rates.

>
> I have some questions:
> BTW, what would tc class show dev eth0 display in this case?
> Above seems to select queue groupings for a specific rates which
> is a short-cut to say assigning each queue via something like TBF
> via "tc class" semantics (but way more cryptic than tc class;->)

Dumping the classes under mqprio qdisc will not display any of the
queue configurations or rates. MQPRIO is classless and does not support
change_class operation like HTB does to add a class to the qdisc and set
a rate for the class.

>
> cheers,
> jamal
>
>
