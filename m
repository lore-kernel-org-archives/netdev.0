From: Stefan Wenk <stefan.wenk@gmx.at>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with "Lost compression sync"
Date: Tue, 1 May 2007 09:27:52 +0200
Message-ID: <200705010927.52426.stefan.wenk@gmx.at>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org> <200705010520.10097.stefan.wenk@gmx.at> <20070430203606.ce9bc944.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:38941 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1030930AbXEAH32 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 03:29:28 -0400
In-Reply-To: <20070430203606.ce9bc944.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >From the commend line: `dmesg -n 8'.
>
> The really big fix is to boot with the ignore_loglevel boot option.  This
> will turn on all messages and will defeat any userspace attempt to turn the
> loglevel down.
Thanks. With this command I see also the KERN_DEBUG printks now.
>
> > Here is the full diff
>
> Thanks for persisting with this.  The problem is rather serious.
If you have instructions how to proceed I'm looking forward to help solving 
it. I guess reverting the zlib modification in the Linux main line is no 
option. What I'm wondering is that this issue hasn't been detected earlier. 
Looks as nobody is using analogue modems and nullmodem cables any more.
>
> > --- ppp_deflate.c.orig  2007-04-23 20:47:08.000000000 +0200
> > +++ ppp_deflate.c       2007-04-30 19:38:19.000000000 +0200
> > @@ -174,7 +174,7 @@ static int z_comp_init(void *arg, unsign
> >
> >         state->seqno = 0;
> >         state->unit  = unit;
> > -       state->debug = debug;
> > +       state->debug = 1;
> >
> >         zlib_deflateReset(&state->strm);
> >
> > @@ -393,7 +393,7 @@ static int z_decomp_init(void *arg, unsi
> >
> >         state->seqno = 0;
> >         state->unit  = unit;
> > -       state->debug = debug;
> > +       state->debug = 1;
> >         state->mru   = mru;
> >
> >         zlib_inflateReset(&state->strm);
> > @@ -487,12 +487,18 @@ int z_decompress(void *arg, unsigned cha
> >          */
> >         for (;;) {
> >                 r = zlib_inflate(&state->strm, Z_PACKET_FLUSH);
> > -               if (r != Z_OK) {
> > +//             if (r != Z_OK) {
> > +                if ((r != Z_OK) && (r != Z_BUF_ERROR)) {
> >                         if (state->debug)
> > -                               printk(KERN_DEBUG "z_decompress%d:
> > inflate returned %d (%s)\n",
> > +                               printk(KERN_ERR "z_decompress%d: inflate
> > returned %d (%s)\n",
> >                                        state->unit, r, (state->strm.msg?
> > state->strm.msg: ""));
> >                         return DECOMP_FATALERROR;
> >                 }
> > +                if (r == Z_BUF_ERROR) {
> > +                             printk(KERN_ERR "z_decompress%d: Would have
> > triggered an error as inflate returned %d (%s)\n",
> > +                             state->unit, r, (state->strm.msg?
> > state->strm.msg: ""));
> > +                }
>
> (that was wordwrapped).
Sorry. I should have made an attachment.
>
> What does it do?
It was just for debugging. Forget it. Now I have changed these modifications 
back, and I do not see more debug information except those below:

z_decompress0: Would have triggered an error as inflate returned -5 ()
z_decompress0: Would have triggered an error as inflate returned -5 ()
z_decompress0: Would have triggered an error as inflate returned -5 ()
..
As there are no debug logs in inflate.c I can't provide more information by 
now.
