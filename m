From: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
Date: Tue, 15 May 2012 10:14:02 +0100
Message-ID: <20120515091402.GG29102@suse.de>
References: <1336658065-24851-2-git-send-email-mgorman@suse.de>
 <20120511.011034.557833140906762226.davem@davemloft.net>
 <20120514105604.GB29102@suse.de>
 <20120514.162634.1094732813264319951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	neilb-l3A5Bk7waGM@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org,
	michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120514.162634.1094732813264319951.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 04:26:34PM -0400, David Miller wrote:
> From: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
> Date: Mon, 14 May 2012 11:56:04 +0100
> 
> > On Fri, May 11, 2012 at 01:10:34AM -0400, David Miller wrote:
> >> From: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
> >> Date: Thu, 10 May 2012 14:54:14 +0100
> >> 
> >> > It could happen that all !SOCK_MEMALLOC sockets have buffered so
> >> > much data that we're over the global rmem limit. This will prevent
> >> > SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
> >> > from running, which is needed to reduce the buffered data.
> >> > 
> >> > Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
> >> > 
> >> > Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
> >> > Signed-off-by: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
> >> 
> >> This introduces an invariant which I am not so sure is enforced.
> >> 
> >> With this change it is absolutely required that once a socket
> >> becomes SOCK_MEMALLOC it must never _ever_ lose that attribute.
> >> 
> > 
> > This is effectively true. In the NFS case, the flag is cleared on
> > swapoff after all the entries have been paged in. In the NBD case,
> > SOCK_MEMALLOC is left set until the socket is destroyed. I'll update the
> > changelog.
> 
> Bugs happen, you need to find a way to assert that nobody every does
> this.  Because if a bug is introduced which makes this happen, it will
> otherwise be very difficult to debug.

Ok, fair point. I looked at how we could ensure it could never happen but
that would require failing sk_clear_memalloc() and it's less clear how
that should be properly recovered from. Instead, it can be detected that
there are rmem tokens allocations, warn about it and fix it up albeit it
in a fairly heavy-handed fashion. How about this on top of the existing
patch?

---8<---
diff --git a/net/core/sock.c b/net/core/sock.c
index 22ff2ea..e3dea27 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -289,6 +289,18 @@ void sk_clear_memalloc(struct sock *sk)
 	sock_reset_flag(sk, SOCK_MEMALLOC);
 	sk->sk_allocation &= ~__GFP_MEMALLOC;
 	static_key_slow_dec(&memalloc_socks);
+
+	/*
+	 * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
+	 * progress of swapping. However, if SOCK_MEMALLOC is cleared while
+	 * it has rmem allocations there is a risk that the user of the
+	 * socket cannot make forward progress due to exceeding the rmem
+	 * limits. By rights, sk_clear_memalloc() should only be called
+	 * on sockets being torn down but warn and reset the accounting if
+	 * that assumption breaks.
+	 */
+	if (WARN_ON(sk->sk_forward_alloc))
+		sk_mem_reclaim(sk);
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
