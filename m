From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may need
 to happen earlier
Date: Mon, 08 Jul 2013 08:22:18 -0700
Message-ID: <1373296938.4979.111.camel@edumazet-glaptop>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
	 <20130517085923.GC14401@zion.uk.xensource.com>
	 <51D57C1F.8070909@hunenet.nl> <20130704150137.GW7483@zion.uk.xensource.com>
	 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
	 <20130705145319.GB9050@zion.uk.xensource.com>
	 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
	 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, davem@davemloft.net,
	Ian Campbell <ian.campbell@citrix.com>,
	Dion Kant <g.w.kant@hunenet.nl>, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-08 at 15:20 +0100, Jan Beulich wrote:

> Okay, so with that done (see below) Dion is now seeing the
> WARN_ON_ONCE(delta < len) in skb_try_coalesce() triggering. Of
> course, with it having crashed before, it's hard to tell whether the
> triggering now is an effect of the patch, or just got unmasked by it.

Please note this warning is not the sign of an error.

It can be triggered because network stack (IP + TCP) had to reallocate
skb->head to hold all the headers.

pskb_may_pull() doesn't change skb->truesize, for various reasons, so we
can have a situation where the warning triggers.

For example, it can happen when drivers use a really small skb->head,
like 64 bytes, as its not big enough to hold ethernet+IP+TCP headers.

For example, I did a patch on a wifi driver (iwl3945: better skb
management in rx path) because of this sub optimal skb->head sizing.
