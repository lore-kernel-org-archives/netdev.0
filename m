From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Request to postpone WE-21
Date: Tue, 10 Oct 2006 15:40:04 -0400
Message-ID: <20061010193959.GC5728@tuxdriver.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:58898 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030235AbWJJTrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 15:47:09 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20061005221246.GB7533@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 03:12:46PM -0700, Jean Tourrilhes wrote:
> On Thu, Oct 05, 2006 at 04:49:54PM -0400, John W. Linville wrote:
> > On Thu, Oct 05, 2006 at 09:31:13AM -0700, Jean Tourrilhes wrote:
> > 
> > > 	Based on the feedback, I formally request you to back out all
> > > of WE-21 from 2.6.19. Rationale : it's probably too early. You can
> > > keep it for a later date if you wish.
> > 
> > Jean,
> > 
> > What about a patch like the one below?  It tries to detect WE-20
> > ESSID/NICKN accesses and adjust them to WE-21 style.  What am
> > I missing?
> > 
> > I haven't had a chance to test it yet -- just hacked it
> > up...YMMV... :-)
> > 
> > John
> 
> 	This is a tested and simplified version of your patch. I added
> an explicit "warning" message, so that users have visibility on what's
> happening.
> 	I had a bit of fun on the testing phase, as most of my antique
> cards were just discarding the extra '\0'. The Broadcom did show the
> issue, and that this patch was fixing it properly.
> 	I let you decide the best course of action.

I think this patch still has two problems.  One is that the length
modification does not happen until after the "Check what user space
is giving us" clause.  So, max length requests will fail.  (Did you
check SIOCGIWESSID w/ WE-20 tools?  Or am I missing something?
SIOCGIWESSID and SIOCGIWNICN do not have IW_DESCR_FLAG_NOMAX set.)

Since I think we have to account for the gets as well as the sets,
then we have to restore the length value in the ifreq to be compatible
with userland, just in case they reuse the data structure.

I think the main issues with my patch were an off-by-one in the length
for checking for \0, and a failure to account for a length of zero.
I have attempted to correct those in my patch below.  What do you
think?

John

P.S.  Again, this is an untested patch...

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
