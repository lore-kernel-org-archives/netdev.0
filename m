From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [2.6 PATCH] ipvs - properly handle non-linear skbs
Date: Mon, 06 Oct 2003 07:42:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006000225.AF7642C0A7@lists.samba.org>
References: <Pine.LNX.4.44.0310051151430.1204-101000@u.domain.uli>
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-reply-to: Your message of "Sun, 05 Oct 2003 12:09:20 +0300."
             <Pine.LNX.4.44.0310051151430.1204-101000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <Pine.LNX.4.44.0310051151430.1204-101000@u.domain.uli> you write:
> 	Hello,
> 
> 	Attached is a patch that includes the changes from
> Rusty about handling non-linear skbs correctly and modified
> a bit from Wensong Zhang and me. This is a huge patch that changes
> interfaces for many functions. It looks difficult to split it in
> parts but if required we can try to do it. It is ready for
> inclusion.

Hi Julian!

	I diffed our two patches.  Is see you still use iph temp vars:
fair enough: I removed mine after some subtle bugs (although it does
make the code a bit uglier).  

Looks really good.  Could you just clarify a couple of things for me please?

@@ -527,10 +528,7 @@ struct ip_vs_conn {
 	struct ip_vs_dest       *dest;          /* real server */
 	atomic_t                in_pkts;        /* incoming packet counter */
 
-	/* packet transmitter for different forwarding methods.  If it
-	   mangles the packet, it must return NF_DROP or NF_STOLEN, otherwise
-	   this must be changed to a sk_buff **.
-	 */
+	/* packet transmitter for different forwarding methods */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
 			   struct ip_vs_protocol *pp);

This comment is still true: the skb pointer from the caller is
useless, so xmit *must* return NF_DROP or NF_STOLEN.  I thought about
making it return void and the callers always return NF_STOLEN, but
there was enough change already.  You might want to put a comment in
there.

ip_vs_make_skb_writable(): how is this different from
skb_ip_make_writable(), except you have to maintain it yourself?  The
advantage of the general one is that Dave looks after it for us 8)

In ip_vs_out_icmp():

 	/* Is the embedded protocol header present? */
 	if (unlikely(ciph.frag_off & __constant_htons(IP_OFFSET) &&
-		     /* FIXME: Remove minhlen, and surely dont_defrag
-		      * test is backwards? --RR */
 		     (pp->minhlen || pp->dont_defrag)))
 		return NF_ACCEPT;

If the protocol says "don't defrag" they never see fragmented packets.
AFAICT, minhlen and dont_defrag are now the same everywhere (minhlen
is not respected: protocols are expected to catch skb_copy_bits
failing on their own, and they do).  Perhaps drop minhlen altogether,
and just keep dont_defrag?

Hey, thanks for doing the hard work for me!

Cheers,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
