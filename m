From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 16:49:54 -0400
Message-ID: <20061005204949.GF18408@tuxdriver.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: liniville@bougret.hpl.hp.com, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:45834 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751311AbWJEVA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 17:00:29 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20061005163113.GB6510@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 09:31:13AM -0700, Jean Tourrilhes wrote:

> 	Based on the feedback, I formally request you to back out all
> of WE-21 from 2.6.19. Rationale : it's probably too early. You can
> keep it for a later date if you wish.

Jean,

What about a patch like the one below?  It tries to detect WE-20
ESSID/NICKN accesses and adjust them to WE-21 style.  What am
I missing?

I haven't had a chance to test it yet -- just hacked it
up...YMMV... :-)

John

diff --git a/net/core/wireless.c b/net/core/wireless.c
index ffff0da..ba5fe77 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -748,11 +748,39 @@ #endif	/* WE_SET_EVENT */
 		int	extra_size;
 		int	user_length = 0;
 		int	err;
+		int	essid_compat = 0;
 
 		/* Calculate space needed by arguments. Always allocate
 		 * for max space. Easier, and won't last long... */
 		extra_size = descr->max_tokens * descr->token_size;
 
+		/* Check need for ESSID compatibility for WE < 21 */
+		switch (cmd) {
+		case SIOCSIWESSID:
+		case SIOCGIWESSID:
+		case SIOCSIWNICKN:
+		case SIOCGIWNICKN:
+			if (iwr->u.data.length == descr->max_tokens + 1)
+				essid_compat = 1;
+			else if (IW_IS_SET(cmd)) {
+				char essid[IW_ESSID_MAX_SIZE + 1];
+
+				err = copy_from_user(essid, iwr->u.data.pointer,
+						     iwr->u.data.length *
+						     descr->token_size);
+				if (err)
+					return -EFAULT;
+
+				if (essid[iwr->u.data.length] == '\0')
+					essid_compat = 1;
+			}
+			break;
+		default:
+			break;
+		}
+
+		iwr->u.data.length -= essid_compat;
+
 		/* Check what user space is giving us */
 		if(IW_IS_SET(cmd)) {
 			/* Check NULL pointer */
@@ -795,7 +823,8 @@ #ifdef WE_IOCTL_DEBUG
 #endif	/* WE_IOCTL_DEBUG */
 
 		/* Create the kernel buffer */
-		extra = kmalloc(extra_size, GFP_KERNEL);
+		/*    kzalloc ensures NULL-termination for essid_compat */
+		extra = kzalloc(extra_size, GFP_KERNEL);
 		if (extra == NULL) {
 			return -ENOMEM;
 		}
@@ -819,6 +848,8 @@ #endif	/* WE_IOCTL_DEBUG */
 		/* Call the handler */
 		ret = handler(dev, &info, &(iwr->u), extra);
 
+		iwr->u.data.length += essid_compat;
+
 		/* If we have something to return to the user */
 		if (!ret && IW_IS_GET(cmd)) {
 			/* Check if there is enough buffer up there */

-- 
John W. Linville
linville@tuxdriver.com
