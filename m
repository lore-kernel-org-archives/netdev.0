From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Sun, 24 Oct 2010 19:14:15 -0700 (PDT)
Message-ID: <20101024.191415.226787411.davem@davemloft.net>
References: <1287704752.11051.79.camel@Dan>
	<AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751595Ab0JYCNw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 22:13:52 -0400
In-Reply-To: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 21 Oct 2010 17:31:12 -0700

> We already (long ago) decided that POSIX.1 compatibility be damned,
> and that reading and writing more than 2GB in a single system call is
> bogus: so normal write calls will actually limit size_t arguments to
> MAX_INT, exactly so that various filesystems don't have to worry abou=
t
> overflow and can keep length arguments in an "int".

Maybe the filesystem paths are this way, but the bulk of the socket
paths properly use size_t when touching anything even related
to an I/O length.

I know that TCP can do a >=3D 4GB write just fine right now.

In fact if you look I recently removed the last obstacle to this based
upon a bug report from a user trying to do a 4GB write (which ended up
getting truncated to zero):

commit 01db403cf99f739f86903314a489fb420e0e254f
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Sep 27 20:24:54 2010 -0700

    tcp: Fix >4GB writes on 64-bit.
   =20
    Fixes kernel bugzilla #16603
   =20
    tcp_sendmsg() truncates iov_len to an 'int' which a 4GB write to wr=
ite
    zero bytes, for example.
   =20
    There is also the problem higher up of how verify_iovec() works.  I=
t
    wants to prevent the total length from looking like an error return
    value.
   =20
    However it does this using 'int', but syscalls return 'long' (and
    thus signed 64-bit on 64-bit machines).  So it could trigger
    false-positives on 64-bit as written.  So fix it to use 'long'.
   =20
    Reported-by: Olaf Bonorden <bono@onlinehome.de>
    Reported-by: Daniel B=FCse <dbuese@gmx.de>
    Reported-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Anyways, my point is that not only is the socket layer entirely ready
for this, it is also the case that while 2GB may seem big today in
most places, some day it might not be.  :-)
