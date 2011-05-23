From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 16:02:23 -0700
Message-ID: <m1boyt10n4.fsf@fess.ebiederm.org>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>
	<20110523140048.777fb378@nehalam>
	<20110523.172047.1438754754048434316.davem@davemloft.net>
	<m1y61x2htp.fsf@fess.ebiederm.org> <4DDADE52.8000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, nicolas.2p.debian@gmail.com,
	jpirko@redhat.com, xiaosuo@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, jesse@nicira.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44168 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab1EWXC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 19:02:29 -0400
In-Reply-To: <4DDADE52.8000008@candelatech.com> (Ben Greear's message of "Mon,
	23 May 2011 15:23:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> On 05/23/2011 03:05 PM, Eric W. Biederman wrote:
>
> If REORDER_HDR dissappears entirely, I think you have to default to
> stripping the header on vlan2000.

Which is what patches that started this thread are doing.

>> With vlan hardware acceleration.  When I tcpdump on eth0 I don't
>> see the vlan header.  Nor do I see the vlan header when I tcpdump
>> on vlan2000.
>
> I think you should see the header on eth0 regardless of hw acceleration
> or not.  Users should not have to know if their NIC/driver supports
> vlan tag stripping in one mode or another.

But is it acceptable to fix this in libpcap?

>> 3) What do we do with pf_packet and vlan hardware acceleration when
>>     dumping not the vlan interface but the interface below the vlan
>>     interface?
>>
>>     Do we provide an option to keep the vlan header?  Should that option
>>     be on by default?
>
> At the least we need to have the header kept when using pf_packet on
> eth0.

Start with the assumption that vlan hardware acceleration is in place
and the hardware has stripped the vlan tag and put it in skb->tci.
Sure there are dumb divers out there that don't do this today but
either we need to throw out vlan hardware acceleration completely
or emulate it in software because otherwise the test matrix is just
too big.

> I think it's best to have it available on vlan2000, but perhaps have it
> stripped by default for backwards compatibility.

Anything that deals with raw packets pretty much breaks if you don't
strip the vlan header from visibility on vlan2000.  Plus you loose
any advantage there is from vlan hardware acceleration, which is
available on must modern NICs.  So I don't think we can seriously
consider having the vlan header for present on the vlan2000 device.

All that is interesting is what to do with eth0, and pf_packet sockets.
And the only question that seems really interesting there is do we put
the vlan header back on with libpcap magic or with pf_packet logic.

We have to start with a the assumption that we come in with a pf_packet
with the vlan tag only in skb->tci.

Eric
