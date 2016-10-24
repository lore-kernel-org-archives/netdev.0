From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH net-next 2/2 v2] firewire: net: set initial MTU = 1500
	unconditionally, fix IPv6 on some CardBus cards
Date: Mon, 24 Oct 2016 14:26:13 +0200
Message-ID: <20161024142613.29145f32@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
	<20161020175524.6184-1-jarod@redhat.com>
	<20161020175524.6184-8-jarod@redhat.com>
	<20161022211606.3b5d137d@kant> <20161022212759.228c7642@kant>
	<20161023011824.GE32569@redhat.com> <20161023162903.4166a35d@kant>
	<20161023163056.6bc38610@kant> <20161024015013.GB42084@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Jarod Wilson <jarod@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20161024015013.GB42084@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

firewire-net, like the older eth1394 driver, reduced the initial MTU to
less than 1500 octets if the local link layer controller's asynchronous
packet reception limit was lower.

This is bogus, since this reception limit does not have anything to do
with the transmission limit.  Neither did this reduction affect the TX
path positively, nor could it prevent link fragmentation at the RX path.

Many FireWire CardBus cards have a max_rec of 9, causing an initial MTU
of 1024 - 16 = 1008.  RFC 2734 and RFC 3146 allow a minimum max_rec = 8,
which would result in an initial MTU of 512 - 16 = 496.  On such cards,
IPv6 could only be employed if the MTU was manually increased to 1280 or
more, i.e. IPv6 would not work without intervention from userland.

We now always initialize the MTU to 1500, which is the default according
to RFC 2734 and RFC 3146.

On a VIA VT6316 based CardBus card which was affected by this, changing
the MTU from 1008 to 1500 also increases TX bandwidth by 6 %.
RX remains unaffected.

CC: netdev@vger.kernel.org
CC: linux1394-devel@lists.sourceforge.net
CC: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
v2: use ETH_DATA_LEN, add comment

 drivers/firewire/net.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 99379542b263..29dbcba38f59 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1463,13 +1463,8 @@ static int fwnet_probe(struct fw_unit *unit,
 		goto out;
 	dev->local_fifo = dev->handler.offset;
 
-	/*
-	 * Use the RFC 2734 default 1500 octets or the maximum payload
-	 * as initial MTU
-	 */
-	net->mtu = min(1500U,
-		       (1U << (card->max_receive + 1))
-		       - RFC2374_FRAG_HDR_SIZE - IEEE1394_GASP_HDR_SIZE);
+	/* MTU range: 68 - 65535, RFC 2734 default: 1500 */
+	net->mtu = ETH_DATA_LEN;
 	net->min_mtu = ETH_MIN_MTU;
 	net->max_mtu = ETH_MAX_MTU;
 
-- 
2.7.3



-- 
Stefan Richter
-======----- =-=- ==---
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most 
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
