From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 5 Feb 2005 20:10:44 -0800
Message-ID: <20050205201044.1b95f4e8.davem@davemloft.net>
References: <20050131162201.GA1000@stilzchen.informatik.tu-chemnitz.de>
	<20050205052407.GA17266@gondor.apana.org.au>
	<20050204213813.4bd642ad.davem@davemloft.net>
	<20050205061110.GA18275@gondor.apana.org.au>
	<20050204221344.247548cb.davem@davemloft.net>
	<20050205064643.GA29758@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, shemminger@osdl.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050205064643.GA29758@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Feb 2005 17:46:43 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This doesn't work because net/core/dst.c can only search based
> on dst->dev.  For the split device case, dst->dev is set to
> loopback_dev while rt6i_idev is set to the real device.

Indeed.  I didn't catch that.

> If we wanted to preserve the split device semantics, then we
> can create a local GC list in IPv6 so that it can search based
> on rt6i_idev as well as the other keys.

Ok, so this would entail changing each ipv6 dst_free() call
into one to ip6_dst_free(), which would:

	ip6_garbage_add(dst);
	dst_free(dst);

It would mean that dst_run_gc() would need to have some callback
like dst->ops->gc_destroy() or similar, which would allow ipv6
to delete the dst from it's local garbage list.

> Alternatively we can
> remove the dst->dev == dev check in dst_dev_event and dst_ifdown
> and move that test down to the individual ifdown functions.

I think there is a hole in this idea.... maybe.

If the idea is to scan dst_garbage_list down in ipv6 specific code,
you can't do that since 'dst' objects from every pool in the kernel
get put onto the dst_garbage_list.   It is generic.

They have no identity, so it's illegal to treat any member of that
list as an rt_entry, rt6_entry or any specific higher level dst
type.
