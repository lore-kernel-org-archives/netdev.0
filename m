From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Tue, 22 Feb 2005 21:15:26 +1100
Message-ID: <20050222101526.GA5814@gondor.apana.org.au>
References: <20050221.162949.65179228.yoshfuji@linux-ipv6.org> <E1D3Wn9-00071h-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: AndyLiebman@aol.com, terryg@axian.com, netdev@oss.sgi.com,
        davem@davemloft.net, akpm@osdl.org
To: YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <E1D3Wn9-00071h-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 22, 2005 at 08:57:19PM +1100, Herbert Xu wrote:
> YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> > In article <20050221.162241.24618885.yoshfuji@linux-ipv6.org> (at Mon, 21 Feb 2005 16:22:41 +0900 (JST)), YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> says:
> > 
> >> [IPV6] Don't remove dev_snmp6 procfs entry until all users gone.
> 
> Sorry, but I don't see how this patch explains the oops the
> people saw.

OK, I think I see what you were trying to fix now.  Unfortunately
I think this patch doesn't quite cure the problem.

First of all you can't sleep in snmp6_unregister_dev so semaphores
are out.  More importantly, the race is still on.

Here is what happens:

CPU0					CPU1
ifdown eth0
	...
					ifup eth0
						snmp6_register_dev
							adds proc entry
in6_dev_finish_destroy
	snmp6_unregister_dev
		deletes new proc entry

The next ifdown may fail because snmp6_unregister_dev will retrieve the
name from a proc entry that's already been deleted.

I see two solutions:

1) Unregister the proc entry earlier.  In other words, do it in
addrconf_ifdown.  Since this is highly serialised it means that
we can't add the new proc entry before the old proc entry has
been deleted.

2) Fix procfs so that we delete by pointer instead of name.  This
makes sense from a semantic pointer of view.  However, for this
particular instance it means that we may have two "eth0" entries
for as long as the old idev entry sticks around.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
