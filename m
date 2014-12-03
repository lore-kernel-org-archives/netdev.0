From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 03:32:46 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DEE09A@SHSMSX104.ccr.corp.intel.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <20141202.192311.1226452173523245977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>, "Du, Fan" <fan.du@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25088 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbaLCDc5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 22:32:57 -0500
In-Reply-To: <20141202.192311.1226452173523245977.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, December 3, 2014 11:23 AM
>To: Du, Fan
>Cc: netdev@vger.kernel.org; fw@strlen.de
>Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
>
>From: Fan Du <fan.du@intel.com>
>Date: Fri, 28 Nov 2014 14:33:05 +0800
>
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
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
>
>I really don't like this at all.
>
>If guest sees a 1500 byte MTU, that's it's link layer MTU and it had better be able to
>send 1500 byte packets onto the "wire".

This patch makes it happens exactly as you putted.

>If you cannot properly propagate the vxlan encapsulation overhead back into the
>guest's MTU you must hide this problem from the rest of our stack somehow.

Again, this patch hide this problem to make Guest feel it can send packet with MTU as 1500 bytes.

>Nothing we create inside the host should need the change that you are making.
