From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] econet: 4 byte infoleak to the network
Date: Thu, 17 Mar 2011 14:40:10 +0300
Message-ID: <1300362011-8653-1-git-send-email-segoon@openwall.com>
Cc: security@kernel.org, "David S. Miller" <davem@davemloft.net>,
	Phil Blundell <philb@gnu.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Nelson Elhage <nelhage@ksplice.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct aunhdr has 4 padding bytes between 'pad' and 'handle' fields on
x86_64.  These bytes are not initialized in the variable 'ah' before
sending 'ah' to the network.  This leads to 4 bytes kernel stack
infoleak.

This bug was introduced before the git epoch.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 net/econet/af_econet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 0c28263..116d3fd 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -435,10 +435,10 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		udpdest.sin_addr.s_addr = htonl(network | addr.station);
 	}
 
+	memset(&ah, 0, sizeof(ah));
 	ah.port = port;
 	ah.cb = cb & 0x7f;
 	ah.code = 2;		/* magic */
-	ah.pad = 0;
 
 	/* tack our header on the front of the iovec */
 	size = sizeof(struct aunhdr);
-- 
1.7.0.4
