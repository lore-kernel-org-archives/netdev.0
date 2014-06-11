From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 1/2] bridge: fix smatch warning / potential null
	pointer dereference
Date: Thu, 12 Jun 2014 01:41:23 +0200
Message-ID: <1402530084-15061-2-git-send-email-linus.luessing@web.de>
References: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
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

 "New smatch warnings:
  net/bridge/br_multicast.c:1368 br_ip6_multicast_query() error:
    we previously assumed 'group' could be null (see line 1349)"

In the rare (sort of broken) case of a query having a Maximum
Response Delay of zero, we could create a potential null pointer
dereference.

Fixing this by skipping the multicast specific MLD Query parsing again
if no multicast group address is available.

Introduced by dc4eb53a996a78bfb8ea07b47423ff5a3aadc362
("bridge: adhere to querier election mechanism specified by RFCs")

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index cd3cf39..876e5fb 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1373,6 +1373,8 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 		br_multicast_query_received(br, port, &br->ip6_other_query,
 					    &saddr, max_delay);
 		goto out;
+	} else if (!group) {
+		goto out;
 	}
=20
 	mp =3D br_mdb_ip6_get(mlock_dereference(br->mdb, br), group, vid);
--=20
1.7.10.4
