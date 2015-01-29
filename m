From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 0/4] Fix checksum error when using stacked
	vlan
Date: Thu, 29 Jan 2015 20:37:06 +0900
Message-ID: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When I was testing 802.1ad, I found several drivers don't take into
account 802.1ad or multiple vlans when retrieving L3 (IP/IPv6) or
L4 (TCP/UDP) protocol for checksum offload.

It is mainly due to vlan_get_protocol(), which extracts ether type only
when it is tagged with single 802.1Q. When 802.1ad is used or there are
multiple vlans, it extracts vlan protocol and drivers cannot determine
which L3/L4 protocol is used.

Those drivers, most of which have IP_CSUM/IPV6_CSUM features, get L3/L4
header-offset by software, so it seems that their checksum offload works
with multiple vlans if we can parse protocols correctly.
(They know mac header length, and probably don't care about what is in it.)

And another thing, some of Intel's drivers seem to use skb->protocol where
vlan_get_protocol() is more suitable.

I tested that at least igb/igbvf on I350 works with this patch set.

Note:
We can hand a double tagged packet with CHECKSUM_PARTIAL to a HW driver
by creating a vlan device on a bridge device and enabling vlan_filtering
of the bridge with 802.1ad protocol.

Toshiaki Makita (4):
  net: Fix vlan_get_protocol for stacked vlan
  igbvf: Fix checksum error when using stacked vlan
  ixgbe: Fix checksum error when using stacked vlan
  ixgbevf: Fix checksum error when using stacked vlan

 drivers/net/ethernet/intel/igbvf/netdev.c         | 19 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +-
 include/linux/if_vlan.h                           | 60 +++++++++++++++++------
 net/core/dev.c                                    | 31 +-----------
 5 files changed, 61 insertions(+), 55 deletions(-)

-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
