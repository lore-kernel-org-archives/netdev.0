From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net] net: Fix the rollback test in dev_change_name()
Date: Mon, 16 Nov 2009 09:30:24 +0000
Message-ID: <20091116093024.GA13115@ff.dom.local>
References: <4AEAAFC4.9050309@gmail.com> <4AEB7BB1.9000901@gmail.com> <20091102.000549.114598716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:43970 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbZKPJa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 04:30:26 -0500
Received: by bwz27 with SMTP id 27so5403580bwz.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 01:30:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091102.000549.114598716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 12:05:49AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 31 Oct 2009 00:50:09 +0100
> 
> > I don't think so: err stores the previous ret meaning rollback and
> > is checked for this later. But somebody forgot err can store previous
> > (positive) value here, so IMHO you're right: there is a bug in this
> > place ;-)
> 
> Just not the one Eric is specifically fixing :-)

Since this bug looks quite serious (consider -stable), here is a
proposal in case we forget what is Eric specifically fixing. ;-)

Thanks,
Jarek P.

---------------->
From: Eric Dumazet <eric.dumazet@gmail.com>

net: Fix the rollback test in dev_change_name()

In dev_change_name() an err variable is used for storing the original
call_netdevice_notifiers() errno (negative) and testing for a rollback
error later, but the test for non-zero is wrong, because the err might
have positive value as well - from dev_alloc_name(). It means the
rollback for a netdevice with a number > 0 will never happen. (The err
test is reordered btw. to make it more readable.)

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---

 net/core/dev.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..fe10551 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -942,14 +942,15 @@ rollback:
 	ret = notifier_to_errno(ret);
 
 	if (ret) {
-		if (err) {
-			printk(KERN_ERR
-			       "%s: name change rollback failed: %d.\n",
-			       dev->name, ret);
-		} else {
+		/* err >= 0 after dev_alloc_name() or stores the first errno */
+		if (err >= 0) {
 			err = ret;
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			goto rollback;
+		} else {
+			printk(KERN_ERR
+			       "%s: name change rollback failed: %d.\n",
+			       dev->name, ret);
 		}
 	}
 
