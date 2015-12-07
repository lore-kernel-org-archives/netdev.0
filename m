From: Edward Cree <ecree@solarflare.com>
Subject: Checksum offload queries
Date: Mon, 7 Dec 2015 15:39:52 +0000
Message-ID: <5665A848.9010001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:27173 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932432AbbLGPrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 10:47:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having decided to take Dave Miller's advice to push our hardware guys in the direction of generic checksum offload, I found I wasn't quite sure exactly what's being encouraged.  After discussing the subject with a colleague, some questions crystallised.  I expect it's mostly a result of misunderstandings on my part, but here goes:

1) Receive checksums.  Given that CHECKSUM_UNNECESSARY conversion exists (and is a cheap operation), what is the advantage to the stack of using CHECKSUM_COMPLETE if the packet happens to be a protocol which CHECKSUM_UNNECESSARY conversion can handle?  As I see it, CHECKSUM_UNNECESSARY is strictly better as the stack is told "the first csum_level+1 checksums are good" *and* (indirectly) "here is the whole-packet checksum, which you can use to help with anything beyond csum_level+1".  Is it not, then, best for a device only to use CHECKSUM_COMPLETE for protocols the conversion doesn't handle?  (I agree that having that fallback of CHECKSUM_COMPLETE is a good thing, sadly I don't think our new chip does that.  (But maybe firmware can fix it.))

2) Transmit checksums.  While many protocols permit using 0 in the outer checksum, it doesn't seem prudent to assume all will.  Besides, many NICs will still have IP and TCP/UDP checksum offload hardware, if only to support less enlightened operating systems; why not use it?  Would it not be better for a device to have both NETIF_F_HW_CSUM *and* NETIF_F_IP[|V6]_CSUM, and be smart enough to fill in IP checksum, TCP/UDP checksum and one encapsulated checksum of your choice (i.e. whatever csum_start and friends asked for)?  (Again, I agree that having a NETIF_F_IP_CSUM device do specific magic for a list of specific encapsulation protocols is unsatisfactory.  Sadly, guess what our new chip does!  (But maybe firmware can fix it.))

3) Related to the above, what does a NETIF_F_HW_CSUM device do when transmitting an unencapsulated packet (let's say it's UDP) currently?  Will it simply get no checksum offload at all?  Will csum_start point at the regular UDP checksum (and the stack will do the IP header checksum)?  Again, a device that does both HW_ and IP_CSUM could cope with this (do the IP and UDP checksums as per NETIF_F_IP_CSUM, and just don't ask for a 'generic' HW_CSUM), though that would require more checksum flags (there's no way for CHECKSUM_PARTIAL to say "do your IP-specific stuff but ignore csum_start and friends).

4) Where, precisely, should I tell our hardware guys to stuff the protocol-specific encapsulated checksum offloads they're so proud of having added to our new chip? ;)

--
Edward Cree, not speaking for Solarflare Communications
