From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH net-next 1/2] firewire: net: fix maximum possible MTU
Date: Sun, 23 Oct 2016 16:29:03 +0200
Message-ID: <20161023162903.4166a35d@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161020175524.6184-1-jarod@redhat.com>
        <20161020175524.6184-8-jarod@redhat.com>
        <20161022211606.3b5d137d@kant>
        <20161022212759.228c7642@kant>
        <20161023011824.GE32569@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
        Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161023011824.GE32569@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit b3e3893e1253 ("net: use core MTU range checking in misc drivers")
mistakenly introduced an upper limit for firewire-net's MTU based on the
local link layer controller's reception capability.  Revert this.  Neither
RFC 2734 nor our implementation impose any particular upper limit.

Actually, to be on the safe side and to make the code explicit, set
ETH_MAX_MTU = 65535 as upper limit now.

(I replaced sizeof(struct rfc2734_header) by the equivalent
RFC2374_FRAG_HDR_SIZE in order to avoid distracting long/int conversions.)

Fixes: b3e3893e1253('net: use core MTU range checking in misc drivers')
CC: netdev@vger.kernel.org
CC: linux1394-devel@lists.sourceforge.net
CC: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/firewire/net.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 8430222151fc..99379542b263 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1467,10 +1467,11 @@ static int fwnet_probe(struct fw_unit *unit,
 	 * Use the RFC 2734 default 1500 octets or the maximum payload
 	 * as initial MTU
 	 */
-	net->max_mtu = (1 << (card->max_receive + 1))
-		       - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
-	net->mtu = min(1500U, net->max_mtu);
+	net->mtu = min(1500U,
+		       (1U << (card->max_receive + 1))
+		       - RFC2374_FRAG_HDR_SIZE - IEEE1394_GASP_HDR_SIZE);
 	net->min_mtu = ETH_MIN_MTU;
+	net->max_mtu = ETH_MAX_MTU;
 
 	/* Set our hardware address while we're at it */
 	ha = (union fwnet_hwaddr *)net->dev_addr;
-- 
Stefan Richter
-======----- =-=- =-===
http://arcgraph.de/sr/
