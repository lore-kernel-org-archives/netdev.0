From: Patrick McHardy <kaber@trash.net>
Subject: Re: 16/32 bit issues at nfulnl_recv_config
Date: Fri, 19 May 2006 03:15:58 +0200
Message-ID: <446D1C4E.6050601@trash.net>
References: <20060518232050.GA31257@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060503010800080506060205"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60126 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932168AbWESBQA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 21:16:00 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060518232050.GA31257@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060503010800080506060205
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Alexey Dobriyan wrote:
> I'm talking about net/netfilter/nfnetlink_log.c::^nfulnl_recv_config
> below. I'm totally confused and beer supply almost ended, so can someone else
> also look at it...
> 
> Put your attention at line 905:
> 
> net/netfilter/nfnetlink_log.c:
> 
>    902		if (nfula[NFULA_CFG_FLAGS-1]) {
>    903			u_int16_t flags =
>    904				*(u_int16_t *)NFA_DATA(nfula[NFULA_CFG_FLAGS-1]);
>    905			nfulnl_set_flags(inst, ntohl(flags));
> 
> 
> 1) Cast should be made to __be16, and history of fixing endian warning
>    slightly above supports it.
> 2) Assuming __be16, ntohl(__be16) is whooops.
> 3) nfulnl_set_flags() wants something 16-bit wide as a second argument,
>    so ntohling there is double whoops.
> 4) NFULNL_CFG_F_SEQ* defines fit into 16 bit and are host-endian;
>    inst->flags is &'ed with host endian so it's probably host-endian and
> 
>    static int
>    nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
>    						  ^^^^^^^^^
> 						  this should be made __be16.
>    {
> 	spin_lock_bh(&inst->lock);
> 	inst->flags = ntohs(flags);
> 	spin_unlock_bh(&inst->lock);
> 	return 0;
>    }
> 
>    What to do with lines 903-905 if it is.


I checked the userspace code, "flags" is indeed a u16 in network byte
order, so the ntohl in line 905 needs to become ntohs and the other
one can just go, as done by this patch.

--------------060503010800080506060205
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: nfnetlink_log: fix byteorder confusion

flags is a u16, so use htons instead of htonl. Also avoid double
conversion.

Noticed by Alexey Dobriyan <adobriyan@gmail.com>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ad1dcdc1f150f613ff8625fed88ed5c1d089d09a
tree fa34bb52998bd56144639dfe6b2c286b114ae59a
parent f372e5df6ab4cd1e1498489562af2095fb5aec7c
author Patrick McHardy <kaber@trash.net> Fri, 19 May 2006 03:12:08 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 19 May 2006 03:12:08 +0200

 net/netfilter/nfnetlink_log.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index c60273c..61cdda4 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -321,7 +321,7 @@ static int
 nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
 {
 	spin_lock_bh(&inst->lock);
-	inst->flags = ntohs(flags);
+	inst->flags = flags;
 	spin_unlock_bh(&inst->lock);
 
 	return 0;
@@ -902,7 +902,7 @@ nfulnl_recv_config(struct sock *ctnl, st
 	if (nfula[NFULA_CFG_FLAGS-1]) {
 		u_int16_t flags =
 			*(u_int16_t *)NFA_DATA(nfula[NFULA_CFG_FLAGS-1]);
-		nfulnl_set_flags(inst, ntohl(flags));
+		nfulnl_set_flags(inst, ntohs(flags));
 	}
 
 out_put:

--------------060503010800080506060205--
