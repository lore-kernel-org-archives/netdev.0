From: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v3 0/2] Add TSO for iwlwifi
Date: Wed, 21 Oct 2015 21:34:22 +0300
Message-ID: <1445452464-19525-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Here is a v3 of the series that has been sent uite a while
ago. V3 is completly different from v2 and (tries to)
address Eric's comments.
I have to admit that the code looks much easier now :)
The purpose is still to be able to create an A-MSDU from
a large send.

iwlwifi is split into 2 different layers:
the op_mode (iwlmvm.ko) and the transport (iwlwifi.ko).

The transport uses the the TSO core to split the payload
and builds an A-MSDU out of it. It needs additional memory
to store the new headers (n - 1) SNAP / IP / TCP headers
that weren't in the original skb and the 802.11 subframe
headers with padding. I allocate a per-cpu page to hold
these headers. When the page is full, I get a new one.
This is the most efficient way I could think about because
it avoids to allocate a (rather big: ~140 byte) data
structure for each Tx descriptor (and we have a lot...).
This is also efficient in terms of data locality.
Allocating / freeing a page is supposed to be very fast.

Since the transport doesn't handle sequence numbers and
other per 802.11 packet related stuff, it needs to get
only one 802.11 at a time. The problem here is that based
on link condition and peer caps, the size of the maximal
802.11 packet may vary: a same netdev can send data to
different peers (think about 2 stations associated to an
Access Point) and then, skbs coming from the same netdev
need to be split into chunks of different sizes so that the
transport will be able to create A-MSDUs. This will happen
if one station supports 11K A-MSDU, while the other one
supports 4K A-MSDU only. This requirement disallows the
use of gso_max_{segs,size} since they can't differentiate
between different peers.

Of course, I could make the transport aware of all the
sequence numbers and friends, but that seemed too
intrusive into the current architecture.
Instead, I prefered to use skb_gso_segment and let it do
the work. When I get an skb to be sent, I know the peer
and its caps. I can then determine what is the maximal
length of A-MSDU for this peer and skb_gso_segment this
skb with gso_size set to that maximal A-MSDU length.
Note that the maximal A-MSDU length can be up to 11K
nowadays, so we are far from the limit of the 2 bytes
of gso_size.
After I did that, I only need to fixup slightly the id in
the IP header.

There are still a few minor TODOs here and there, but
I think (and hope) we are getting close :)

Emmanuel Grumbach (2):
  iwlwifi: pcie: allow to build an A-MSDU using TSO core
  iwlwifi: mvm: send large SKBs to the transport

 drivers/net/wireless/iwlwifi/iwl-devtrace-data.h |  16 ++
 drivers/net/wireless/iwlwifi/iwl-trans.h         |   6 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c            | 143 +++++++++++-
 drivers/net/wireless/iwlwifi/pcie/internal.h     |   7 +
 drivers/net/wireless/iwlwifi/pcie/trans.c        |  20 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c           | 286 ++++++++++++++++++++++-
 6 files changed, 464 insertions(+), 14 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
