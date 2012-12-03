From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net/macb: Use non-coherent memory for rx buffers
Date: Mon, 3 Dec 2012 12:43:51 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70D5@saturn3.aculab.com>
References: <CAGhQ9VwWmP_B17LnAEqDHcL8Yd-s0C-Bf35z3+=vnJmK_NoCSw@mail.gmail.com> <1354536876-6274-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	"Joachim Eastwood" <manabian@gmail.com>,
	"Jean-Christophe PLAGNIOL-VILLARD" <plagnioj@jcrosoft.com>,
	"Havard Skinnemoen" <havard@skinnemoen.net>
To: "Nicolas Ferre" <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1354536876-6274-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Allocate regular pages to use as backing for the RX ring and use the
> DMA API to sync the caches. This should give a bit better performance
> since it allows the CPU to do burst transfers from memory. It is also
> a necessary step on the way to reduce the amount of copying done by
> the driver.

I've not tried to understand the patches, but you have to be
very careful using non-snooped memory for descriptor rings.
No amount of DMA API calls can sort out some of the issues.

Basically you must not dirty a cache line that contains data
that the MAC unit might still write to.

For the receive ring this means that you must not setup
new rx buffers for ring entries until the MAC unit has
filled all the ring entries in the same cache line.
This probably means only adding rx buffers in blocks
of 8 or 16 (or even more if there are large cache lines).

I can't see any code in the patch that does this.

Doing the same for the tx ring is more difficult, especially
if you can't stop the MAC unit polling the TX ring on a
timer basis.
Basically you can only give the MAX tx packets if either
it is idle, or if the tx ring containing the new entries
starts on a cache line.
If the MAC unit is polling the ring, then to give it
multiple items you may need to update the 'owner' bit
in the first ring entry last - just in case the cache
line gets written out before you've finished.

	David
