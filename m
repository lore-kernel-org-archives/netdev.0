From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Tue, 15 Feb 2005 10:10:06 +0200
Message-ID: <4211AE5E.2010506@kolumbus.fi>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221433.GB18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>This patch adds a pointer to the route corresponding to the specific
>flow over the SA of an xfrm_dst that's being used.
>
>It also sets the next pointer of each xfrm_dst to the one above it.
>This allows to traverse the list upwards from the bottom.
> 
>Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
>Cheers,
>  
>
>------------------------------------------------------------------------
> /* Decapsulation state, used by the input to store data during
>===== net/ipv4/xfrm4_policy.c 1.14 vs edited =====
>--- 1.14/net/ipv4/xfrm4_policy.c	2005-02-14 14:02:13 +11:00
>+++ edited/net/ipv4/xfrm4_policy.c	2005-02-14 14:29:35 +11:00
>@@ -55,18 +55,29 @@
> 	struct rtable *rt = rt0;
> 	u32 remote = fl->fl4_dst;
> 	u32 local  = fl->fl4_src;
>+	struct flowi fl_tunnel = {
>+		.nl_u = {
>+			.ip4_u = {
>+				.saddr = local,
>+				.daddr = remote
>+			}
>+		}
>+	};
> 	int i;
> 	int err;
> 	int header_len = 0;
> 	int trailer_len = 0;
> 
> 	dst = dst_prev = NULL;
>  
>

Shouldn't this pinning happen inside the loop for eaxh xdst, to be 
balanced with  the dst_release(xdst->route) in xfrm_dst_destroy ?

>+	dst_hold(&rt->u.dst);
> 
> 	for (i = 0; i < nx; i++) {
> 		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
>+		struct xfrm_dst *xdst;
> 
> 		if (unlikely(dst1 == NULL)) {
> 			err = -ENOBUFS;
>  
>
