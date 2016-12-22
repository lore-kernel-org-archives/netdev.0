From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH net 1/1] tipc: revert use of
	copy_from_iter_full()
Date: Thu, 22 Dec 2016 02:47:09 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D225E8E2B@eusaamb103.ericsson.se>
References: <1482368497-7103-1-git-send-email-jon.maloy@ericsson.com>
	<20161222012101.GF1555@ZenIV.linux.org.uk>
	<20161222014321.GA2805@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20161222014321.GA2805@ZenIV.linux.org.uk>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Al Viro [mailto:viro@ftp.linux.org.uk] On Behalf Of Al Viro
> Sent: Wednesday, 21 December, 2016 20:43
> To: Jon Maloy <jon.maloy@ericsson.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Parthasarathy Bhuvaragan
> <parthasarathy.bhuvaragan@ericsson.com>; Ying Xue
> <ying.xue@windriver.com>; maloy@donjonn.com; tipc-
> discussion@lists.sourceforge.net
> Subject: Re: [PATCH net 1/1] tipc: revert use of copy_from_iter_full()
> 
> On Thu, Dec 22, 2016 at 01:21:01AM +0000, Al Viro wrote:
> > On Wed, Dec 21, 2016 at 08:01:37PM -0500, Jon Maloy wrote:
> > > commit cbbd26b8b1a6 ("[iov_iter] new primitives - copy_from_iter_full()
> > > and friends") replaced calls to copy_from_iter() in the function
> > > tipc_msg_build(). This causes a an immediate crash as follows:
> >
> > Very interesting.
> >
> > > [ 1209.597076] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000008
> > > [ 1209.607025] IP: copy_from_iter_full+0x43/0x290
> >
> > > [ 1209.689257]  tipc_msg_build+0xe1/0x590 [tipc]
> > > [ 1209.691479]  ? _raw_spin_unlock_bh+0x1e/0x20
> > > [ 1209.694641]  ? tipc_node_find+0x30/0xa0 [tipc]
> > > [ 1209.696789]  __tipc_sendmsg+0x189/0x480 [tipc]
> > > [ 1209.699017]  ? remove_wait_queue+0x4d/0x60
> > > [ 1209.700354]  tipc_connect+0x15f/0x1b0 [tipc]
> > > [ 1209.701684]  SYSC_connect+0xd9/0x110
> >
> > I don't believe that it's something tipc-specific; could you post an objdump
> > of copy_from_iter_full() in your kernel?  That smells like a bug in there
> > and it really ought to be fixed...
> 
> FWIW, looking at the tipc, am I reading the trace correctly?  We seem to
> have tipc_connect() taking an msghdr with empty payload and hitting this
>         switch (sk->sk_state) {
>         case TIPC_OPEN:
>                 /* Send a 'SYN-' to destination */
>                 m.msg_name = dest;
>                 m.msg_namelen = destlen;
> 
>                 /* If connect is in non-blocking case, set MSG_DONTWAIT to
>                  * indicate send_msg() is never blocked.
>                  */
>                 if (!timeout)
>                         m.msg_flags = MSG_DONTWAIT;
> 
>                 res = __tipc_sendmsg(sock, &m, 0);
> which eventually calls
>         rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &pktchain);
> possibly more than once, but with explicit "restore m->msg_iter to what
> it was before the first call" before each subsequent call.
> 
> What's putting anything into m.msg_iter on that codepath?  AFAICS, it should
> be completely empty...  Wait.  AAARRRGH!
> 
> OK, I see what's going on there - unlike iterate_and_advance(), which
> explicitly skips any work in case of empty iterator, iterate_all_kind()
> does not.  Could you check if the following fixes your problem?

Confirmed. The crash disappeared and everything works fine.

BR
///jon

> 
> diff --git a/lib/iov_iter.c b/lib/iov_iter.c
> index 228892dabba6..6a0396b8d47f 100644
> --- a/lib/iov_iter.c
> +++ b/lib/iov_iter.c
> @@ -73,19 +73,21 @@
>  }
> 
>  #define iterate_all_kinds(i, n, v, I, B, K) {			\
> -	size_t skip = i->iov_offset;				\
> -	if (unlikely(i->type & ITER_BVEC)) {			\
> -		struct bio_vec v;				\
> -		struct bvec_iter __bi;				\
> -		iterate_bvec(i, n, v, __bi, skip, (B))		\
> -	} else if (unlikely(i->type & ITER_KVEC)) {		\
> -		const struct kvec *kvec;			\
> -		struct kvec v;					\
> -		iterate_kvec(i, n, v, kvec, skip, (K))		\
> -	} else {						\
> -		const struct iovec *iov;			\
> -		struct iovec v;					\
> -		iterate_iovec(i, n, v, iov, skip, (I))		\
> +	if (i->count) {						\
> +		size_t skip = i->iov_offset;			\
> +		if (unlikely(i->type & ITER_BVEC)) {		\
> +			struct bio_vec v;			\
> +			struct bvec_iter __bi;			\
> +			iterate_bvec(i, n, v, __bi, skip, (B))	\
> +		} else if (unlikely(i->type & ITER_KVEC)) {	\
> +			const struct kvec *kvec;		\
> +			struct kvec v;				\
> +			iterate_kvec(i, n, v, kvec, skip, (K))	\
> +		} else {					\
> +			const struct iovec *iov;		\
> +			struct iovec v;				\
> +			iterate_iovec(i, n, v, iov, skip, (I))	\
> +		}						\
>  	}							\
>  }
> 

------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today.http://sdm.link/intel
