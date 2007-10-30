From: David Miller <davem@davemloft.net>
Subject: Re: BUG in sys_socketpair
Date: Mon, 29 Oct 2007 21:55:00 -0700 (PDT)
Message-ID: <20071029.215500.114909860.davem@davemloft.net>
References: <20071025141107.GA19437@dragon.rich-paul.net>
	<4720E424.7060509@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketpair_bug@rich-paul.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752685AbXJ3EzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 00:55:06 -0400
In-Reply-To: <4720E424.7060509@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Thu, 25 Oct 2007 14:44:52 -0400

> On 10/25/2007 10:11 AM, Rich Paul wrote:
> > In 2.6.23, there seems to be a minor bug in sys_socketpair.  When the
> > calls to sock_alloc_fd fail, it aborts the routine, but it returns the
> > variable err, which is not set in this case.
> > 
> > The result is a silent failure if you have too many files open and call
> > socketpair.
> > 
> > Here is a simple UNTESTED patch (not even compiled) which should resolve the
> > issue.
> > 
> > 
> > --- net/socket.c.orig   2007-10-25 10:03:56.000000000 -0400
> > +++ net/socket.c        2007-10-25 10:04:00.000000000 -0400
> Should be "err = fd1" (spaces), otherwise looks good.
> 
> Original did:
> 
> 	err = sock_map_fd(sock1);
> 	if (err < 0)
> 		goto out_release_both;
> 	fd1 = err;

Thanks everyone, I'll commit the following both to 2.6.x GIT
and -stable.

>From 42f3fc7e989554e9952bdf28af137e4e4570f067 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Mon, 29 Oct 2007 21:54:02 -0700
Subject: [PATCH] [NET]: Fix error reporting in sys_socketpair().

If either of the two sock_alloc_fd() calls fail, we
forget to update 'err' and thus we'll erroneously
return zero in these cases.

Based upon a report and patch from Rich Paul, and
commentary from Chuck Ebbert.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/socket.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 540013e..5d879fd 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1250,11 +1250,14 @@ asmlinkage long sys_socketpair(int family, int type, int protocol,
 		goto out_release_both;
 
 	fd1 = sock_alloc_fd(&newfile1);
-	if (unlikely(fd1 < 0))
+	if (unlikely(fd1 < 0)) {
+		err = fd1;
 		goto out_release_both;
+	}
 
 	fd2 = sock_alloc_fd(&newfile2);
 	if (unlikely(fd2 < 0)) {
+		err = fd2;
 		put_filp(newfile1);
 		put_unused_fd(fd1);
 		goto out_release_both;
-- 
1.5.2.5

