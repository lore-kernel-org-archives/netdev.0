From: Arthur Jones <ajones@riverbed.com>
Subject: [net-next PATCH] igb: allow tx of pre-formatted vlan
	tagged packets
Date: Thu, 12 Mar 2009 14:33:45 -0700
Message-ID: <20090312213345.GA12653@ajones-laptop.nbttech.com>
References: <20090312202724.GA9876@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Hemminger <shemminger@vyatta.com>, Stephen
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20090312202724.GA9876@ajones-laptop.nbttech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When the 82575 is fed 802.1q packets, it chokes with
an error of the form:

igb 0000:08:00.1: partial checksum but proto=81

As the logic there was not smart enough to look into
the vlan header to pick out the encapsulated protocol.

There are times when we'd like to send these packets
out without having to configure a vlan on the interface.
Here we check for the vlan tag and allow the packet to
go out with the correct hardware checksum.

Thanks to Kand Ly <kand@riverbed.com> for discovering the
issue and the coming up with a solution.  This patch is
based upon his work.

Macro fixups from Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/igb/igb_main.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 78558f8..e4ef1f6 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3017,7 +3017,17 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			switch (skb->protocol) {
+			__be16 protocol;
+
+			if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
+				const struct vlan_ethhdr *vhdr =
+					(const struct vlan_ethhdr *) skb->data;
+
+				protocol = vhdr->h_vlan_encapsulated_proto;
+			} else
+				protocol = skb->protocol;
+
+			switch (protocol) {
 			case cpu_to_be16(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
-- 
1.5.6.3

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
