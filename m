From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 09:11:50 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BajZO-0001UK-00@gondolin.me.apana.org.au>
References: <20040616202341.GD29781@ms2.inr.ac.ru>
Cc: herbert@gondor.apana.org.au, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru (Alexey Kuznetsov)
In-Reply-To: <20040616202341.GD29781@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> So, holding pmtu at all the dst's is necessary and we have to sync
> those mtus with dst_path instead using it directly.

Agreed.  However, the we don't have enough dst's in the bundle as it
is because each policy only has one bundle, but there may be aa
arbitrary number of different paths and hence different PMTUs over
that bundle.

>> Now the problem with all this is that it looks pretty complicated.
> 
> I am afraid I still did not understand your troubles completely.
> 
> Actually, the last time when we discussed this we had only one
> but _damn_ ugly problem. We have to remember original packet content
> to reply with ICMP correctly, when encapsulating. Is it possible
> that you are confused with this? We do send invalid ICMP_FRAG_NEEDED
> from ip_fragment. PMTU discovery will work only if we reply to original,
> not transofrmed packet. See?

Well Alexey that's a totally different topic altogether :) Yes this
is something that we should look at since it is specified in RFC2401.

However, let's get the simple stuff to work first, that is, let's make
sure that Linux itself knows what the MTU is before we attempt to send
ICMP packets back to the original host.

Let me restate my problem in terms of examples.

Scenario 1:

This is what prompted me to look at this two months ago.  The stack
assumes that the MTU for an xfrm dst is equal to

	dst_pmtu(dst) - dst->header_len - dst->trailer_len

But this is not true for ESP due to block padding.  The trailer_len
is variable and the one we store in trailer_len is not the maximum.

There are two approaches to this problem.  We can either store the
maximum trailer_len, or make dst_pmtu(dst) return the correct MTU
directly.

The former is simple to do, but has the disadvantage of wasting
bandwidth up to a block.  The latter looks non-trivial, but is
pretty simple once we solve the following problems.

Scenario 2:

Suppose that we have a remote subnet where PMTU doesn't work for
whatever reason.  However, we do know what the correct MTU is.
If IPsec weren't involved, you could simply do

	ip r r 192.168.0.0/16 dev vpn mtu 1400

But this doesn't work with IPsec as the MTU is retrieved from the
path by dst_pmtu.  And the path is always the final gateway in
the bundle.

Scenario 3:

Suppose that your default gateway requires you to talk to it using
IPsec (wireless gateway for example).  As it is, this break PMTU
for everything over it.  The reason is that when we receive an
ICMP packet for a remote host behind the gateway, the MTU will be
stored in the route entry as usual.  But the route entry is not
used to calculate the MTU at all!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
