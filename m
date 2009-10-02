From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Fri, 02 Oct 2009 20:05:01 +0200
Message-ID: <4AC640CD.2030204@gmail.com>
References: <20090930004820.GC19540@obsidianresearch.com> <E1Mssmb-004RJz-Hf@intern.SerNet.DE> <20091002171029.GG5191@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>,
	netdev@vger.kernel.org, Volker Lendecke <vl@samba.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37001 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbZJBSFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:05:19 -0400
In-Reply-To: <20091002171029.GG5191@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Gunthorpe a =E9crit :

>=20
> I'd suggest a construct like the following as a compatability
> solution:
>=20
> struct pollfd pfd =3D {.fd =3D tcpfd, events =3D POLLIN | POLLRDHUP};
> while (..) {
>    rc =3D splice(tcpfd,0,pfd[1],0,count,SPLICE_F_MOVE | SPLICE_F_NONB=
LOCK);
>    if (rc =3D=3D -1)
>      //...
>    if (rc =3D=3D 0) {
>        if (pfd.revents & POLLRDHUP)
>           // oops, EOF on TCP
>=20
>        /* Might be an old kernel that nonblocks on TCP, have to check
>           if this is EOF or do blocking. */
>        rc =3D poll(&pfd,1,-1);
>        if (rc =3D=3D -1)
>           //...
>    }
>=20
>    rc =3D splice(pfd[0],0,ofd,0,..., SPLICE_F_MOVE)
> }
>=20
> Which should add no overhead in the new splice blocks case, and falls
> back gracefully on older kernels..
>=20

Agreed, thanks for the tip.

Indeed, new kernel will permit a loop with only splice() syscalls, whil=
e on an old
kernel, some poll() syscalls might be needed if tcp socket is empty.


