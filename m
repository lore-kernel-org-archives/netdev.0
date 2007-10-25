From: Rich Paul <socketpair_bug@rich-paul.net>
Subject: BUG in sys_socketpair
Date: Thu, 25 Oct 2007 10:11:07 -0400
Message-ID: <20071025141107.GA19437@dragon.rich-paul.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rich-paul.net ([70.85.129.89]:42029 "EHLO rich-paul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761046AbXJYOSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 10:18:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 2.6.23, there seems to be a minor bug in sys_socketpair.  When the
calls to sock_alloc_fd fail, it aborts the routine, but it returns the
variable err, which is not set in this case.

The result is a silent failure if you have too many files open and call
socketpair.

Here is a simple UNTESTED patch (not even compiled) which should resolve the
issue.

Regards,
Rich

--- net/socket.c.orig   2007-10-25 10:03:56.000000000 -0400
+++ net/socket.c        2007-10-25 10:04:00.000000000 -0400
@@ -1245,11 +1245,14 @@
                goto out_release_both;

        fd1 = sock_alloc_fd(&newfile1);
-       if (unlikely(fd1 < 0))
+       if (unlikely(fd1 < 0)) {
+               err=fd1;
                goto out_release_both;
+       }

        fd2 = sock_alloc_fd(&newfile2);
        if (unlikely(fd2 < 0)) {
+               err=fd2;
                put_filp(newfile1);
                put_unused_fd(fd1);
                goto out_release_both;

