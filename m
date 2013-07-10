From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may need
 to happen earlier
Date: Wed, 10 Jul 2013 06:19:19 -0700
Message-ID: <1373462359.4600.11.camel@edumazet-glaptop>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
	 <20130517085923.GC14401@zion.uk.xensource.com>
	 <51D57C1F.8070909@hunenet.nl> <20130704150137.GW7483@zion.uk.xensource.com>
	 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
	 <20130705145319.GB9050@zion.uk.xensource.com>
	 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
	 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
	 <20130708154814.GI8027@zion.uk.xensource.com>
	 <51DBCF4F02000078000E3793@nat28.tlf.novell.com>
	 <20130709165134.GG19798@zion.uk.xensource.com>
	 <51DD221E02000078000E3BC6@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, davem@davemloft.net,
	Dion Kant <g.w.kant@hunenet.nl>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51DD221E02000078000E3BC6@nat28.tlf.novell.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-10 at 07:58 +0100, Jan Beulich wrote:

> 
> Yes, as the call stack provided by Dion proves. The question
> really is whether the patch somehow results in ->truesize to be
> incorrect, or whether - as Eric points out - this is "normal" for
> the sort of special SKBs here (having a rather small headlen). If
> what he says is applicable here, it may hint at the pulling we do
> still not being sufficient for the full TCP header to be in the linear
> part (which iirc is the main [if not the only purpose] of us doing
> the pull in the first place).

I have not closely followed the thread (it seems it did not began on
netdev so I do not have the first messages), but if we cook an skb with
no tailroom (headroom is irrelevant), and IP stack or TCP stack has to
pull more bytes from the frags to skb->head, then skb->head must be
reallocated to get more headroom before pulling the headers.

This operation is _expensive_, as it involves copy of struct
skb_shared_info and eventually page refcounts games if original skb
was cloned (sniffer)

We have a one time WARN_ON_ONCE() in skb_try_coalesce(),
to detect such non optimal behavior, but not in the fast path, only in
the part used in TCP coalescing.

So the right thing would be to cook skbs so that there is enough
tailroom.

But there are 256 bytes of tailroom, it should be enough unless some
huge amount of headers are used.

If you believe it's fine and very unlikely, then ignore the warning,
because using 512 bytes of tailroom for all skbs only to cope with very
unlikely reallocations is not worth it.
