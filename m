From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: iproute2 (addr flush) infinite loop when unprivileged users
Date: Fri, 25 Jan 2008 16:12:59 -0800
Message-ID: <20080125161259.0356c990@deepthought>
References: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Alon Bar-Lev" <alon.barlev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47919 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751699AbYAZANZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 19:13:25 -0500
In-Reply-To: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Jan 2008 01:00:34 +0200
"Alon Bar-Lev" <alon.barlev@gmail.com> wrote:

> Hello,
> 
> When executing the following command using unprivileged users there is
> an infinite loop...
> /sbin/ip route flush dev eth1
> 
> Execution with -s produces:
> *** Round 28153, deleting 2 entries ***
> 
> *** Round 28154, deleting 2 entries ***
> 
> *** Round 28155, deleting 2 entries ***
> 
> *** Round 28156, deleting 2 entries ***
> 
> *** Round 28157, deleting 2 entries ***
> 
> *** Round 28158, deleting 2 entries ***
> 
> *** Round 28159, deleting 2 entries ***
> 
> I do not fully understand the sequence, but it may be kernel fault, as
> it should have returned EPERM for this request stopping the netlink
> request.
> 
> Anyway... A simple solution is to store the filter.flushed and fail if
> it keeps its value during loop iteration at
> ip/ipaddress.c::ipaddr_list_or_flush(), but this is only a
> workaround...
> 
> Please CC as I am not in netdev list.
> Thanks!
> Alon.

The issue is that iproute is just blindly sending the deletes and
not asking for acknowledgment status. Here is a trivial patch to iproute
to fix that, but the problem is that it means it will slow down bulk removal.

Maybe it should just check the first, or last delete to see if there are
errors?

diff --git a/ip/iproute.c b/ip/iproute.c
index 7a885b0..b2ae879 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -112,11 +112,27 @@ static struct
 
 static int flush_update(void)
 {
+	unsigned long i;
+	struct nlmsghdr *fn;
+
+#ifdef nochecking
 	if (rtnl_send(&rth, filter.flushb, filter.flushp) < 0) {
 		perror("Failed to send flush request\n");
 		return -1;
 	}
+#else
+	for (i = 0; i < filter.flushp; ) {
+		fn = (struct nlmsghdr *)(filter.flushb + NLMSG_ALIGN(i));
+		fn->nlmsg_flags |= NLM_F_ACK;
+		
+		if (rtnl_talk(&rth, fn, 0, 0, NULL, NULL, NULL) < 0)
+			return -1;
+
+		i = (((char*)fn) + fn->nlmsg_len) - filter.flushb;
+	}
+#endif
 	filter.flushp = 0;
+
 	return 0;
 }
 




-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
