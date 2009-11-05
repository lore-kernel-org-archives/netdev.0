From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: set SPLICE_F_NONBLOCK after first buffer has been
 spliced
Date: Thu, 05 Nov 2009 12:21:53 +0100
Message-ID: <4AF2B551.6010302@gmail.com>
References: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag> <4AF2A929.3000201@gmail.com> <20091105105749.GA4901@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Max Kellermann <mk@cm4all.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57146 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456AbZKELWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 06:22:00 -0500
In-Reply-To: <20091105105749.GA4901@rabbit.intern.cm-ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max Kellermann a =E9crit :
> On 2009/11/05 11:30, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> I dont think this patch is correct. Could you describe your use case=
 ?
>=20
> See my second email, there's a demo source.
>=20
>> If you dont want to block on output pipe, you should set this NONBLO=
CK=20
>> flag before calling splice(SPLICE_F_NONBLOCK) syscall.
>>
>> ie : Use the socket in blocking mode, but output pipe in non-blockin=
g mode.
>=20
> Do you think that a splice() should block if the socket is readable
> and the pipe is writable according to select()?
>=20

Yes, this is perfectly legal

select() can return "OK to write on fd",
and still, write(fd, buffer, 10000000) is supposer/allowed to block if =
fd is not O_NDELAY

If you want to not block on fd, use O_NDELAY (if using write() syscall)=
,
or SPLICE_F_NONBLOCK splice() flag ?

Please read recent commit on this area and why I think your patch confl=
icts with
this commit.

commit 42324c62704365d6a3e89138dea55909d2f26afe
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Oct 1 15:26:00 2009 -0700

    net: splice() from tcp to pipe should take into account O_NONBLOCK

    tcp_splice_read() doesnt take into account socket's O_NONBLOCK flag

    Before this patch :

    splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE);
    causes a random endless block (if pipe is full) and
    splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
    will return 0 immediately if the TCP buffer is empty.

    User application has no way to instruct splice() that socket should=
 be in blocking mode
    but pipe in nonblock more.

    Many projects cannot use splice(tcp -> pipe) because of this flaw.

    http://git.samba.org/?p=3Dsamba.git;a=3Dhistory;f=3Dsource3/lib/rec=
vfile.c;h=3Dea0159642137390a0f7e57a123684e6e63e47581;hb=3DHEAD
    http://lkml.indiana.edu/hypermail/linux/kernel/0807.2/0687.html

    Linus introduced  SPLICE_F_NONBLOCK in commit 29e350944fdc2dfca1025=
00790d8ad6d6ff4f69d
    (splice: add SPLICE_F_NONBLOCK flag )

      It doesn't make the splice itself necessarily nonblocking (becaus=
e the
      actual file descriptors that are spliced from/to may block unless=
 they
      have the O_NONBLOCK flag set), but it makes the splice pipe opera=
tions
      nonblocking.

    Linus intention was clear : let SPLICE_F_NONBLOCK control the splic=
e pipe mode only

    This patch instruct tcp_splice_read() to use the underlying file O_=
NONBLOCK
    flag, as other socket operations do.
    Users will then call :

    splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK )=
;

    to block on data coming from socket (if file is in blocking mode),
    and not block on pipe output (to avoid deadlock)

    First version of this patch was submitted by Octavian Purdila

    Reported-by: Volker Lendecke <vl@samba.org>
    Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
    Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
    Acked-by: Jens Axboe <jens.axboe@oracle.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

