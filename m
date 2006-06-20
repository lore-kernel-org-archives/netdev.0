From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/5] GSO: Generic Segmentation Offload
Date: Tue, 20 Jun 2006 19:09:19 +1000
Message-ID: <20060620090919.GA31613@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:10250 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030191AbWFTJJ1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 05:09:27 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This series adds Generic Segmentation Offload (GSO) support to the Linux
networking stack.

Many people have observed that a lot of the savings in TSO come from
traversing the networking stack once rather than many times for each
super-packet.  These savings can be obtained without hardware support.
In fact, the concept can be applied to other protocols such as TCPv6,
UDP, or even DCCP.

The key to minimising the cost in implementing this is to postpone the
segmentation as late as possible.  In the ideal world, the segmentation
would occur inside each NIC driver where they would rip the super-packet
apart and either produce SG lists which are directly fed to the hardware,
or linearise each segment into pre-allocated memory to be fed to the NIC.
This would elminate segmented skb's altogether.

Unfortunately this requires modifying each and every NIC driver so it
would take quite some time.  A much easier solution is to perform the
segmentation just before the entry into the driver's xmit routine.  This
series of patches does this.

I've attached some numbers to demonstrate the savings brought on by
doing this.  The best scenario is obviously the case where the underlying
NIC supports SG.  This means that we simply have to manipulate the SG
entries and place them into individual skb's before passing them to the
driver.  The attached file lo-res shows this.

The test was performed through the loopback device which is a fairly good
approxmiation of an SG-capable NIC.

GSO like TSO is only effective if the MTU is significantly less than the
maximum value of 64K.  So only the case where the MTU was set to 1500 is
of interest.  There we can see that the throughput improved by 17.5%
(3061.05Mb/s => 3598.17Mb/s).  The actual saving in transmission cost is
in fact a lot more than that as the majority of the time here is spent on
the RX side which still has to deal with 1500-byte packets.

The worst-case scenario is where the NIC does not support SG and the user
uses write(2) which means that we have to copy the data twice.  The files
gso-off/gso-on provide data for this case (the test was carried out on
e100).  As you can see, the cost of the extra copy is mostly offset by the
reduction in the cost of going through the networking stack.

For now GSO is off by default but can be enabled through ethtool.  It is
conceivable that with enough optimisation GSO could be a win in most cases
and we could enable it by default.

However, even without enabling GSO explicitly it can still function on
bridged and forwarded packets.  As it is, passing TSO packets through a
bridge only works if all constiuents support TSO.  With GSO, it provides
a fallback so that we may enable TSO for a bridge even if some of its
constituents do not support TSO.

This provides massive savings for Xen as it uses a bridge-based architecture
and TSO/GSO produces a much larger effective MTU for internal traffic between
domains.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
