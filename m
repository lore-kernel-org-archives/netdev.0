From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bridge: mdb: avoid uninitialized variable warning
Date: Wed, 10 Feb 2016 16:09:02 +0100
Message-ID: <1455116946-2948649-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
	linux-arm-kernel@lists.infradead.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

A recent change to the mdb code confused the compiler to the point
where it did not realize that the port-group returned from
br_mdb_add_group() is always valid when the function returns a nonzero
return value, so we get a spurious warning:

net/bridge/br_mdb.c: In function 'br_mdb_add':
net/bridge/br_mdb.c:542:4: error: 'pg' may be used uninitialized in this function [-Werror=maybe-uninitialized]
    __br_mdb_notify(dev, entry, RTM_NEWMDB, pg);

Slightly rearranging the code in br_mdb_add_group() makes the problem
go away, as gcc is clever enough to see that both functions check
for 'ret != 0'.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 9e8430f8d60d ("bridge: mdb: Passing the port-group pointer to br_mdb module")
---
 net/bridge/br_mdb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index ac089286526e..9ab1fcd488c6 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -437,8 +437,8 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	mp = br_mdb_ip_get(mdb, group);
 	if (!mp) {
 		mp = br_multicast_new_group(br, port, group);
-		err = PTR_ERR(mp);
-		if (IS_ERR(mp))
+		err = PTR_ERR_OR_ZERO(mp);
+		if (err)
 			return err;
 	}
 
-- 
2.7.0
