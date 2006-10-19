From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'we21-fix' branch of wireless-2.6.git
Date: Thu, 19 Oct 2006 17:56:53 -0400
Message-ID: <20061019215647.GA18217@tuxdriver.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com> <20061010193959.GC5728@tuxdriver.com> <20061010202803.GA17177@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:10768 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1946556AbWJSWEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 18:04:22 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061010202803.GA17177@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Here is my ugly patch to fix userland ABI compatibility for WE-21.
It tries to detect WE <= 20 by the request length or the inclusion of
'\0' in the length for the ESSID and NICKN ioctls.  If it finds that,
it temporarily adjusts the length value and puts it back before
reporting back to userland.

It is possible that there are more elegant solutions that work, but
I'm not totally convinced that they truly preserve the ABI as desired.
Please see the discussion earlier in this thread if you are interested.

I'm aware that checking for '\0' is problematic, since that technically
is a valid SSID character even at the end of the SSID.  I'm afraid
we will just have to live with that limitation.

I have the single patch on its own "clean" branch from Linus's tree of
a few days ago.  That way you can pull just this fix without concern
about picking-up the other fixes which I posted a few days ago,
in case you haven't reviewed them yet.

Obviously, this is intended for 2.6.19.

Thanks,

John
---

The following changes since commit 51018b0a3160d253283173c2f54f16746cee5852:
  Ulrich Drepper:
        make UML compile (FC6/x86-64)

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/wireless-2.6.git we21-fix

John W. Linville:
      wireless: WE-20 compatibility for ESSID and NICKN ioctls

 net/core/wireless.c |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/net/core/wireless.c b/net/core/wireless.c
index ffff0da..cb1b872 100644
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
+			else if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
+				char essid[IW_ESSID_MAX_SIZE + 1];
+
+				err = copy_from_user(essid, iwr->u.data.pointer,
+						     iwr->u.data.length *
+						     descr->token_size);
+				if (err)
+					return -EFAULT;
+
+				if (essid[iwr->u.data.length - 1] == '\0')
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
