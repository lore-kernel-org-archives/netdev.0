From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Set truesize in pskb_expand_head
Date: Sat, 25 Sep 2004 10:05:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925000503.GA10873@gondor.apana.org.au>
References: <20040924232053.GA7807@gondor.apana.org.au> <20040924163328.7597352c.davem@davemloft.net> <20040924233555.GA7962@gondor.apana.org.au> <20040924233713.GA8001@gondor.apana.org.au> <20040924164540.2d750572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924164540.2d750572.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Sep 24, 2004 at 04:45:40PM -0700, David S. Miller wrote:
> 
> I still am hesitant about your idea.

Alright let's talk more about it :)

> You're willing to do a very likely re-alloc every transaction
> where as I'm suggesting a single allocation for the socket at
> creation time which is used for every transaction on that
> socket.

Yes.  However, what we really care about is not how many
reallocations there are, but how likely are they going to fail.

In your scheme, every netlink socket gets a page regardless
of whether it's going to be used (think of a socket for
multicast reception only).  That means at the point just
before the realloc, your scheme would have allocated at least
as much memory as my method, if not more.  Therefore I'd
argue that the realloc is more likely to fail for you.

Let's also consider what happens when it does fail.  In your
scheme you've got to drop the packet.  In mine, you just continue
as we do now.
 
> your scheme:
> 
>    Allocate full PAGE_SIZE SKB for each netlink transaction,
>    reallocate data area at end of building each transaction.

That's not quite true.  Some users (e.g., tcp_diag) can and do
accurately estimate the final message size.  They do not require
a realloc/copy at all.

> So, two data area kmalloc()'s per netlink response compared
> to one for mine.

Now I admit that is one weakness in my scheme.  However, I'd
argue that the performance cost of doing one extra kmalloc is
lost when compared to the rest of the work in filling up the
skb and copying it, no?

> Your scheme doesn't even avoid the copy.  What's the advantage?

Actually, it does avoid the copy for all dumped packets except the
final one as well as those packets that are near the right size already.

> Furthermore my per-socket PAGE_SIZE scratch area is likely to
> get very good cache hit rates making the copy very inexpensive.

True.  But surely it is better to not copy at all where possible?

Here is the real patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.53 vs edited =====
--- 1.53/net/netlink/af_netlink.c	2004-09-22 12:32:44 +10:00
+++ edited/net/netlink/af_netlink.c	2004-09-25 09:53:19 +10:00
@@ -536,12 +536,25 @@
 	sock_put(sk);
 }
 
+static inline void netlink_trim(struct sk_buff *skb, int allocation)
+{
+	int delta = skb->end - skb->tail;
+
+	if (delta * 2 < skb->truesize)
+		return;
+	if (pskb_expand_head(skb, 0, -delta, allocation))
+		return;
+	skb->truesize -= delta;
+}
+
 int netlink_unicast(struct sock *ssk, struct sk_buff *skb, u32 pid, int nonblock)
 {
 	struct sock *sk;
 	int err;
 	long timeo;
 
+	netlink_trim(skb, gfp_any());
+
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
 	sk = netlink_getsockbypid(ssk, pid);
@@ -587,6 +600,8 @@
 	struct sk_buff *skb2 = NULL;
 	int protocol = ssk->sk_protocol;
 	int failure = 0, delivered = 0;
+
+	netlink_trim(skb, allocation);
 
 	/* While we sleep in clone, do not allow to change socket list */
 

--6TrnltStXW4iwmi0--
