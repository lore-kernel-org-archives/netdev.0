From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root container
 qdisc sch_mclass
Date: Mon, 03 Jan 2011 18:59:33 -0800
Message-ID: <4D228D15.2020209@intel.com>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab> <20101221192930.9703.63791.stgit@jf-dev1-dcblab> <4D1D17C9.3040500@gmail.com> <4D2161FF.4070804@intel.com> <20110103170244.GA1843@del.dom.local> <4D2233A4.9050701@intel.com> <20110103225947.GB1977@del.dom.local> <4D22674B.6010304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43870 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880Ab1ADC7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 21:59:39 -0500
In-Reply-To: <4D22674B.6010304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/3/2011 4:18 PM, John Fastabend wrote:
> On 1/3/2011 2:59 PM, Jarek Poplawski wrote:
>> On Mon, Jan 03, 2011 at 12:37:56PM -0800, John Fastabend wrote:
>>> On 1/3/2011 9:02 AM, Jarek Poplawski wrote:
>>>> On Sun, Jan 02, 2011 at 09:43:27PM -0800, John Fastabend wrote:
>>>>> On 12/30/2010 3:37 PM, Jarek Poplawski wrote:
>>>>>> John Fastabend wrote:
>>>>>>> This implements a mclass 'multi-class' queueing discipline that by
>>>>>>> default creates multiple mq qdisc's one for each traffic class. Each
>>>>>>> mq qdisc then owns a range of queues per the netdev_tc_txq mappings.
>>>>>>
>>>>>> Is it really necessary to add one more abstraction layer for this,
>>>>>> probably not most often used (or even asked by users), functionality?
>>>>>> Why mclass can't simply do these few things more instead of attaching
>>>>>> (and changing) mq?
>>>>>>
>>>>>
>>>>> The statistics work nicely when the mq qdisc is used. 
>>>>
>>>> Well, I sometimes add leaf qdiscs only to get class stats with less
>>>> typing, too ;-)
>>>>
>>>>>
>>>>> qdisc mclass 8002: root  tc 4 map 0 1 2 3 0 1 2 3 1 1 1 1 1 1 1 1
>>>>>              queues:(0:1) (2:3) (4:5) (6:15)
>>>>>  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>> qdisc mq 8003: parent 8002:1
>>>>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>> qdisc mq 8004: parent 8002:2
>>>>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>> qdisc mq 8005: parent 8002:3
>>>>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>> qdisc mq 8006: parent 8002:4
>>>>>  Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>> qdisc sfq 8007: parent 8005:1 limit 127p quantum 1514b
>>>>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>> qdisc sfq 8008: parent 8005:2 limit 127p quantum 1514b
>>>>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>>>>  backlog 0b 0p requeues 0
>>>>>
>>>>> The mclass gives the statistics for the interface and then statistics on the mq qdisc gives statistics for each traffic class. Also, when using the 'mq qdisc' with this abstraction other qdisc can be grafted onto the queue. For example the sch_sfq is used in the above example.
>>>>
>>>> IMHO, these tc offsets and counts make simply two level hierarchy
>>>> (classes with leaf subclasses) similarly (or simpler) to other
>>>> classful qdisc which manage it all inside one module. Of course,
>>>> we could think of another way of code organization, but it should
>>>> be rather done at the beginning of schedulers design. The mq qdisc
>>>> broke the design a bit adding a fake root, but I doubt we should go
>>>> deeper unless it's necessary. Doing mclass (or something) as a more
>>>> complex alternative to mq should be enough. Why couldn't mclass graft
>>>> sch_sfq the same way as mq?
>>>>
>>>
>>> If you also want to graft a scheduler onto a traffic class now your stuck. For now this qdisc doesn't exist, but I would like to have a software implementation of the currently offloaded DCB ETS scheduler. The 802.1Qaz spec allows different scheduling algorithms to be used on each traffic class. In the current implementation mclass could graft these scheduling schemes onto each traffic class independently.
>>>
>>>                               mclass
>>>                                 |
>>>     -------------------------------------------------------
>>>     |         |        |        |     |     |     |       |
>>>    mq_tbf   mq_tbf   mq_ets   mq_ets  mq    mq   mq_wrr greedy
>>>    |                            |
>>>  ---------                  ---------
>>>  |   |   |                  |   |   |
>>> red red red                red red red
>>>
>>> Perhaps, being concerned with hypothetical qdiscs is a bit of a stretch but I would like to at least not preclude this work from being done in the future.
>>
>> Probably, despite this very nice figure and description, I still miss
>> something and can't see the problem. If you graft a qdisc/scheduler
>> to a traffic class you can change the way/range of grafting depending
>> on additional parameters or even by checking some properties of the
>> grafted qdisc. My main concern is adding complexity to the qdisc tree
>> structure (instead of hiding it at the class level) for something,
>> IMHO, hardly ever popular (like both mq and DCB).
>>
> 
> OK I'm convinced I'll keep everything contained in mclass. Building this mechanism into the qdisc seems to be adding extra complexity that is most likely not needed as you noted.
> 
> Although I suspect the "additional parameter" would be something along the lines of a queue index and offset? right? Otherwise how would a mq like qdisc know which queues it owns.


Perhaps something with qdisc_class_ops select_queue() could be done to make it more flexible. When I get around to implementing these hypothetical qdiscs I will have to figure it out. For now though hypothetical qdiscs are not a very compelling use case.

Thanks,
John.
