From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: don't try to update timers in case of
	broken MLD queries
Date: Tue,  6 Aug 2013 00:32:05 +0200
Message-ID: <1375741925-22179-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Paul Bolle <pebolle@tiscali.nl>, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Adam Baker <linux@baker-net.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: bridge@lists.linux-foundation.org
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

Currently we are reading an uninitialized value for the max_delay
variable when snooping an MLD query message of invalid length and would
update our timers with that.

Fixing this by simply ignoring such broken MLD queries (just like we do
for IGMP already).

This is a regression introduced by:
"bridge: disable snooping if there is no querier" (b00589af3b04)

Reported-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 61c5e81..08e576a 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1195,7 +1195,7 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 		max_delay =3D msecs_to_jiffies(ntohs(mld->mld_maxdelay));
 		if (max_delay)
 			group =3D &mld->mld_mca;
-	} else if (skb->len >=3D sizeof(*mld2q)) {
+	} else {
 		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
 			err =3D -EINVAL;
 			goto out;
--=20
1.7.10.4
