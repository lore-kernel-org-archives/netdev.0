From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 11:26:38 +0200
Message-ID: <487F104E.6070003@trash.net>
References: <20080716220058.GA31425@amd64.fatal.se>	 <20080716150320.63f20215@extreme>	 <1216247237.31646.12.camel@amd64.fatal.se>	 <20080716152631.04125f56@extreme> <1216247722.3422.38.camel@johannes.berg>	 <20080716155354.28281053@extreme> <1216254660.31646.54.camel@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090106080602090503020204"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	stephen.hemminger@vyatta.com, 489340@bugs.debian.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50208 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbYGQJ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 05:26:43 -0400
In-Reply-To: <1216254660.31646.54.camel@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090106080602090503020204
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Andreas Henriksson wrote:
> On ons, 2008-07-16 at 15:53 -0700, Stephen Hemminger wrote:
>> The netlink message in question is marked as type ERROR but the errno
>> encoded in the message is zero.
>>
>> 		if (h->nlmsg_type == NLMSG_ERROR) {
>> 			struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
>> 			if (l < sizeof(struct nlmsgerr)) {
>> 				fprintf(stderr, "ERROR truncated\n");
>> 			} else {
>> 				errno = -err->error;
>> 				if (errno == 0) {
>> 					if (answer)
>> 						memcpy(answer, h, h->nlmsg_len);
>> 					return 0;
>> 				}
>> 				perror("RTNETLINK answers");
>> 			}
>>
>> So the netlink library just treats as a successful return.
> Why? This seems like a really bad idea to me, and none of the callers in
> iproute benefits from this as far as I can see.
> 
> Just ripping out the errno == 0 special casing looks like and option to
> me, unless anyone can find a reason for it.

NLMSG_ERROR with errno == 0 is a netlink ACK message.

> (It'll give an error message and an error exit code! The message will be
> strange, but lets blame the kernel for that cosmetic issue. Atleast the
> user got some kind of notification.)
> 
> Moving the "return 0;" inside the "if (answer)" would be another
> (atleast for iproutes callers of the library functions)...
> 
>> To me it looks like the problem is in the kernel sending back
>> a NLMSG_ERROR with errno of zero. Some code path isn't setting
>> it up properly.
> 
> None the less, it would be be good if the application wouldn't poop it's
> pants when it can be avoided - broken kernel or not.

The fix in this case is to propagate the return value from
dev_change_flags().



--------------090106080602090503020204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

rtnetlink: propagate error from dev_change_flags in do_setlink()

Andreas Henriksson <andreas@fatal.se> reported that unlike ifconfig,
iproute doesn't report an error when setting an interface up fails.

Propagate the return value from dev_change_flags() to fix this.

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a9a7721..ffde766 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -867,7 +867,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		if (ifm->ifi_change)
 			flags = (flags & ifm->ifi_change) |
 				(dev->flags & ~ifm->ifi_change);
-		dev_change_flags(dev, flags);
+		err = dev_change_flags(dev, flags);
+		if (err < 0)
+			goto errout;
 	}
 
 	if (tb[IFLA_TXQLEN])

--------------090106080602090503020204--
