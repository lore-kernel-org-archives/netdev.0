From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/2] NET: Re-add VLAN tag for devices incapable of keeping it
Date: Tue, 06 Nov 2007 21:08:21 +0100
Message-ID: <m3fxzj3znu.fsf@maximus.localdomain>
References: <472A6089.7020104@hp.com>
	<18223.22291.622615.129374@zeus.sw.starentnetworks.com>
	<472F5A33.20906@trash.net>
	<20071105.151544.175839612.davem@davemloft.net>
	<472FB375.1020802@trash.net> <m3y7db45ga.fsf@maximus.localdomain>
	<4730B8ED.7020301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	djohnson+linux-kernel@sw.starentnetworks.com,
	jes@trained-monkey.org, mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:56678 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbXKFUIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 15:08:23 -0500
In-Reply-To: <4730B8ED.7020301@candelatech.com> (Ben Greear's message of "Tue, 06 Nov 2007 10:56:45 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> Bridging eth0 to eth1 should not pay attention to VLAN tags
> at all (if the pkt comes in on VLAN 7, it should go out on VLAN 7),
> in my opinion.  If the NIC is stripping the VLAN header, then this
> cannot work unless something re-builds the VLAN header.  If the stripped
> VLAN header is placed into the skb, then any code that does need to
> rebuild it can do so.  It may be less efficient, but users can just
> not use that NIC hardware for high-end solutions, and at any rate,
> less efficient is better than broken.

That is all true. The problem arises when you receive a tagged frame
on eth0, the chip removes the tag, and then the bridge sends it
out untagged on eth1.

I think there are two valid models for VLAN + bridging:

a) bridging works on "physical" interfaces, all tags are transmitted
   unchanged.

b) every VLAN is a different logical interface, packets from unknown
   VLANs are dropped on RX (and thus don't show up anywhere, except
   counters), bridging uses logical interfaces. VLAN 100 on eth0 may
   become VLAN 200 on eth1 and may be untagged on eth2.


"a" requires "soft" VLANs and/or adding the tags back (with
accelerated VLANs). This is how unmanaged switches labeled
"802.1Q - transparent" work. Not very flexible but usually good
enough.

"b" is how switches supporting VLANs (and 802.1Q) usually work.


I know ability to see exactly all packets as they are received
(including tags) is a really nice thing. But maybe we should change
the model? Making the ethX only carry untagged frames (even without
hw VLAN acceleration)?
-- 
Krzysztof Halasa
