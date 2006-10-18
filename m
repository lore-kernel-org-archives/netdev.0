From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: [RFC] Ethernet Cheap Cryptography
Date: Tue, 17 Oct 2006 20:21:46 -0700
Message-ID: <17717.40394.531846.695392@localhost.localdomain>
References: <200610151820.22867.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:61990 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1751188AbWJRDWt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 23:22:49 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
In-Reply-To: <200610151820.22867.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dawid Ciezarkiewicz writes:
 >  I'd be thankful for your opinions about that idea. Please forgive me any
 > nuances that I didn't know about.

* I suggest extending the documentation with some motivating examples
  of why someone would want to use this rather than IPsec for IP
  and/or in what scenarios you'd envisage someone wanting to encrypt
  ARP, PPPoE, ... etc.  Perhaps, you can somehow mesh it with 802.1x
  to provide link-level encryption to augment 802.1x link-level
  authentication?

* Your implementation allows the key to be changed but not in a way
  that allows both sides to do so without disrupting traffic i.e. you
  don't have something akin to IKE phase2 re-keying.  Without that
  then if someone can sniff the traffic long enough they are going to
  get a big sample of data to try and crack the keys with.
  
* You write "frames will be delivered in order, so on the other side
  IV can be always in sync."  If any switches between the two linux
  boxes are running any kind of link aggregation then you can't
  guarantee that the frames will be delivered in order.  IEEE 802.3ad
  requires that packets belonging to the same session travel down the
  same port to avoid re-ordering but implementations vary as to
  whether they actually guarantee it or not since most higher level
  protcols can survive some re-ordering.

* Given your desire not to change the size of the payload you have no
  space for MAC.  This makes it easier (but by no means easy) to alter
  the payload in such a way that it is still decrypted and considered
  valid.

* For the same reason as above you don't have a sequence number.  This
  combined with the lack of MAC weakens the defense against replay
  attacks i.e. where third party captures a packet and then re-sends
  it at a later time.  The fact that IVs must be in sync for the
  packet to be accepted makes it harder for an attacker but since they
  know how the IV is calculated they know what message to look for
  before replaying a packet.

* A variation of the above is that the attacker doesn't care about
  injecting packets per se, rather they use the above to cause packet
  loss by causing the receiver to update its IV based on a replayed
  packet thereby causing the next "real" packet to be dropped because
  the IV is out of sync.
