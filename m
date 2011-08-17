From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 04/14] bna: Add Multiple Tx Queue Support
Date: Tue, 16 Aug 2011 17:17:34 -0700
Message-ID: <4E4B089E.9080102@intel.com>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>  <1313529591-3718-5-git-send-email-rmody@brocade.com>  <1313531338.2725.63.camel@bwh-desktop>  <E5313AF6F2BFD14293E5FD0F94750F86A94D99537C@HQ1-EXCH01.corp.brocade.com> <1313538196.2725.74.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Rasesh Mody <rmody@brocade.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Gurunatha Karaje <gkaraje@Brocade.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14100 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab1HQARg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 20:17:36 -0400
In-Reply-To: <1313538196.2725.74.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/2011 4:43 PM, Ben Hutchings wrote:
> On Tue, 2011-08-16 at 16:32 -0700, Rasesh Mody wrote:
>>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>> Sent: Tuesday, August 16, 2011 2:49 PM
>>>
>>> On Tue, 2011-08-16 at 14:19 -0700, Rasesh Mody wrote:
>>>> Change details:
>>>>  - Add macros bna_prio_allow, bna_default_nw_prio, bna_iscsi_prio,
>>>>    bna_is_iscsi_over_cee
>>>>  - Added support for multipe Tx queues with a separate iSCSI Tx queue
>>> based
>>>>    on the default value of iSCSI port number. The feature is supported
>>> based
>>>>    on the underlying hardware and enabled for DCB (CEE) mode only.
>>>>  - Allocate multiple TxQ resource in netdev
>>>>  - Implement bnad_tx_select_queue() which enables the correct
>>> selection of
>>>>    TxQ Id (and tcb). This function is called either by the kernel to
>>> channel
>>>>    packets to the right TxQ
>>>>  - bnad_tx_select_queue() returns priority, while only a few packets
>>> during
>>>>    transition could have wrong priority, all will be associated with a
>>> valid
>>>>    non-NULL tcb.
>>>>  - Implement bnad_iscsi_tcb_get() and BNAD_IS_ISCSI_PKT() for iSCSI
>>> packet
>>>>    inspection and retrieval of tcb corresponding to the iSCSI
>>> priority.
>>>>  - Construction of priority indirection table to be used by bnad to
>>> direct
>>>>    packets into TxQs
>>> [...]
>>>
>>> You probably should implement TX priority classes through the
>>> ndo_setup_tc operation, not ndo_select_queue.
>>
>> The reason we went with ndo_select_queue is due to the need for mapping
>> iSCSI packets (TCP port 3260) to a priority derived from DCB configuration.
>> Here the iSCSI packets may not have any tc defined in the packet header. 
> 
> There is an skb priority, which is derived from the socket priority
> option (SO_PRIORITY).  If you implement ndo_setup_tc then the networking
> core will take care of mapping the skb priority onto a different queue
> (or range of queues).
> 
> I don't know whether the socket priority option is easily configurable
> for the existing iSCSI implementations.  But looking at port numbers
> really doesn't seem like the right way to do this.
> 
> Ben.
> 

At least open-iscsi supports DCB by listening to the RTNLGRP_DCB for events.
These are generated with dcbnl_cee_notify and dcbnl_ieee_notify. To support
this in your driver you need to call dcb_setapp() or dcb_ieee_setapp() to
add the application data and follow this with the appropriate notify call.
Then assuming you do the necessary tc setup work the stack will handle the
mapping of priority to queues.

John.




