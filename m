From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/tcp6 inconsistent line length
Date: Tue, 17 Jan 2012 16:13:17 +0100
Message-ID: <1326813197.2259.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120117152919.7746a3f9@wwwwww-701SD>
	 <AE90C24D6B3A694183C094C60CF0A2F6D8AF49@saturn3.aculab.com>
	 <20120117161447.5ef681c9@wwwwww-701SD>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: abirvalg@lavabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47420 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab2AQPNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:13:21 -0500
Received: by wibhm6 with SMTP id hm6so1450580wib.19
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 07:13:20 -0800 (PST)
In-Reply-To: <20120117161447.5ef681c9@wwwwww-701SD>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 16:14 +0000, abirvalg@lavabit.com a =C3=
=A9crit :

> Thank you, David. I first fread() the whole file to membuf and then p=
rocess it thusly trying to find a line that matches my source port (por=
thex) :
>=20
> while(1){
>     memcpy(buffer,&tcp6_membuf[184+170*i],4);
>     if ( !memcmp ( porthex, buffer, 4 ) ){ //match!
>         goto endloop;
>     }
>      i++;
>      continue;


Wow... no comment on this code.

>=20
> N.B. 184 is the offset of source port on line 2 from the beginning of=
 file (line 1 is used for column headings)
>=20
> my /proc/net/tcp6 file contains 300 - 500 lines and I parse it at lea=
st from 4 to 10 times per sec. So the maximum is 5000 iterations per se=
c. It would be very costly CPU wise to do strchr(buf, '\n')
> =20
> I'm not skillful enough to understand the code in kernel sources.
> My concern boils down to this:
>=20
> Was /proc/net/tcp* meant to have an equal length of each line?
> If yes, then I discovered a bug.
> If no, then would it be possible to patch the kernel to enable an equ=
al length on each line?=20
>=20

netlink can give you the needed information much faster.

Take a look at what is done by :

"ss -emoi src :22"
State      Recv-Q Send-Q                   Local Address:Port
Peer Address:Port=20
ESTAB      0      0                       192.168.20.108:22
10.37.168.20:39444  timer:(keepalive,115min,0) ino:6852
sk:ffff88011ca81900
	 mem:(r0,w0,f8192,t0) ts sack cubic wscale:4,4 rto:208 rtt:8/11 ato:51
cwnd:10 ssthresh:24 send 14.5Mbps rcv_rtt:15 rcv_space:14480


sendmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D0=
0000000},
msg_iov(3)=3D[{"`\0\0\0\22\0\1\3@\342\1\0\0\0\0\0\2\0\0\17\0\0\0\0\0\0\=
0\0
\0\0\0\0"..., 76}, {"\24\0\1\0", 4}, {"\7\20\24\0\0\0\0\0\26\0\0\0\0\0\=
0
\0", 16}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 96
recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D0=
0000000},
msg_iov(1)=3D[{"\344\0\0\0\22\0\2\0@\342\1\0l\f\0\0\2\1\1\0\0\26\232\24
\300\250\24l320 "..., 8192}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D=
 228




One sendmsg() for the request, one recvmsg() for the answer (with _all_
details included), even if your /proc/net/tcp*** has 1.000.000 lines.

Really say no to /proc files.
