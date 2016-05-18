From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: sock: move ->sk_shutdown out of bitfields.
Date: Wed, 18 May 2016 08:31:11 -0700
Message-ID: <1463585471.18194.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463576621.18194.96.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463582171-24083-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33308 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932634AbcERPbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 11:31:13 -0400
In-Reply-To: <1463582171-24083-1-git-send-email-aryabinin@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 17:36 +0300, Andrey Ryabinin wrote:
> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
> sock_setsockopt() may write to these bits, while holding the socket lock.
> 
> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
> to corrupting these bits.
> 
> Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
> This will not change the 'struct sock' size since ->sk_shutdown moved into
> previously unused 16-bit hole.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> Changes since v1:
>  - move sk_shutdown into a separate byte instead of locking
> 	AF_UNIX sockets.
> 
> Changes since v2:
>  - reorder bitfields, so that sk_type/sk_protocol still fit in
>     separate 2-bytes/byte.
> 	

I suggested to use an explicit padding, to clearly show that two bits
are available there. You also could add a comment to remind the rules.

Something like :

diff --git a/include/net/sock.h b/include/net/sock.h
index c9c8b19df27c558354687119db60c0716909ea3f..4e239a7ef4f67b1988fe119d81566d1465a2b596 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -382,8 +382,10 @@ struct sock {
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
 	struct sk_buff_head	sk_write_queue;
+
+	/* because of non atomicity rules, all changes are protected by socket lock */
 	kmemcheck_bitfield_begin(flags);
-	unsigned int		sk_shutdown  : 2,
+	unsigned int		sk_padding   : 2,
 				sk_no_check_tx : 1,
 				sk_no_check_rx : 1,
 				sk_userlocks : 4,
@@ -391,6 +393,7 @@ struct sock {
 				sk_type      : 16;
 #define SK_PROTOCOL_MAX U8_MAX
 	kmemcheck_bitfield_end(flags);
+
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
 	u32			sk_pacing_rate; /* bytes per second */
@@ -418,6 +421,7 @@ struct sock {
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
 	u16			sk_tsflags;
+	u8			sk_shutdown;
 	u32			sk_tskey;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
