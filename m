From: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v3 0/3] add TSO / A-MSDU TX for iwlwifi
Date: Thu, 20 Aug 2015 11:15:41 +0300
Message-ID: <1440058544-20342-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

An A-MSDU is a 802.11 frame that comprises several L3
segments:
Each subframe has a ETH / SNAP / IP / TCP header (in case 
TCP is used of course). Each subframe has no 802.11
limitation on its length (only the MSS limitation), but
the whole A-MSDU has a size limit both in number of
subframes, and in bytes. In the best conditions, the
A-MSDU is unlimited in number of subframes, and can be up
to 11K byte long. An A-MSDU has only one WiFi MAC address,
and hence, each A-MSDU can be sent to only one WiFi peer.

There a 2 ways to get A-MSDU:
 * xmit_more
 * LSO
 * LSO + skb_gso_segment

The problem with xmit_more is that in AP mode, the Qdisc
can have packets for several L2 clients which makes is
harder to use since as stated above, an A-MSDU can be sent
to one single WiFi peer.

The problem with LSO is that the LSO packet is very likely
to be way bigger than the maximal A-MSDU length. This means
that a single LSO packet will generate several WiFi packets.
>From an arch point of view, having different WiFi packets
sitting in one single skb is a problem, so we need to create
several skbs out of one single LSO packet. This makes the
usage of currently existing helpers (net/core/tso.c) very
hard.

Using LSO and skb_gso_segment is a bit wasteful since we
don't need an skb for each MSS, so that we would have to
reassemble the segs into one single packet. This is
sub-efficient.

Out of the two aforementioned ways, I chose to work with
LSO and implemented the segmentation in the driver itself.
While this code can technically be made driver agnostic,
the trend in the industry seems to show that more and more
vendors split the buffers in the firmware, so that I don't
expect to see any new devices coming up with the same
behavior as ours. I did take a look on currently existing
drivers and they already do the work in firmware.
If someone in linux-wireless thinks that this code can
serve his purposes, please speak up. All you'd need is to
support TX_CSUM and SG.

The additional headers needed (SNAP / IP / TCP) are copied
and updated on a page which is allocated in xmit. This is
supposed to very cheap. I add skb frags from that page to 
add the skb. Since I can have several 802.11 packets from a
single LSO packet, I allocated skb's on the way if needed.

I am quite a newbie in skb handling, so I guess that this
code can be improved. I have tested it decently using iperf,
but this doesn't mean that there are no issues using other
applications. We are enabling pktgen on TCP (using patches
that were sent a year ago or so) to test the different
layouts of the skb (payload partition amongst the header
and the different frags).

Changes since v2:
*****************
   + I fixed the whitespace problem spotted by Sergei.
   + I changed the D'tor check for truesize accounting.
     Since the D'tor seems to be set to tcp_wfree if it
     exists, I just the D'tor not being NULL.

Emmanuel Grumbach (3):
  iwlwifi: mvm: add real TSO implementation
  iwlwifi: mvm: allow to create A-MSDUs from a large send
  iwlwifi: mvm: transfer the truesize to the last TSO segment

 drivers/net/wireless/iwlwifi/mvm/mac80211.c |   3 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c      |   4 +-
 drivers/net/wireless/iwlwifi/mvm/sta.h      |   6 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c       | 669 ++++++++++++++++++++++++++--
 4 files changed, 647 insertions(+), 35 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
