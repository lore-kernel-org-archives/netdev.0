From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v3] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 17:36:11 +0300
Message-ID: <1463582171-24083-1-git-send-email-aryabinin@virtuozzo.com>
References: <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

->sk_shutdown bits share one bitfield with some other bits in sock struct,
such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
sock_setsockopt() may write to these bits, while holding the socket lock.

In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
to corrupting these bits.

Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
This will not change the 'struct sock' size since ->sk_shutdown moved into
previously unused 16-bit hole.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Changes since v1:
 - move sk_shutdown into a separate byte instead of locking
	AF_UNIX sockets.

Changes since v2:
 - reorder bitfields, so that sk_type/sk_protocol still fit in
    separate 2-bytes/byte.
	
 include/net/sock.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c9c8b19..1c019d4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -383,12 +383,11 @@ struct sock {
 	int			sk_sndbuf;
 	struct sk_buff_head	sk_write_queue;
 	kmemcheck_bitfield_begin(flags);
-	unsigned int		sk_shutdown  : 2,
+	unsigned int		sk_type : 16,
+				sk_protocol : 8,
 				sk_no_check_tx : 1,
 				sk_no_check_rx : 1,
-				sk_userlocks : 4,
-				sk_protocol  : 8,
-				sk_type      : 16;
+				sk_userlocks : 4;
 #define SK_PROTOCOL_MAX U8_MAX
 	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
@@ -418,6 +417,7 @@ struct sock {
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
 	u16			sk_tsflags;
+	u8			sk_shutdown;
 	u32			sk_tskey;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
-- 
2.7.3
