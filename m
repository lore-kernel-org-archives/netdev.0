From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Thu, 20 Aug 2009 22:28:38 +0200
Message-ID: <m31vn6jkll.fsf@intrepid.localdomain>
References: <985009134.71250769263099.JavaMail.root@mail.holmansrus.com>
	<m3skfmk39q.fsf@intrepid.localdomain>
	<20090820.122850.37712606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: walt@holmansrus.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932075AbZHTU2k@vger.kernel.org>
In-Reply-To: <20090820.122850.37712606.davem@davemloft.net> (David Miller's message of "Thu\, 20 Aug 2009 12\:28\:50 -0700 \(PDT\)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> swiotlb emulates what hardware does, so if it can go wrong with
> swiotlb it can go wrong with hardware to.
>
> Figure out what the exact bug is.

I think I already have.

The exact bug is using streaming allocations for the descriptor.
It can't work consistently on all platforms, period. Streaming
allocation can only have one owner (either CPU or device) at a time, and
e100 driver wants access (for examining desc status) simultaneously with
the hardware (which may alter desc status at any time).

On ARM with the previous patch applied it can work because the CPU cache
has the "dirty" bits (e100 driver only reads from the descriptors).
On x86 without swiotlb it can work because streaming allocations are
already coherent.
On x86 with swiotlb it can't really work reliably (and if does, it does
by pure luck) because (I guess) swiotlb has no "dirty" flag and can't
know when it doesn't need to flush.

There is no other fix than to convert the desc rings to coherent
allocs. I'm going to do precisely that in few days, but we're stuck with
the existing code in 2.6.31 (and 2.6.30.x etc).
-- 
Krzysztof Halasa
