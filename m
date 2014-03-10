From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 1/2] bridge: multicast: add sanity check for
	general query destination
Date: Mon, 10 Mar 2014 04:39:45 +0100
Message-ID: <1394422786-1683-1-git-send-email-linus.luessing@web.de>
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

General IGMP and MLD queries are supposed to have the multicast
link-local all-nodes address as their destination according to RFC2236
section 9, RFC3376 section 4.1.12/9.1, RFC2710 section 8 and RFC3810
section 5.1.15.

Without this check, such malformed IGMP/MLD queries can result in a
denial of service: The queries are ignored by most IGMP/MLD listeners
therefore they will not respond with an IGMP/MLD report. However,
without this patch these malformed MLD queries would enable the
snooping part in the bridge code, potentially shutting down the
according ports towards these hosts for multicast traffic as the
bridge did not learn about these listeners.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index fb0e36f..c77f073 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1181,6 +1181,14 @@ static int br_ip4_multicast_query(struct net_bridg=
e *br,
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
 	}
=20
+	/* RFC2236+RFC3376 (IGMPv2+IGMPv3) require the multicast link layer
+	 * all-systems destination addresses (224.0.0.1) for general queries
+	 */
+	if (!group && iph->daddr !=3D htonl(INADDR_ALLHOSTS_GROUP)) {
+		err =3D -EINVAL;
+		goto out;
+	}
+
 	br_multicast_query_received(br, port, &br->ip4_querier, !!iph->saddr,
 				    max_delay);
=20
@@ -1228,6 +1236,7 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 	unsigned long max_delay;
 	unsigned long now =3D jiffies;
 	const struct in6_addr *group =3D NULL;
+	bool is_general_query;
 	int err =3D 0;
=20
 	spin_lock(&br->multicast_lock);
@@ -1262,6 +1271,16 @@ static int br_ip6_multicast_query(struct net_bridg=
e *br,
 		max_delay =3D max(msecs_to_jiffies(mldv2_mrc(mld2q)), 1UL);
 	}
=20
+	is_general_query =3D group && ipv6_addr_any(group) ? true : false;
+
+	/* RFC2710+RFC3810 (MLDv1+MLDv2) require the multicast link layer
+	 * all-nodes destination address (ff02::1) for general queries
+	 */
+	if (is_general_query && !ipv6_addr_is_ll_all_nodes(&ip6h->daddr)) {
+		err =3D -EINVAL;
+		goto out;
+	}
+
 	br_multicast_query_received(br, port, &br->ip6_querier,
 				    !ipv6_addr_any(&ip6h->saddr), max_delay);
=20
--=20
1.7.10.4
