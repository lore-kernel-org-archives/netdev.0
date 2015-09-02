From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net 1/2] sctp: fix dst leak
Date: Wed,  2 Sep 2015 16:20:21 -0300
Message-ID: <e6339177cb0ff680f451cbfb6c2cf44f148c1d11.1441220305.git.marcelo.leitner@gmail.com>
References: <cover.1441220305.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbbIBTUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 15:20:35 -0400
In-Reply-To: <cover.1441220305.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0ca50d12fe46 failed to release the reference to dst entries that
it decided to skip.

Fixes: 0ca50d12fe46 ("sctp: fix src address selection if using secondary addresses")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/protocol.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4345790ad3266c353eeac5398593c2a9ce4effda..4abf94d4cce769371260b42d13c38dbe5776c809 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -511,8 +511,10 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		 */
 		odev = __ip_dev_find(sock_net(sk), laddr->a.v4.sin_addr.s_addr,
 				     false);
-		if (!odev || odev->ifindex != fl4->flowi4_oif)
+		if (!odev || odev->ifindex != fl4->flowi4_oif) {
+			dst_release(&rt->dst);
 			continue;
+		}
 
 		dst = &rt->dst;
 		break;
-- 
2.4.3
