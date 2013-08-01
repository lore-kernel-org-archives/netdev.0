From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE
Date: Thu, 1 Aug 2013 04:00:49 +0200
Message-ID: <20130801020049.GA4067@localhost>
References: <1375093804-7534-1-git-send-email-pablo@netfilter.org>
 <20130730.164423.1103943978365554977.davem@davemloft.net>
 <20130731111215.GA6062@localhost>
 <20130731.170348.1752477967026355787.davem@davemloft.net>
 <20130801003710.GA19777@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55039 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab3HACA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 22:00:56 -0400
Content-Disposition: inline
In-Reply-To: <20130801003710.GA19777@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 01, 2013 at 02:37:10AM +0200, Pablo Neira Ayuso wrote:
> On Wed, Jul 31, 2013 at 05:03:48PM -0700, David Miller wrote:
[...]
> > Therefore I don't see how NLM_F_REPLACE and NLM_F_EXCL can be used
> > at all, in those places, because the check is still "& NLM_F_DUMP"
> 
> The kind = type&3; is doing the magic there for rtnetlink. kind == 2
> means that this is a get command, and you can only set NLM_F_DUMP
> using the get command.
> 
> Since it doesn't make sense to use NLM_F_EXCL or NLM_F_REPLACE for get
> commands, there is no room for ambiguity and rtnetlink is fine.

I had re-read what I wrote to get your point. We can fix in a
different way by checking for: ops->flags & GENL_CMD_CAP_DUMP, which
means we have a .dumpit callback, so only in that case genetlink
should interpret the flags as NLM_F_DUMP.

Please, see patch attached.

--W/nzBZO5zC0uMSeA
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-genetlink-interpret-NLM_F_DUMP-if-GENL_CMD_CAP_DUMP-.patch"

>From 0536ae81c430d007a81dbdf2989b736f4f5057f1 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 1 Aug 2013 03:32:11 +0200
Subject: [PATCH] genetlink: interpret NLM_F_DUMP if GENL_CMD_CAP_DUMP flag is
 set

This patch reverts (e1ee367 genetlink: fix usage of NLM_F_EXCL
or NLM_F_REPLACE) to fix the possible ambiguity for non-get
commands in a different way. Basically, we assume that genetlink
should only interpret the NLM_F_DUMP flags if the .dumpit callback
is set, which is the common case for getoperation.

This approach is similar to what rtnetlink does to resolve this
ambiguity.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netlink/genetlink.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 512718a..d034728 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -571,7 +571,8 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	    !capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
+	if ((ops->flags & GENL_CMD_CAP_DUMP) &&
+	    nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ops->dumpit,
 			.done = ops->done,
-- 
1.7.10.4


--W/nzBZO5zC0uMSeA--
