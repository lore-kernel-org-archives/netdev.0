From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: NFS TCP race condition with SOCK_ASYNC_NOSPACE
Date: Fri, 18 Nov 2011 20:52:48 +0200
Message-ID: <1321642368.2653.35.camel@lade.trondhjem.org>
References: <4EC6A681.30902@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Cooper <andrew.cooper3-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EC6A681.30902-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-11-18 at 18:40 +0000, Andrew Cooper wrote: 
> Hello,
> 
> As described originally in
> http://www.spinics.net/lists/linux-nfs/msg25314.html, we were
> encountering a bug whereby the NFS session was unexpectedly timing out.
> 
> I believe I have found the source of the race condition causing the timeout.
> 
> Brief overview of setup:
>   10GiB network, NFS mounted using TCP.  Problem reproduces with
> multiple different NICs, with synchronous or asynchronous mounts, and
> with soft and hard mounts.  Reproduces on 2.6.32 and I am currently
> trying to reproduce with mainline. (I don't have physical access to the
> servers so installing stuff is not fantastically easy)
> 
> 
> 
> In net/sunrpc/xprtsock.c:xs_tcp_send_request(), we try to write data to
> the sock buffer using xs_sendpages()
> 
> When the sock buffer is nearly fully, we get an EAGAIN from
> xs_sendpages() which causes a break out of the loop.  Lower down the
> function, we switch on status which cases us to call xs_nospace() with
> the task.
> 
> In xs_nospace(), we test the SOCK_ASYNC_NOSPACE bit from the socket, and
> in the rare case where that bit is clear, we return 0 instead of
> EAGAIN.  This promptly overwrites status in xs_tcp_send_request().
> 
> The result is that xs_tcp_release_xprt() finds a request which has no
> error, but has not sent all of the bytes in its send buffer.  It cleans
> up by setting XPRT_CLOSE_WAIT which causes xprt_clear_locked() to queue
> xprt->task_cleanup, which closes the TCP connection.
> 
> 
> Under normal operation, the TCP connection goes down and back up without
> interruption to the NFS layer.  However, when the NFS server hangs in a
> half closed state, the client forces a RST of the TCP connection,
> leading to the timeout.
> 
> I have tried a few naive fixes such as changing the default return value
> in xs_nospace() from 0 to -EAGAIN (meaning that 0 will never be
> returned) but this causes a kernel memory leak.  Can someone who a
> better understanding of these interactions than me have a look?  It
> seems that the if (test_bit()) test in xs_nospace() should have an else
> clause.

I fully agree with your analysis. The correct thing to do here is to
always return either EAGAIN or ENOTCONN. Thank you very much for working
this one out!

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
