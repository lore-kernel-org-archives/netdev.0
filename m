From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: "af_unix: conditionally use freezable blocking calls in read" is
 wrong
Date: Mon, 5 Dec 2016 03:52:41 +0000
Message-ID: <20161205035241.GJ1555@ZenIV.linux.org.uk>
References: <20161204210455.GI1555@ZenIV.linux.org.uk>
 <20161204.214214.1868750446620130834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56514 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbcLEDwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 22:52:43 -0500
Content-Disposition: inline
In-Reply-To: <20161204.214214.1868750446620130834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 04, 2016 at 09:42:14PM -0500, David Miller wrote:
> > 	I've run into that converting AF_UNIX to generic_file_splice_read();
> > I can kludge around that ("freezable unless ->msg_iter is ITER_PIPE"), but
> > that only delays trouble.
> > 
> > 	Note that the only other user of freezable_schedule_timeout() is
> > a very different story - it's a kernel thread, which *does* have a guaranteed
> > locking environment.  Making such assumptions in unix_stream_recvmsg(),
> > OTOH, is insane...
> 
> We have to otherwise Android phones drain their batteries in 10
> minutes.
> 
> I'm not going to revert this and be responsible for that.
> 
> So you have to find a way to make the freezable calls legitimate.

Oh, well...  As I said, I can kludge around that - call from
generic_file_splice_read() can be distinguished by looking at the
->msg_iter->type; it still means unpleasantness for kernel_recvmsg()
users - in effect, it can only be called with locks held if you know that
the socket is not an AF_UNIX one.

BTW, how do they deal with plain pipes?
