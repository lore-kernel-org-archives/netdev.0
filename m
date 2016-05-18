From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v4] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 19:19:27 +0300
Message-ID: <1463588367-16310-1-git-send-email-aryabinin@virtuozzo.com>
References: <1463585471.18194.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463585471.18194.123.camel@edumazet-glaptop3.roam.corp.google.com>
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

Changes since v3:
  - padding and comment per Eric.

 include/net/sock.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c9c8b19..649d2a8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -382,8 +382,13 @@ struct sock {
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
 	struct sk_buff_head	sk_write_queue;
+
+	/*
+	 * Because of non atomicity rules, all
+	 * changes are protected by socket lock.
+	 */
 	kmemcheck_bitfield_begin(flags);
-	unsigned int		sk_shutdown  : 2,
+	unsigned int		sk_padding : 2,
 				sk_no_check_tx : 1,
 				sk_no_check_rx : 1,
 				sk_userlocks : 4,
@@ -391,6 +396,7 @@ struct sock {
 				sk_type      : 16;
 #define SK_PROTOCOL_MAX U8_MAX
 	kmemcheck_bitfield_end(flags);
+
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
 	u32			sk_pacing_rate; /* bytes per second */
@@ -418,6 +424,7 @@ struct sock {
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
 	u16			sk_tsflags;
+	u8			sk_shutdown;
 	u32			sk_tskey;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
-- 
2.7.3
