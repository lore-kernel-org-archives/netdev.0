From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 15:12:46 -0700
Message-ID: <20061005221246.GB7533@bougret.hpl.hp.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:36604 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932333AbWJEWPY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 18:15:24 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20061005204949.GF18408@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 04:49:54PM -0400, John W. Linville wrote:
> On Thu, Oct 05, 2006 at 09:31:13AM -0700, Jean Tourrilhes wrote:
> 
> > 	Based on the feedback, I formally request you to back out all
> > of WE-21 from 2.6.19. Rationale : it's probably too early. You can
> > keep it for a later date if you wish.
> 
> Jean,
> 
> What about a patch like the one below?  It tries to detect WE-20
> ESSID/NICKN accesses and adjust them to WE-21 style.  What am
> I missing?
> 
> I haven't had a chance to test it yet -- just hacked it
> up...YMMV... :-)
> 
> John

	This is a tested and simplified version of your patch. I added
an explicit "warning" message, so that users have visibility on what's
happening.
	I had a bit of fun on the testing phase, as most of my antique
cards were just discarding the extra '\0'. The Broadcom did show the
issue, and that this patch was fixing it properly.
	I let you decide the best course of action.

	Have fun...

	Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

--------------------------------------------------

diff -u -p linux/net/core/wireless.j1.c linux/net/core/wireless.c
--- linux/net/core/wireless.j1.c	2006-10-05 14:24:16.000000000 -0700
+++ linux/net/core/wireless.c	2006-10-05 14:53:23.000000000 -0700
@@ -821,6 +821,26 @@ static int ioctl_standard_call(struct ne
 			       dev->name,
 			       iwr->u.data.length * descr->token_size);
 #endif	/* WE_IOCTL_DEBUG */
+
+			/* Some users have old userspace compatible
+			 * with WE-20. Those add an extra '\0' at the
+			 * end of the ESSID. Just get rids of it.
+			 * Note : in the long term we will need to get
+			 * rid of this code to allow '\0' as a valid
+			 * last char of the ESSID.
+			 * Jean II */
+			if((cmd == SIOCSIWESSID) ||
+			   (cmd == SIOCSIWNICKN)) {
+				if(extra[iwr->u.data.length - 1] == '\0') {
+					static int printed_message;
+
+					if (!printed_message++)
+						printk(KERN_DEBUG "%s (WE) : NUL terminated ESSID detected, please update Wireless Tools !\n",
+						       dev->name);
+
+					iwr->u.data.length--;
+				}
+			}
 		}
 
 		/* Call the handler */
