From: David Miller <davem@davemloft.net>
Subject: Re: XFRM structures binary compability
Date: Wed, 14 Jan 2009 14:55:52 -0800 (PST)
Message-ID: <20090114.145552.71463842.davem@davemloft.net>
References: <200901091331.18342@centrum.cz>
	<200901121454.21748@centrum.cz>
	<496B56B7.3080703@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klimes@centrum.cz, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755935AbZANWzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 17:55:50 -0500
In-Reply-To: <496B56B7.3080703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 12 Jan 2009 15:41:59 +0100

> klimes@centrum.cz wrote:
> > What causes my trouble is "xfrm_usersa_info" which is padded with 7 bytes at the end in 64-bit,
> > so that the whole structure is 224 bytes in 64bit application against 220 bytes in 32bit (just 3-byte padding).
> > An explicit 7-byte padding in the structure would cure the case, IMHO.
> 
> That would break on 32 bit because userspace binaries compiled
> with the old layout would send "short" messages. I'd suggest
> to explicitly use the smaller value for the xfrm_msg_min checks
> (i.e. replace sizeof by numerical constant).

I'll commit the following and queue it up for -stable.

Thanks.

xfrm: For 32/64 compatability wrt. xfrm_usersa_info

Reported by Jiri Klimes.

Fix suggested by Patrick McHardy.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_user.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b95a2d6..7877e79 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1914,10 +1914,17 @@ static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 }
 #endif
 
+/* For the xfrm_usersa_info cases we have to work around some 32-bit vs.
+ * 64-bit compatability issues.  On 32-bit the structure is 220 bytes, but
+ * for 64-bit it gets padded out to 224 bytes.  Those bytes are just
+ * padding and don't have any content we care about.  Therefore as long
+ * as we have enough bytes for the content we can make both cases work.
+ */
+
 #define XMSGSIZE(type) sizeof(struct type)
 
 static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
-	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_info),
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = 220, /* see above */
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_id),
 	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_id),
 	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_info),
@@ -1927,7 +1934,7 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_acquire),
 	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_expire),
 	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_info),
-	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_info),
+	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = 220, /* see above */
 	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_polexpire),
 	[XFRM_MSG_FLUSHSA     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_flush),
 	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = 0,
-- 
1.6.1.15.g159c88

