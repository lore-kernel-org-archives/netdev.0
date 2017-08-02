From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [PATCH net-next RFC 0/6] Configure cloud filters in i40e via
 tc/flower classifier
Date: Wed, 2 Aug 2017 11:17:08 -0700
Message-ID: <db701a5c-8809-90d3-0e20-11fff34ab642@intel.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <2d833571-a5f3-41a6-0e6c-9d2c27b0a8c5@mojatatu.com>
 <78fbc08d-f846-a3e4-ffbd-f0cba43780e3@intel.com>
 <146b5375-5d70-bb65-74aa-5c19c1de7daf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com,
        Or Gerlitz <gerlitz.or@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:6852 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751186AbdHBSRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 14:17:09 -0400
In-Reply-To: <146b5375-5d70-bb65-74aa-5c19c1de7daf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8/2/2017 5:01 AM, Jamal Hadi Salim wrote:
> On 17-08-01 08:57 PM, Nambiar, Amritha wrote:
>>
>> On 8/1/2017 3:15 AM, Jamal Hadi Salim wrote:
>>> On 17-07-31 08:36 PM, Amritha Nambiar wrote:
> 
>>>>
>>>> # tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>>>>     dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>>>>     skip_sw indev eth0 action mirred ingress redirect dev eth0 tc 1
>>>>
>>>
>>> I think "queue 1" sounds better than "tc 1".
>>> "tc" is  already a keyword in a few places (even within that declaration
>>> above).
>>
>> The idea is to redirect to a traffic class that has queues assigned to
>> it and not a single queue i.e. these are actually queue groups and not a
>> single queue. So may be "qgroup 1" or "tcqgroup 1" fits better.
>>
> 
> Can you describe how this works? So the specific memeber of a
> a tcgroups show up on a specific rx DMA ring? If you only have
> 16 and 512 RX DMA rings - how does that work?
>

The Rx rule here is to redirect packets a specific traffic class. It is
the traffic class index (queue group index) that is offloaded to the
device. Queues were already configured for the traffic class by mapping
the queue counts and offsets and offloading this layout using the mqprio
framework. I had submitted a patch series for this which uses a new
hardware offload mode in mqprio to offload the TCs, the queue
configurations and the bandwidth rates for the TCs. So the 512 rings can
be mapped into 16 TCs using the mqprio offload mechanism, something like
this:
TC0 : 0 – 15
TC1: 16 – 31
TC2: 32 – 33
TC3: 34 – 49
.
.
.
TC15: 500 - 511

Now, once the TC configuration is prepared, it is just a matter of
hooking up the Rx rules to route traffic to the traffic class/queue
group. Rx queue selection within the queue group happens based on RSS.

> cheers,
> jamal
> 
