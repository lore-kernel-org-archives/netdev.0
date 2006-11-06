From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 12:54:55 -0800
Message-ID: <adawt68jnxc.fsf@cisco.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77E29496@nekter>
	<20061106204643.GA11788@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:48050 "EHLO
	sj-iport-3.cisco.com") by vger.kernel.org with ESMTP
	id S1753780AbWKFUzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 15:55:24 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061106204643.GA11788@infradead.org> (Christoph Hellwig's message of "Mon, 6 Nov 2006 20:46:43 +0000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > For consistencies sake we really want to have readq() and writeq() available
 > on all platforms.  I remember that some IB cards require it to actually
 > be a 64bit transactions, otherwise they have to do funny workarounds.
 > I think the best solution is to define ARCH_HAS_ATOMIC_READQ_WRITEQ
 > and let drivers do their workarounds based on that.
 > 
 > I've Cc'ed Roland because he should be able to explain the IB issue in
 > details.

The issue I know about is drivers/infiniband/hw/mthca.  The card has
64-bit "doorbell registers", and the restriction is that if you write
the doorbell write two 32-bit writes, you can't write anything else on
the same register page in between writing the two halves.  Since
different CPUs might be doing stuff on the same doorbell page at the
same time, there are two things we can do:
 - If writeq() exists then use that and assume it will generate only a
   single bus transaction that can't let anything sneak in the
   middle.  (That's a fairly safe assumption because the devices being
   driven are either 64-bit PCI-X or PCIe only)
 - If writeq() doesn't exist, use a spinlock to protect access to each
   doorbell page.

ARCH_HAS_ATOMIC_READQ_WRITEQ would be fine for that, but of course the
tricky thing is writing down the exact semantics that "HAS_ATOMIC" is
actually promising.

 - R.
