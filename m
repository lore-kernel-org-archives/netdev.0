From: "D. Hugh Redelmeier" <hugh@mimosa.com>
Subject: RE: PATCH: netdev: add a cast NLMSG_OK to avoid a GCC warning in
 users' code
Date: Fri, 11 Sep 2015 13:11:26 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1509110845151.4754@redclaw.mimosa.com>
References: <alpine.LRH.2.02.1509080933340.4754@redclaw.mimosa.com> <20150909.123717.2263645868892698375.davem@davemloft.net> <alpine.LRH.2.02.1509091555230.4754@redclaw.mimosa.com> <063D6719AE5E284EB5DD2968C1650D6D1CB922FF@AcuExch.aculab.com>
Reply-To: "D. Hugh Redelmeier" <hugh@mimosa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-d.mimosa.com ([209.161.207.149]:45966 "EHLO gw-d.mimosa.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500AbbIKRLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 13:11:47 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB922FF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Laight <David.Laight@ACULAB.COM>

| From: D. Hugh Redelmeier

| > #define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
| > 			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
| > 			   (nlh)->nlmsg_len <= (len))

| Why not cast (nlh)->nl_msg_len instead?
| Perhaps:
| 	(typeof (len))(nlh)->nlmsg_len <= (len)
| which is almost certainly safe unless 'len' is 'signed char'.

(Nit pick: it doesn't feel safe to cast to short either.)

You would also want to adjust the first compare to
	(len) >= (typeof (len))sizeof(struct nlmsghdr)
Remember that, on 32-bit machines, with the current macro, GCC gives a
warning on the first compare if len is unsigned.

These casts together might cover up some weird typing errors, like
using char * or double.

This doesn't seem like a bad fix.  It probably doesn't break any
currently working code unless something depended on one of the
surprising conversions.

I think that this change is better than the status quo but
isn't the best place to get to.


The most common source of the value is from a call to one of the
recv(2) functions.  These functions return a ssize_t.  In particular,
the error indicator is -1.

=> The error indicator -1 is only handled correctly by NLMSG_OK if the
   first compare is a signed compare.

The right change is to force the type to be ssize_t.  This should
break no currently working code (unless it is accidentally working).
After all, no practical length would be positive in size_t and negative in
ssize_t.

Using "int" instead of ssize_t would work on all Linux machines that I
know and has the merit of matching the documentation, so that is the
code change I suggested.

| Or subtract the two values and compare against zero?

If it is an unsigned subtract, the result cannot be negative, so that
doesn't work.

If it is a signed subtract, you have just the same problems as a
signed compare, plus you can get overflow (undefined in C, but
probably not in Linux).

So this isn't a win.
