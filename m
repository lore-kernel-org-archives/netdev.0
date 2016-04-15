From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH nf] netfilter: ipv6: Orphan skbs in nf_ct_frag6_gather()
Date: Thu, 14 Apr 2016 17:14:07 -0700
Message-ID: <CAPWQB7GGqbUNgqt1nT6RfqtWwL8pYmnBcjb=y6UC4Nw1pVbEpQ@mail.gmail.com>
References: <1460570974-44050-1-git-send-email-joe@ovn.org>
 <063D6719AE5E284EB5DD2968C1650D6D5F4A226C@AcuExch.aculab.com> <20160414084015.GA3192@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"diproiettod@vmware.com" <diproiettod@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:35238 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbcDOAOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 20:14:32 -0400
In-Reply-To: <20160414084015.GA3192@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 April 2016 at 01:40, Florian Westphal <fw@strlen.de> wrote:
> David Laight <David.Laight@ACULAB.COM> wrote:
>> From: Joe Stringer
>> > Sent: 13 April 2016 19:10
>> > This is the IPv6 equivalent of commit 8282f27449bf ("inet: frag: Always
>> > orphan skbs inside ip_defrag()").
>> >
>> > Prior to commit 029f7f3b8701 ("netfilter: ipv6: nf_defrag: avoid/free
>> > clone operations"), ipv6 fragments sent to nf_ct_frag6_gather() would be
>> > cloned (implicitly orphaning) prior to queueing for reassembly. As such,
>> > when the IPv6 message is eventually reassembled, the skb->sk for all
>> > fragments would be NULL. After that commit was introduced, rather than
>> > cloning, the original skbs were queued directly without orphaning. The
>> > end result is that all frags except for the first and last may have a
>> > socket attached.
>>
>> I'd have thought that the queued fragments would still want to be
>> resource-counted against the socket (I think that is what skb->sk is for).
>
> No, ipv4/ipv6 reasm has its own accouting.
>
>> Although I can't imagine why IPv6 reassembly is happening on skb
>> associated with a socket.
>
> Right, thats a much more interesting question -- both ipv4 and
> ipv6 orphan skbs before NF_HOOK prerouting trip.
>
> (That being said, I don't mind the patch, I'm just be curious how this
>  can happen).

The topology is quite simple, there is a veth pair connected between a
namespace and OVS. The OVS bridge has an internal port. The
bridge is configured with flows to send packets through conntrack
(causing packet reassembly + refragmentation on output), and then
forward packets between the host and the veth. The internal port and
the veth inside the netns have IP addresses configured in the same
subnet.

In the test case, we send a large ICMPv6 ping request from the
namespace to the internal port. The namespace will fragment the IP
message into fragments and send through the veth. OVS processes these,
sends to conntrack (reassembly), then decides to output to the
internal port (refragmenting). The host stack finally receives the
fragments and processes the ICMP request. On response, the host sends
several fragments to OVS. OVS reassembles these and sends them to
conntrack, then decides to forward to the veth. When forwarding to the
veth, the skb frag queue is in this state with many skbs (all except
first and last) having skb->sk populated, and we hit the
BUG_ON(skb->sk) in ip6_fragment() just prior to transmitting to the veth.

In regards to your question about prerouting, does the response even
hit the input path on the host? An ICMP response is generated, and it
needs to be directed out to the device (output path), then when the
internal device receives it, it starts OVS processing.
