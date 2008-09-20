From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .28
Date: Sat, 20 Sep 2008 00:09:14 -0700 (PDT)
Message-ID: <20080920.000914.219711773.davem@davemloft.net>
References: <20080914022236.GA15673@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brice@myri.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53208
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750816AbYITHJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 03:09:26 -0400
In-Reply-To: <20080914022236.GA15673@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sat, 13 Sep 2008 22:22:36 -0400

> Please pull from 'davem-next' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next
> 
> to receive the following updates:

Jeff, I pulled this and I was going to push back out but I couldn't
because there are two or three changes in here I think have major
problems.

First, the two myri10ge patches that do the Toeplitz TX hashing
stuff.

--------------------
myri10ge: Add Toeplitz-hashing related routines

myri10ge uses a Toeplitz hashing. Add the corresponding select_queue()
method without using it yet.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

myri10ge: Add multiqueue TX support

Add multiqueue TX support to myri10ge, using Toeplitz hashing.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
--------------------

No, that is crap.  I didn't create the ->select_tx_queue() callback so
that each and every damn multiqueue driver will override the generic
TX hash function in order to try and make the TX hashing match the RX
hashing.

That's not what it's for.

The callback exists for things like wireless where the queues have
a meaning other than flow seperation.

We (specifically Herbert Xu and myself) know that for routing and
firewalling applications matching the TX queue to the same hashing
namespace of the RX multiqueueing is desirable for best performance.

But we will do that generically by allowing the driver on the receive
side to record the RX hash used (or alternatively, if the exact RSS
hash isn't obtainable, the RX queue index itself) and on TX we will
use this information to select the TX queue properly.

Next, a bad IXGBE change:

--------------------
ixgbe: make compilation with LRO optional

The current ixgbe forces LRO to always be enabled.  This patch makes this
optional due to the fact so that LRO can be disabled in cases where it is
not desirable such as routing or bridging.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
--------------------

Ummm, no.  This is completely unnecessary and it's another thing we
don't want every damn driver doing.  It is almost as bad as making
NAPI configurable.

If the user enables forwarding or bridging, the kernel automatically
disable LRO on the appropriate interfaces.

Jeff, please rebuild your tree with those three patches removed and I'll
repull.  Those patches were near or at the end of the group of changes
for their effected drivers, so there should be absolutely zero conflicts
or merge windows when you do this tree rebuild.

Thanks!
