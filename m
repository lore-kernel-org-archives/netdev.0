From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 02:31:00 +0200
Message-ID: <1216254660.31646.54.camel@amd64.fatal.se>
References: <20080716220058.GA31425@amd64.fatal.se>
	 <20080716150320.63f20215@extreme>
	 <1216247237.31646.12.camel@amd64.fatal.se>
	 <20080716152631.04125f56@extreme> <1216247722.3422.38.camel@johannes.berg>
	 <20080716155354.28281053@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	stephen.hemminger@vyatta.com, 489340@bugs.debian.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:35801 "EHLO
	amd64.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754776AbYGQA1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 20:27:25 -0400
In-Reply-To: <20080716155354.28281053@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ons, 2008-07-16 at 15:53 -0700, Stephen Hemminger wrote:
> The netlink message in question is marked as type ERROR but the errno
> encoded in the message is zero.
> 
> 		if (h->nlmsg_type == NLMSG_ERROR) {
> 			struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
> 			if (l < sizeof(struct nlmsgerr)) {
> 				fprintf(stderr, "ERROR truncated\n");
> 			} else {
> 				errno = -err->error;
> 				if (errno == 0) {
> 					if (answer)
> 						memcpy(answer, h, h->nlmsg_len);
> 					return 0;
> 				}
> 				perror("RTNETLINK answers");
> 			}
> 
> So the netlink library just treats as a successful return.
Why? This seems like a really bad idea to me, and none of the callers in
iproute benefits from this as far as I can see.

Just ripping out the errno == 0 special casing looks like and option to
me, unless anyone can find a reason for it.
(It'll give an error message and an error exit code! The message will be
strange, but lets blame the kernel for that cosmetic issue. Atleast the
user got some kind of notification.)

Moving the "return 0;" inside the "if (answer)" would be another
(atleast for iproutes callers of the library functions)...

> To me it looks like the problem is in the kernel sending back
> a NLMSG_ERROR with errno of zero. Some code path isn't setting
> it up properly.

None the less, it would be be good if the application wouldn't poop it's
pants when it can be avoided - broken kernel or not.


diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 5ae64f7..4413165 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -348,12 +348,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 					fprintf(stderr, "ERROR truncated\n");
 				} else {
 					errno = -err->error;
-					if (errno == 0) {
-						if (answer)
-							memcpy(answer, h, h->nlmsg_len);
-						return 0;
-					}
-					perror("RTNETLINK answers");
+					perror("RTNETLINK error");
 				}
 				return -1;
 			}


-- 
Regards,
Andreas Henriksson
