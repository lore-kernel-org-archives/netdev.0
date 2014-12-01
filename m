From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Mon, 1 Dec 2014 06:47:40 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DEDA78@SHSMSX104.ccr.corp.intel.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <20141130102640.GA19726@breakpoint.cc>
 <5A90DA2E42F8AE43BC4A093BF0678848DED957@SHSMSX104.ccr.corp.intel.com>
 <20141130151114.GA4462@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Du, Fan" <fan.du@intel.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63969 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbaLAGsE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 01:48:04 -0500
In-Reply-To: <20141130151114.GA4462@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Florian Westphal [mailto:fw@strlen.de]
>Sent: Sunday, November 30, 2014 11:11 PM
>To: Du, Fan
>Cc: Florian Westphal; netdev@vger.kernel.org; davem@davemloft.net
>Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
>
>Du, Fan <fan.du@intel.com> wrote:
>> All interface MTU in the test scenario is the default one, 1500.
>
>Not really, unless I misunderstand the setup.
>
>You have a l2 network where part of the machines are connected by a
>l2 tunnel.
>
>All machines within that network ought to assume that MTU is equal for all
>machines within the same L2 network.

Based on what assumption do you think the test scenario use different MTU???
I think all your conclusion comes from the MTU configuration, as a matter of fact,
Like I stated before, ALL interface MTU is default 1500.

I elaborate this typical(!kludges) env a bit more:

Without vxlan tunnel, a typical standard env:
Guest -> Qemu/VirtIO -> tap0 -> linux bridge -> NIC

No tunneling trick here, no MTU change, packets come packets go, naked...

With vxlan tunnel, almost all the same topology as before, really no need to change any MTU
To make below env work.
Guest -> Qemu/VirtIO -> tap0 -> ovs bridge -> vxlan tunnel -> NIC
                                         ^^^^^^^^
                                         ^^^^^^^^
Encapsulation outer L234/VXLAN clothes before Guest frame,
Over-MTU-sized packet is locally created as *default* when Guest first attempts to try a big MSS *BEFORE* PMTU
is able to make guest sense this MSS is too big. Guest what, this over-MTU-sized packet is lost. That's the problem,
not because any different MTU configuration, but the code here rule out(based on what fact???) any such existing possibility

Anyway, setup such env is quite easy to see what's really going on inside the stack. You could even use docker to give a try.
It's the same effect as KVM guest, but easy to deploy.

Docker instance -> docker0 bridge -> vethA -> vethB -> ovs-br0 -> vxlan -> NIC

Any doubts about the env, please let me know.


>> >It seems to me to only clean solution is to set tap0 MTU so that it
>> >accounts for the bridge encap overhead.
>>
>> This will force _ALL_ deploy instances requiring tap0 MTU change in every cloud
>env.
>
>Yes, alternatively emply routing, then PMTU should work.
>
>> Current behavior leads over-mtu-sized packet push down to NIC, which
>> should not happen anyway. And as I putted in another threads:
>> Perform GSO for skb, then try to do ip segmentation if possible, If DF
>> set, send back ICMP message. If DF is not set, apparently user want
>> stack do ip segmentation, and All the GSO-ed skb will be sent out correctly as
>expected.
>
>Well, the linux bridge implementation (especially bridge netfilter) did/allows for a
>lot of layering violations and this has usually caused a myriad of followup kludges
>to make one-more scenario work.
>
>I still think that trying to make this work is a bad idea.
>If hosts have different MTUs they should be in different l2 networks.
>
>Alternatively, the Tunneling implementation should be opaque and do the needed
>fragmentation to provide the illusion of identical MTUs.
>
>That said, I don't see anything wrong with the patch per se, I just dislike the
>concept.
