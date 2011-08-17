From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 04/14] bna: Add Multiple Tx Queue Support
Date: Tue, 16 Aug 2011 22:47:40 -0700
Message-ID: <4E4B55FC.5070000@intel.com>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>  <1313529591-3718-5-git-send-email-rmody@brocade.com>  <1313531338.2725.63.camel@bwh-desktop>  <E5313AF6F2BFD14293E5FD0F94750F86A94D99537C@HQ1-EXCH01.corp.brocade.com> <1313538196.2725.74.camel@bwh-desktop> <4E4B089E.9080102@intel.com> <E5313AF6F2BFD14293E5FD0F94750F86A94D9953ED@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Gurunatha Karaje <gkaraje@Brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20245 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813Ab1HQFrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 01:47:42 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A94D9953ED@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/2011 7:14 PM, Rasesh Mody wrote:
>> From: John Fastabend [mailto:john.r.fastabend@intel.com]
>> Sent: Tuesday, August 16, 2011 5:18 PM
>>
>> On 8/16/2011 4:43 PM, Ben Hutchings wrote:
>>> On Tue, 2011-08-16 at 16:32 -0700, Rasesh Mody wrote:
>>>>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>>>> Sent: Tuesday, August 16, 2011 2:49 PM
>>>>>
>>>>> On Tue, 2011-08-16 at 14:19 -0700, Rasesh Mody wrote:
>>>>>> Change details:
>>>>>>  - Add macros bna_prio_allow, bna_default_nw_prio, bna_iscsi_prio,
>>>>>>    bna_is_iscsi_over_cee
>>>>>>  - Added support for multipe Tx queues with a separate iSCSI Tx
>> queue
>>>>> based
>>>>>>    on the default value of iSCSI port number. The feature is
>> supported
>>>>> based
>>>>>>    on the underlying hardware and enabled for DCB (CEE) mode only.
>>>>>>  - Allocate multiple TxQ resource in netdev
>>>>>>  - Implement bnad_tx_select_queue() which enables the correct
>>>>> selection of
>>>>>>    TxQ Id (and tcb). This function is called either by the kernel
>> to
>>>>> channel
>>>>>>    packets to the right TxQ
>>>>>>  - bnad_tx_select_queue() returns priority, while only a few
>> packets
>>>>> during
>>>>>>    transition could have wrong priority, all will be associated
>> with a
>>>>> valid
>>>>>>    non-NULL tcb.
>>>>>>  - Implement bnad_iscsi_tcb_get() and BNAD_IS_ISCSI_PKT() for iSCSI
>>>>> packet
>>>>>>    inspection and retrieval of tcb corresponding to the iSCSI
>>>>> priority.
>>>>>>  - Construction of priority indirection table to be used by bnad to
>>>>> direct
>>>>>>    packets into TxQs
>>>>> [...]
>>>>>
>>>>> You probably should implement TX priority classes through the
>>>>> ndo_setup_tc operation, not ndo_select_queue.
>>>>
>>>> The reason we went with ndo_select_queue is due to the need for
>> mapping
>>>> iSCSI packets (TCP port 3260) to a priority derived from DCB
>> configuration.
>>>> Here the iSCSI packets may not have any tc defined in the packet
>> header.
>>>
>>> There is an skb priority, which is derived from the socket priority
>>> option (SO_PRIORITY).  If you implement ndo_setup_tc then the
>> networking
>>> core will take care of mapping the skb priority onto a different queue
>>> (or range of queues).
>>>
>>> I don't know whether the socket priority option is easily configurable
>>> for the existing iSCSI implementations.  But looking at port numbers
>>> really doesn't seem like the right way to do this.
>>>
>>> Ben.
>>>
>>
>> At least open-iscsi supports DCB by listening to the RTNLGRP_DCB for
>> events.
>> These are generated with dcbnl_cee_notify and dcbnl_ieee_notify. To
>> support
>> this in your driver you need to call dcb_setapp() or dcb_ieee_setapp()
>> to
>> add the application data and follow this with the appropriate notify
>> call.
>> Then assuming you do the necessary tc setup work the stack will handle
>> the
>> mapping of priority to queues.
> 
> This is how iSCSI over DCB feature is expected to works in BNA driver:-
> FW running in the BNA adapter implements the DCB protocol. It learns the
> iSCSI priority from the switch through iSCSI TLV exchange. BNA driver
> extracts the iSCSI priority from the FW that needs to be used for iSCSI
> packets.

Up to here this is fine. What I was suggesting was to then use the
dcb_setapp() routines to program the iSCSI TLV and generate an event
so any user space applications listening to DCB events could handle
this. It would also be nice if your driver notified user space of
any PG or PFC changes as well. Then management agents (lldpad) could
use the DCB attributes to make policy decisions.

> For every outgoing packet, BNA driver does a TCP header
> inspection to classify iSCSI packet and attach right 802.1q priority &
> send it on the correct TX queue.
> 
> This is expected to work with iSCSI applications that do not configure the
> priority with SO_PRIORITY - here the iSCSI priority configuration actually
> comes from the switch to the adapter.
> 

Although this works I don't think it is optimal for a few reason. Your
L2 driver is inspecting TCP frames which is bad layering IMHO. The
iSCSI port number is hard coded into the driver so it will only work
with the well known port number. Also it adds more driver specific
behavior into select_queue() where I think the trend is to try to
use select_queue() less not more.

To address iSCSI applications that do not configure the priority
we could either work on adding the DCB hooks needed in those
applications. Or look at adding a hook in the qdisc layer to
to do what your select_queue() hook does here. I started prototyping
this awhile ago but this requires running the packet classifiers
and associated actions before picking a queue assuming you want
to use mq or mqprio. I hope to get back to this soon I have some
more details to flush out wrt this and need to run it by some other
folks to make sure its a sane idea.


> The goal of this iSCSI priority is:
> a) adapter applies prioritized scheduling for packets in its egress - to
> guarantee minimum bandwidth as per ETS
> b) packets are tagged with right priority so that switch can also identify
> and guarantee BW on its egress.

Correct. This is the same for other drivers that support DCB and
use tc_setup as Ben suggested. See the bnx2x driver for an example
that also uses a FW based LLDP engine and does this.

> 
> Hope this explains.

I think the one valid item is the unsupported applications but
hopefully that can be addressed. Thanks for the details.

John.

> 
> Thanks,
> Rasesh

