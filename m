From: Simon Kirby <sim@hostway.ca>
Subject: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Fri, 3 Dec 2010 02:34:47 -0800
Message-ID: <20101203103447.GA29714@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:34344 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932397Ab0LCKzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Dec 2010 05:55:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

We upgraded some LVS (DR) servers from 2.6.35 to 2.6.36 on tg3 cards
(partno(BCM95721) rev 4201) with VLAN tags in use, to think that
everything looked great, but in fact...

LVS was receiving magically-merged TCP packets which it tried to forward
on to the real server, only to get annoyed at itself for trying to
forward a packet bigger than the device MTU:

IP A.47376 > B.529: . 175488:176936(1448) ack 1 win 92 <nop,nop,timestamp 52737308 29656081>
IP A.47376 > B.529: . 176936:179832(2896) ack 1 win 92 <nop,nop,timestamp 52737325 29656098>
IP B > A: ICMP B unreachable - need to frag (mtu 1500), length 556

This caused packet loss for any merged frames, which caused abysmal
performance for uploads via the LVS server.  Local performance to or
from the box is still fine, because the stack doesn't care, only the
forwarding part of LVS is running into the problem.

Furthermore, disabling _everything_ reported by ethtool -k doesn't seem
to change the result, even if I down/up the interface after, and even if
I try on every single interface including the VLANned ones.  This seems
to be another bug.  Reverting to 2.6.35 makes it all work again.

Possibly related to commit 7fe876af921d1d2bc8353e0062c10ff35e902653

So how should this be fixed?  Should LVS be taught to fragment, or must
we disable the merging in this case?  It seems like it would work well if
the sending side could do the same offload in reverse, but I'm not sure
if that would be possible.

Simon-
