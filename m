From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: userspace build broken by include changes
Date: Sat, 15 Oct 2016 17:02:34 +0300
Message-ID: <20161015140234.GB2831@lakka.kapsi.fi>
References: <CA+CX+bgbJ=aw7155Z_BbL4FpBVgu6RL4d2jR4dj2FNubj-v1BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Pascal Terjan <pterjan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:43794 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754376AbcJOOCh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Oct 2016 10:02:37 -0400
Content-Disposition: inline
In-Reply-To: <CA+CX+bgbJ=aw7155Z_BbL4FpBVgu6RL4d2jR4dj2FNubj-v1BA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Oct 15, 2016 at 12:40:43PM +0100, Pascal Terjan wrote:
> rp-pppoe plugin of ppp no longer builds:
> 
> In file included from pppoe.h:87:0,
>                  from plugin.c:29:
> /usr/include/linux/in.h:28:3: error: redeclaration of enumerator 'IPPROTO_IP'
>    IPPROTO_IP = 0,  /* Dummy protocol for TCP  */
>    ^
> /usr/include/netinet/in.h:42:5: note: previous definition of
> 'IPPROTO_IP' was here
>      IPPROTO_IP = 0,    /* Dummy protocol for TCP.  */
> 
> Short reproducer:
> 
> #include <sys/cdefs.h>
> #include <sys/socket.h>
> #include <linux/if.h>
> #include <netinet/in.h>
> #include <linux/ppp_defs.h>
> #include <linux/if_pppox.h>
> 
> Full log:
> http://pkgsubmit.mageia.org/autobuild/cauldron/x86_64/core/2016-10-12/ppp-2.4.7-8.mga6.src.rpm/build.0.20161012185227.log
> 
> Moving the include of linux/if.h after netinet/in.h fixes it.
> 
> I guess the breakage is caused by
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/include/uapi/linux?id=eafe92114308acf14e45c6c3d154a5dad5523d1a
> but the commit doesn't look wrong to me.

These kernel uapi headers did not declare their dependencies correctly
and this patch fixed it. Many uapi headers from kernel unfortunately
conflict with glibc and other userspace headers, and userspace code is often
relying on this behavior, e.g. has had a working order of includes.

My patch series has compatibility changes so that kernel headers can be
included after glibc ones.

Unfortunately I haven't had time to provide similar patches to glibc so
things might breaks if kernel headers are included before glibc headers.

So the best I can do for now is to ask you to change the userspace include
order to first include glibc headers and then kernel uapi ones.

This is an unfortunate kernel header API break, sorry. ABI's are not affected
though.

-Mikko
