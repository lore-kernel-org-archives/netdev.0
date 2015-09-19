From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Subject: Re: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in
 users' code
Date: Sat, 19 Sep 2015 17:43:29 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1509191646070.1669@redclaw.mimosa.com>
References: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com> <20150909.123717.2263645868892698375.davem@davemloft.net>
Reply-To: "D. Hugh Redelmeier" <hugh@mimosa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-d.mimosa.com ([209.161.207.149]:51208 "EHLO gw-d.mimosa.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbbISVnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Sep 2015 17:43:31 -0400
In-Reply-To: <20150909.123717.2263645868892698375.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes have been proposed for this problem at least twice before.

================

(These messages are not presented as a thread so I've put links to
each of them)

Problem report: <https://lkml.org/lkml/2013/12/15/59>
Patch proposal: <https://lkml.org/lkml/2013/12/15/60>
Reply suggesting improved presentation:  <https://lkml.org/lkml/2013/12/15/62>
Revised patch proposal: <https://lkml.org/lkml/2013/12/15/96>
Duplicate revised patch proposal: <https://lkml.org/lkml/2013/12/15/97>

Doron Tsur proposed:
-			   (nlh)->nlmsg_len <= (len))
+			   (int)(nlh)->nlmsg_len <= (len))

This would correctly function as long as nlmsg_length were <= INT_MAX.
I imagine that this would always be the case since Linux isn't used on
machines with ints narrower than 32 bits.

It would cause a GCC warning on 32-bit machines when len has an
unsigned type that is the same width as int.

Programs conforming the the netlink documentation would not get
warnings.

There was no reply to the revised patch proposal.

================

<https://lkml.org/lkml/2015/3/5/38>
Mike Frysinger proposed:
-#define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
+#define NLMSG_OK(nlh,len) ((len) >= sizeof(struct nlmsghdr) && \

This should correctly function as long as len is an unsigned type or
it has a non-negative value.  It won't work correctly if len is size_t
and has the value -1 (the error indicator).

David Miller replied:

	I don't think we can change this.  If you get rid of the 'int'
	cast then code is going to end up with a signed comparison for
	the first test even if 'len' is signed, and that's a potential
	security issue.

I don't understand this response.  If you get rid of the int cast, and
the type of len, after the "integral promotions", is the same width as
size_t, the "usual arithmetic conversions" of the C language will
cause the comparison to be done in unsigned.

I would agree with a variant of the reply:

	I don't think we can change this.  If you get rid of the 'int'
	cast then IN MOST ENVIRONMENTS the code is going to end up
	with an UNSIGNED comparison for the first test even if 'len'
	is signed, and that's a potential security issue.

	Consider the case where len is a signed type with a negative
	value, such as -1, the error indicator described in recv(2).

The example code in netlink(7) about reading netlink message is a good
example of code that would misbehave if the cast were removed.
