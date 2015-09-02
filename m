From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net 2/2] sctp: add routing output fallback
Date: Wed,  2 Sep 2015 16:20:22 -0300
Message-ID: <47e46293bcd8786484a815786a615c68253f3b50.1441220305.git.marcelo.leitner@gmail.com>
References: <cover.1441220305.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932230AbbIBTUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 15:20:37 -0400
In-Reply-To: <cover.1441220305.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0ca50d12fe46 added a restriction that the address must belong to
the output interface, so that sctp will use the right interface even
when using secondary addresses.

But it breaks IPVS setups, on which people is used to attach VIP
addresses to loopback interface on real servers. It's preferred to
attach to the interface actually in use, but it's a very common setup
and that used to work.

This patch then saves the first routing good result, even if it would be
going out through an interface that doesn't have that address. If no
better hit found, it's then used. This effectively restores the original
behavior if no better interface could be found.

Fixes: 0ca50d12fe46 ("sctp: fix src address selection if using secondary addresses")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/protocol.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4abf94d4cce769371260b42d13c38dbe5776c809..b7143337e4fa025fdb473732fdc064503e731dd4 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -506,16 +506,22 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		if (IS_ERR(rt))
 			continue;
 
+		if (!dst)
+			dst = &rt->dst;
+
 		/* Ensure the src address belongs to the output
 		 * interface.
 		 */
 		odev = __ip_dev_find(sock_net(sk), laddr->a.v4.sin_addr.s_addr,
 				     false);
 		if (!odev || odev->ifindex != fl4->flowi4_oif) {
-			dst_release(&rt->dst);
+			if (&rt->dst != dst)
+				dst_release(&rt->dst);
 			continue;
 		}
 
+		if (dst != &rt->dst)
+			dst_release(dst);
 		dst = &rt->dst;
 		break;
 	}
-- 
2.4.3
