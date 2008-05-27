From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 03:08:51 +0100
Message-ID: <20080527020849.GG28241@solarflare.com>
References: <200805270325.24323.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:51311 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756220AbYE0CI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 22:08:57 -0400
Content-Disposition: inline
In-Reply-To: <200805270325.24323.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> 
> Hi,
> 
> The following socket lock dropping in skb_splice_bits seems to open a race 
> condition which causes an invalid kernel access:
> 
> >        if (spd.nr_pages) {
> >                int ret;
> >
> >                /*
> >                 * Drop the socket lock, otherwise we have reverse
> >                 * locking dependencies between sk_lock and i_mutex
> >                 * here as compared to sendfile(). We enter here
> >                 * with the socket lock held, and splice_to_pipe() will
> >                 * grab the pipe inode lock. For sendfile() emulation,
> >                 * we call into ->sendpage() with the i_mutex lock held
> >                 * and networking will grab the socket lock.
> >                 */
> >                release_sock(__skb->sk);
> >                ret = splice_to_pipe(pipe, &spd);
> >                lock_sock(__skb->sk);
> >                return ret;
> >        }

Given the previous comment, that certainly looks wrong.

<snip>
> Commenting out the sequence that drops the socket lock seems to fix the
> problem on my setup.

But this could apparently cause deadlock.  Surely the correct fix is
to copy __skb->sk to a local variable before calling splice_to_pipe()
so we can re-lock it?

Ben.

--
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
