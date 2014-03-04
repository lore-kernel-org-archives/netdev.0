From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: multicast: add sanity check for query
	source addresses
Date: Tue,  4 Mar 2014 03:57:35 +0100
Message-ID: <1393901855-18231-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Florian Westphal <fwestpha@redhat.com>, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Jan Stancek <jstancek@redhat.com>
To: netdev@vger.kernel.org
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

MLD queries are supposed to have an IPv6 link-local source address
according to RFC2710, section 4 and RFC3810, section 5.1.14. This patch
adds a sanity check to ignore such broken MLD queries.

Without this check, such malformed MLD queries can result in a
denial of service: The queries are ignored by any MLD listener
therefore they will not respond with an MLD report. However,
without this patch these malformed MLD queries would enable the
snooping part in the bridge code, potentially shutting down the
according ports towards these hosts for multicast traffic as the
bridge did not learn about these listeners.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index ef66365..fb0e36f 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1235,6 +1235,12 @@ static int br_ip6_multicast_query(struct net_bridg=
e *br,
 	    (port && port->state =3D=3D BR_STATE_DISABLED))
 		goto out;
=20
+	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addresses */
+	if (!(ipv6_addr_type(&ip6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
+		err =3D -EINVAL;
+		goto out;
+	}
+
 	if (skb->len =3D=3D sizeof(*mld)) {
 		if (!pskb_may_pull(skb, sizeof(*mld))) {
 			err =3D -EINVAL;
--=20
1.7.10.4
