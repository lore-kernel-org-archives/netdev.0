From: David Miller <davem@davemloft.net>
Subject: Re: "af_unix: conditionally use freezable blocking calls in read"
 is wrong
Date: Sun, 04 Dec 2016 21:42:14 -0500 (EST)
Message-ID: <20161204.214214.1868750446620130834.davem@davemloft.net>
References: <20161204210455.GI1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbcLECti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 21:49:38 -0500
In-Reply-To: <20161204210455.GI1555@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 4 Dec 2016 21:04:55 +0000

> 	Could we please kill that kludge?  "af_unix: use freezable blocking
> calls in read" had been wrong to start with; having a method make assumptions
> of that sort ("nobody will call me while holding locks I hadn't thought of")
> is asking for serious trouble.  splice is just a place where lockdep has
> caught that - we *can't* assume that nobody will ever call kernel_recvmsg()
> while holding some locks.
> 
> 	I've run into that converting AF_UNIX to generic_file_splice_read();
> I can kludge around that ("freezable unless ->msg_iter is ITER_PIPE"), but
> that only delays trouble.
> 
> 	Note that the only other user of freezable_schedule_timeout() is
> a very different story - it's a kernel thread, which *does* have a guaranteed
> locking environment.  Making such assumptions in unix_stream_recvmsg(),
> OTOH, is insane...

We have to otherwise Android phones drain their batteries in 10
minutes.

I'm not going to revert this and be responsible for that.

So you have to find a way to make the freezable calls legitimate.
