From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: "af_unix: conditionally use freezable blocking calls in read" is
 wrong
Date: Sun, 4 Dec 2016 21:04:55 +0000
Message-ID: <20161204210455.GI1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50652 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbcLDVE6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 16:04:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Could we please kill that kludge?  "af_unix: use freezable blocking
calls in read" had been wrong to start with; having a method make assumptions
of that sort ("nobody will call me while holding locks I hadn't thought of")
is asking for serious trouble.  splice is just a place where lockdep has
caught that - we *can't* assume that nobody will ever call kernel_recvmsg()
while holding some locks.

	I've run into that converting AF_UNIX to generic_file_splice_read();
I can kludge around that ("freezable unless ->msg_iter is ITER_PIPE"), but
that only delays trouble.

	Note that the only other user of freezable_schedule_timeout() is
a very different story - it's a kernel thread, which *does* have a guaranteed
locking environment.  Making such assumptions in unix_stream_recvmsg(),
OTOH, is insane...
