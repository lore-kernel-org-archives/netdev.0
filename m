From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Sun, 30 Jan 2005 18:45:07 +0000
Message-ID: <20050130184507.F25000@flint.arm.linux.org.uk>
References: <16888.58622.376497.380197@robur.slu.se> <20050127164918.C3036@flint.arm.linux.org.uk> <20050127123326.2eafab35.davem@davemloft.net> <20050128001701.D22695@flint.arm.linux.org.uk> <20050127163444.1bfb673b.davem@davemloft.net> <20050128085858.B9486@flint.arm.linux.org.uk> <20050130132343.A25000@flint.arm.linux.org.uk> <41FD17FE.6050007@trash.net> <41FD18C5.6090108@trash.net> <41FD2043.3070303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Robert.Olsson@data.slu.se,
        akpm@osdl.org, torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41FD2043.3070303@trash.net>; from kaber@trash.net on Sun, Jan 30, 2005 at 06:58:27PM +0100
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 30, 2005 at 06:58:27PM +0100, Patrick McHardy wrote:
> Patrick McHardy wrote:
> >> Russell King wrote:
> >>> I don't know if the code is using fragment lists in ip_fragment(), but
> >>> on reading the code a question comes to mind: if we have a list of
> >>> fragments, does each fragment skb have a valid (and refcounted) dst
> >>> pointer before ip_fragment() does it's job?  If yes, then isn't the
> >>> first ip_copy_metadata() in ip_fragment() going to overwrite this
> >>> pointer without dropping the refcount?
> >>>
> >> Nice spotting. If conntrack isn't loaded defragmentation happens after
> >> routing, so this is likely the cause.
> >
> > OTOH, if conntrack isn't loaded forwarded packet are never defragmented,
> > so frag_list should be empty. So probably false alarm, sorry.
> 
> Ok, final decision: you are right :) conntrack also defragments locally
> generated packets before they hit ip_fragment. In this case the fragments
> have skb->dst set.

Good news - with this in place, I no longer have refcounts of 14000!
After 18 minutes (the first clearout of the dst cache from 500 odd
down to 11 or so), all dst cache entries have a ref count of zero.

I'll check it again later this evening to be sure.

Thanks Patrick.

> ===== net/ipv4/ip_output.c 1.74 vs edited =====
> --- 1.74/net/ipv4/ip_output.c	2005-01-25 01:40:10 +01:00
> +++ edited/net/ipv4/ip_output.c	2005-01-30 18:54:43 +01:00
> @@ -389,6 +389,7 @@
>  	to->priority = from->priority;
>  	to->protocol = from->protocol;
>  	to->security = from->security;
> +	dst_release(to->dst);
>  	to->dst = dst_clone(from->dst);
>  	to->dev = from->dev;
>  


-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
