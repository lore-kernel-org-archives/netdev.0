From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Fri, 8 Jul 2016 11:10:57 +1000
Message-ID: <20160708011057.GA21465@gwshan>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <577E921C.5050904@gmail.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, benh@kernel.crashing.org, joel@jms.id.au,
	weixue@trustnetic.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:18578 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753084AbcGHBLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 21:11:05 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6813rEg053239
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2016 21:11:03 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2415xn14mm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 21:11:03 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 8 Jul 2016 11:11:00 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 188DB2BB005A
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 11:10:59 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u681AxtW9896334
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 11:10:59 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u681Avwl012335
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 11:10:58 +1000
Content-Disposition: inline
In-Reply-To: <577E921C.5050904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 10:32:12AM -0700, Florian Fainelli wrote:
>On 07/02/2016 10:32 PM, Gavin Shan wrote:
>> This series rebases on David's linux-net git repo ("master" branch). It's
>> to support NCSI stack on net/farady/ftgmac100.c
>> 
>> The following figure gives an example about how NCSI is deployed: The NCSI is
>> specified by DSP0222, which can be downloaded from the following link here
>> (http://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.0.0.pdf).
>> 
>>    * The NC-SI (aka NCSI) is defined as the interface between a (Base) Management
>>      Controller (BMC) and one or multiple Network Controlers (NC) on host side.
>>      The interface is responsible for providing external network connectivity
>>      for BMC.
>>    * Each BMC can connect to multiple packages, up to 8. Each package can have
>>      multiple channels, up to 32. Every package and channel are identified by
>>      3-bits and 5-bits in NCSI packet. At one moment, one channel is active to
>>      provide service.
>>    * NCSI packet, encapsulated in ethernet frame, has 0x88F8 in the protocol
>>      field. The destination MAC address should be 0xFF's while the source MAC
>>      address can be arbitrary one.
>>    * NCSI packets are classified to command, response, AEN (Asynchronous Event
>>      Notification). Commands are sent from BMC to host for configuration and
>>      information retrival. Responses, corresponding to commands, are sent from
>>      host to BMC for confirmation and requested information. One command should
>>      have one and only one response. AEN is sent from host to BMC for notification
>>      (e.g. link down on active channel) so that BMC can take appropriate action.
>> 
>>    +------------------+        +----------------------------------------------+
>>    |                  |        |                     Host                     |
>>    |        BMC       |        |                                              |
>>    |                  |        | +-------------------+  +-------------------+ |
>>    |    +---------+   |        | |     Package-A     |  |     Package-B     | |
>>    |    |         |   |        | +---------+---------+  +-------------------+ |
>>    |    |   NIC   |   |        | | Channel | Channel |  | Channel | Channel | |
>>    +----+----+----+---+        +-+---------+---------+--+---------+---------+-+
>>              |                             |                      |
>>              |                             |                      |
>>              +-----------------------------+----------------------+
>> 
>> The design for the patchset is highlighted as below:
>> 
>>    * The NCSI interface is abstracted with "struct ncsi_dev". It's registered
>>      when net_device is created, started to work by calling ncsi_start_dev()
>>      when net_device is opened (ndo_open()). For the first time, NCSI packets
>>      are sent and received to/from the far end (host in above figure) to probe
>>      available NCSI packages and channels. After that, one channel is chosen as
>>      active one to provide service.
>>    * The NCSI stack is driven by workqueue and state machine internally.
>>    * AEN (Asychronous Event Notification) might be received from the far end
>>      (host). The currently active NCSI channel fails over to another available
>>      one if possible. Otherwise, the NCSI channel is out of service.
>>    * NCSI stack should be configurable through netlink or another mechanism,
>>      but it's not implemented in this patchset. It's something TBD.
>>    * The first NIC driver that is aware of NCSI: drivers/net/ethernet/faraday/ftgmac100.c

Florian, thanks for your comments.

>I know nothing about NCSI, pretty much like Jon Snow, but from a cursory
>look at your patches, is not there a way to make the NCSCI capable
>network devices strictly adhere to the net_device APIs and calling
>conventions?
>

Please refer to Ben's reply and it's well explained.

>Even if the data flow is a little different than normal ethernet frames,
>and there is not a good way to trap to intercept the delivery of NCSI
>packets, one could imagine doing something ala DSA where you register a
>fake ethertype for NCSI to hook a ptype_fun packet handler, augment
>struct net_device with a ncsi_dev pointer, and do processing in
>net/nsci/ for this device you know where the packet came from. You don't
>need to have an officially assigned ethertype for this, see
>netdev_uses_dsa() which just tests whether the traffic is tagged with a
>particular tag and delivers packet to a protocol specific parser in
>net/dsa/.
>
>For packets on their way out you could imagine assigning them a specific
>skb->protocol value and have the driver's transmit path do specific
>things based on that.
>
>Just an idea, I am not even sure this makes sense here, but what seems
>to make sens to me is that if more network device drivers end up
>supporting and transporting NCSI, we barely want them to know about that.

NCSI packets are encapsulated in ethernet frames those protocol field
is set to 0x88F8 as the NCSI specification states. I guess it's different
from DSA after having quick scan on the code you pointed. It seems DSA
is using software objects (struct dsa_switch_tree) to supersede the bridge
information contained in ethernet frame (e.g. destination MAC address).
The ingress ethernet frames are switched to destination port based the
tag then. NCSI isn't switching frames and all packets originate from
NCSI stack regardless of NIC on the far end. In most cases, the NCSI
packets show up in pairs (command/response). The command is always
originated from NCSI stack and response (from NIC on the far end)
terminates in NCSI stack. I think a device specific ptype works fine.

Thank you again for the idea and comments :-)

Thanks,
Gavin
 
>-- 
>Florian
>
