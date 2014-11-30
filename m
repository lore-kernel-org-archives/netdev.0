From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Sun, 30 Nov 2014 10:55:01 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DED957@SHSMSX104.ccr.corp.intel.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <20141130102640.GA19726@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Du, Fan" <fan.du@intel.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50107 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbaK3KzI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 05:55:08 -0500
In-Reply-To: <20141130102640.GA19726@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Florian Westphal [mailto:fw@strlen.de]
>Sent: Sunday, November 30, 2014 6:27 PM
>To: Du, Fan
>Cc: netdev@vger.kernel.org; davem@davemloft.net; fw@strlen.de
>Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
>
>Fan Du <fan.du@intel.com> wrote:
>> Test scenario: two KVM guests sitting in different hosts communicate
>> to each other with a vxlan tunnel.
>>
>> All interface MTU is default 1500 Bytes, from guest point of view, its
>> skb gso_size could be as bigger as 1448Bytes, however after guest skb
>> goes through vxlan encapuslation, individual segments length of a gso
>> packet could exceed physical NIC MTU 1500, which will be lost at
>> recevier side.
>>
>> So it's possible in virtualized environment, locally created skb len
>> after encapslation could be bigger than underlayer MTU. In such case,
>> it's reasonable to do GSO first, then fragment any packet bigger than
>> MTU as possible.
>>
>> +---------------+ TX     RX +---------------+
>> |   KVM Guest   | -> ... -> |   KVM Guest   |
>> +-+-----------+-+           +-+-----------+-+
>>   |Qemu/VirtIO|               |Qemu/VirtIO|
>>   +-----------+               +-----------+
>>        |                            |
>>        v tap0                  tap0 v
>>   +-----------+               +-----------+
>>   | ovs bridge|               | ovs bridge|
>>   +-----------+               +-----------+
>>        | vxlan                vxlan |
>>        v                            v
>>   +-----------+               +-----------+
>>   |    NIC    |    <------>   |    NIC    |
>>   +-----------+               +-----------+
>>
>> Steps to reproduce:
>>  1. Using kernel builtin openvswitch module to setup ovs bridge.
>>  2. Runing iperf without -M, communication will stuck.
>
>Hmm, do we really want to suport bridges containing interfaces with different
>MTUs?

All interface MTU in the test scenario is the default one, 1500.

>It seems to me to only clean solution is to set tap0 MTU so that it accounts for the
>bridge encap overhead.

This will force _ALL_ deploy instances requiring tap0 MTU change in every cloud env.

Current behavior leads over-mtu-sized packet push down to NIC, which should not
happen anyway. And as I putted in another threads:
Perform GSO for skb, then try to do ip segmentation if possible, If DF set, send back
ICMP message. If DF is not set, apparently user want stack do ip segmentation, and
All the GSO-ed skb will be sent out correctly as expected.
