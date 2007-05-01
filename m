From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with
 "Lost compression sync"
Date: Mon, 30 Apr 2007 20:36:06 -0700
Message-ID: <20070430203606.ce9bc944.akpm@linux-foundation.org>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org>
	<1177939870.5872.29.camel@localhost.localdomain>
	<200704302112.27930.stefan.wenk@gmx.at>
	<200705010520.10097.stefan.wenk@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Stefan Wenk <stefan.wenk@gmx.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43476 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946220AbXEADgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 23:36:19 -0400
In-Reply-To: <200705010520.10097.stefan.wenk@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 May 2007 05:20:10 +0200 Stefan Wenk <stefan.wenk@gmx.at> wrote:

> > What is more interesting is that the pppd server log is logging errors.
> > There are LCP EchoReq and EchoRep. Later a LCP ProtoRej messages occurs and
> > then the connection is broken. I have attached a pppdump file of the client
> > side if it helps. This file can be read e.g. by wireshark.
> 
> I should have mentioned that I have made some other modifications in order to 
> see the kernel logging. This was because I could not find the documentation 
> how to turn debugging on for ppp_deflate and because I'm only seeing printk 
> of type KERN_ERR and not those with KERN_DEBUG. So I might be missing some 
> additional KERN_DEBUG loggings. If somebody can point me to the documentation 
> how to get KERN_DEBUG to the log file I can make the test again.

>From the commend line: `dmesg -n 8'.

The really big fix is to boot with the ignore_loglevel boot option.  This will
turn on all messages and will defeat any userspace attempt to turn the
loglevel down.

> Here is the full diff 

Thanks for persisting with this.  The problem is rather serious.

> --- ppp_deflate.c.orig  2007-04-23 20:47:08.000000000 +0200
> +++ ppp_deflate.c       2007-04-30 19:38:19.000000000 +0200
> @@ -174,7 +174,7 @@ static int z_comp_init(void *arg, unsign
> 
>         state->seqno = 0;
>         state->unit  = unit;
> -       state->debug = debug;
> +       state->debug = 1;
> 
>         zlib_deflateReset(&state->strm);
> 
> @@ -393,7 +393,7 @@ static int z_decomp_init(void *arg, unsi
> 
>         state->seqno = 0;
>         state->unit  = unit;
> -       state->debug = debug;
> +       state->debug = 1;
>         state->mru   = mru;
> 
>         zlib_inflateReset(&state->strm);
> @@ -487,12 +487,18 @@ int z_decompress(void *arg, unsigned cha
>          */
>         for (;;) {
>                 r = zlib_inflate(&state->strm, Z_PACKET_FLUSH);
> -               if (r != Z_OK) {
> +//             if (r != Z_OK) {
> +                if ((r != Z_OK) && (r != Z_BUF_ERROR)) {
>                         if (state->debug)
> -                               printk(KERN_DEBUG "z_decompress%d: inflate 
> returned %d (%s)\n",
> +                               printk(KERN_ERR "z_decompress%d: inflate 
> returned %d (%s)\n",
>                                        state->unit, r, (state->strm.msg? 
> state->strm.msg: ""));
>                         return DECOMP_FATALERROR;
>                 }
> +                if (r == Z_BUF_ERROR) {
> +                             printk(KERN_ERR "z_decompress%d: Would have 
> triggered an error as inflate returned %d (%s)\n",
> +                             state->unit, r, (state->strm.msg? 
> state->strm.msg: ""));
> +                }
> 

(that was wordwrapped).

What does it do?

