From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Subject: Re: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in
 users' code
Date: Fri, 11 Sep 2015 02:34:00 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1509110227150.4754@redclaw.mimosa.com>
References: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com> <20150909.123717.2263645868892698375.davem@davemloft.net> <alpine.LRH.2.02.1509091555230.4754@redclaw.mimosa.com> <20150909.140215.1213898124238701461.davem@davemloft.net>
Reply-To: "D. Hugh Redelmeier" <hugh@mimosa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-d.mimosa.com ([209.161.207.149]:45577 "EHLO gw-d.mimosa.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbbIKGeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 02:34:05 -0400
In-Reply-To: <20150909.140215.1213898124238701461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>

| From: "D. Hugh Redelmeier" <hugh@mimosa.com>
| Date: Wed, 9 Sep 2015 16:24:07 -0400 (EDT)

| > 1) netlink(3) says that the type of the second parameter is "int".
| >    From the synopsis:
| >        int NLMSG_OK(struct nlmsghdr *nlh, int len);
| >    Surely then "int" should be appropriate.
| 
| Documentation can, and often is, wrong.  The code that has been there
| for more than two decades determines what the interface and semantics
| actually are.
| 
| Whatever is actually in the macro is what people have to accomodate
| and cope with.

That's pretty scary.  Especially since I've found that more than half
the files in Fedora that used the macor used a signed type.

Thanks for responding to the start of my message.  Here's the rest
again in case you missed it.

2) if you use the type "unsigned int" on a 32-bit machine, you get the 
   warning for an earlier conjunct:

#define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
			   (nlh)->nlmsg_len <= (len))

   (len) >= (int)sizeof(struct nlmsghdr)  <=== unsigned >= int

3) on a 32-bit machine, size_t is likely "unsigned int" so the
   same problem as (2) should arise.

4) on a 64-bit machine with 64-bit ints, the same problems are likely.
   I don't have one to test on.

Casting to "short" or "unsigned short" works, but I don't know that
the value is guaranteed to fit in either of them.

| I'm not applying this, sorry.

Thanks for looking at this.  Could you reconsider?

An alternative would be to change netlink(3) to say that len is
of type ssize_t or size_t (there are arguments for each).  This would
be cleaner, but it would be an API change (at least in theory).  The
macro would still have to be changed, just in a different way.
