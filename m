From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 2/4] NET: NETROM: When adding a route verify length of
 mnemonic string.
Date: Fri, 25 Nov 2011 09:08:49 +0000
Message-ID: <cfff1df64b18a89140ff995189c6a3c484815997.1322214950.git.ralf@linux-mips.org>
References: <cover.1322214950.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Walter Harms <wharms@bfs.de>,
	Thomas Osterried <thomas@osterried.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <cover.1322214950.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct nr_route_struct's mnemonic permits a string of up to 7 bytes to be
used.  If userland passes a not zero terminated string to the kernel adding
a node to the routing table might result in the kernel attempting to read
copy a too long string.

Mnemonic is part of the NET/ROM routing protocol; NET/ROM routing table
updates only broadcast 6 bytes.  The 7th byte in the mnemonic array exists
only as a \0 termination character for the kernel code's convenience.

Fixed by rejecting mnemonic strings that have no terminating \0 in the first
7 characters.  Do this test only NETROM_NODE to avoid breaking NETROM_NEIGH
where userland might passing an uninitialized mnemonic field.

Initial patch by Dan Carpenter <dan.carpenter@oracle.com>.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Walter Harms <wharms@bfs.de>
Cc: Thomas Osterried <thomas@osterried.de>
---
 net/netrom/nr_route.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 915a87b..8d7716c 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -678,6 +678,11 @@ int nr_rt_ioctl(unsigned int cmd, void __user *arg)
 		}
 		switch (nr_route.type) {
 		case NETROM_NODE:
+			if (strnlen(nr_route.mnemonic, 7) == 7) {
+				ret = -EINVAL;
+				break;
+			}
+
 			ret = nr_add_node(&nr_route.callsign,
 				nr_route.mnemonic,
 				&nr_route.neighbour,
-- 
1.7.4.4


