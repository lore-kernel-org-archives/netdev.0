From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sk->sk_socket seems to disappear before connection termination
Date: Wed, 10 Nov 2010 17:44:11 +0100
Message-ID: <1289407451.2860.239.camel@edumazet-laptop>
References: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr>
	 <1289368037.2700.14.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1011101148060.18018@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Howells <dhowells@redhat.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	=?UTF-8?Q?Rafa=C5=82?= Maj <rafal.maj.it@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57590 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756977Ab0KJQoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 11:44:19 -0500
In-Reply-To: <alpine.LNX.2.01.1011101148060.18018@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 11:53 +0100, Jan Engelhardt a =C3=A9=
crit :
> On Wednesday 2010-11-10 06:47, Eric Dumazet wrote:
> >Le mercredi 10 novembre 2010 =C3=A0 02:09 +0100, Jan Engelhardt a =C3=
=A9crit :
> >> Hi,
> >>=20
> >> Rafa=C5=82 reported this to us on IRC, paraphrasing what has been =
observed:
> >>=20
> >> Using a simple rule like `iptables -A OUTPUT -p tcp --dport 80 -j =
LOG=20
> >> --log-uid`, one can observe on creating a connection and terminati=
ng
> >> it that the trailing packets have skb->sk->sk_socket =3D=3D NULL.
> >> Is this intended? Is the socket not retained until after TCP has
> >> sent out the closing exchange?
> >>=20
> >> As I can reproduce:
> >>=20
> >> $ telnet 134.76.13.21 80
> >> Trying 134.76.13.21...
> >> Connected to 134.76.13.21.
> >> Escape character is '^]'.
> >> ^]
> >> telnet> ^D
> >> Connection closed.
> >>=20
> >> [491419.500978] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.1=
3.21 LEN=3D60 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35420 DF PROTO=3DTCP=
 SPT=3D58613 DPT=3D80 WINDOW=3D5488 RES=3D0x00 SYN URGP=3D0 UID=3D25121=
 GID=3D100=20
> >> [491419.511533] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.1=
3.21 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35421 DF PROTO=3DTCP=
 SPT=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0 UID=3D25121 G=
ID=3D100=20
> >> [491420.052182] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.1=
3.21 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35422 DF PROTO=3DTCP=
 SPT=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK FIN URGP=3D0 UID=3D251=
21 GID=3D100=20
> >> [491420.063619] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.1=
3.21 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35423 DF PROTO=3DTCP=
 SPT=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0=20
> >
> >Hmmm... skb->sk->sk_socket is really NULL ?
> >Are you sure its not skb->sk->sk_socket->file which is NULL ?
>=20
> I am certain of it, having augmented ipt_LOG/xt_LOGMARK temporarily b=
y=20
> appropriate printks.
>=20
> >In this case, you might need to use sock_i_uid() / sock_i_ino() as a
> >fallback ? (expensive because they take a rwlock)
>=20
> No, sock_i_uid also uses sk->sk_socket. What is interesting though is=
=20
> that sock_i_uid uses SOCK_INODE(sk->sk_socket)->i_uid, but xt_owner u=
ses=20
> sk->sk_socket->file->f_cred->fsuid. Would you have an idea as to why=20
> that is?
> Dave Howells (cced) did the last change on it.
>=20

Hmm, this is not what I get here. Could you please recheck ?

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.=
c
index 72ffc8f..b0933b7 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -337,6 +337,8 @@ static void dump_packet(struct sbuff *m,
        /* Max length: 15 "UID=3D4294967295 " */
        if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
                read_lock_bh(&skb->sk->sk_callback_lock);
+               pr_err("sk=3D%p sk->sk_socket=3D%p file=3D%p\n",
+                       skb->sk, skb->sk->sk_socket, skb->sk->sk_socket=
 ? skb->sk->sk_socket->file : NULL);
                if (skb->sk->sk_socket && skb->sk->sk_socket->file)
                        sb_add(m, "UID=3D%u GID=3D%u ",
                                skb->sk->sk_socket->file->f_cred->fsuid=
,


[ 9917.808796] ipt_LOG: sk=3Dffff880118bd32c0 sk->sk_socket=3Dffff88011=
d0d8c00 file=3Dffff88011cd4e100
[ 9917.808851] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.20.1=
10 LEN=3D60 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D63701 DF PROTO=3DTCP S=
PT=3D60088 DPT=3D22 WINDOW=3D4380 RES=3D0x00 SYN URGP=3D0 UID=3D0 GID=3D=
0=20
[ 9917.809091] ipt_LOG: sk=3Dffff880118bd32c0 sk->sk_socket=3Dffff88011=
d0d8c00 file=3Dffff88011cd4e100
[ 9917.809142] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.20.1=
10 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D63702 DF PROTO=3DTCP S=
PT=3D60088 DPT=3D22 WINDOW=3D35 RES=3D0x00 ACK URGP=3D0 UID=3D0 GID=3D0=
=20
[ 9917.814199] ipt_LOG: sk=3Dffff880118bd32c0 sk->sk_socket=3Dffff88011=
d0d8c00 file=3Dffff88011cd4e100
[ 9917.814251] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.20.1=
10 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D63703 DF PROTO=3DTCP S=
PT=3D60088 DPT=3D22 WINDOW=3D35 RES=3D0x00 ACK URGP=3D0 UID=3D0 GID=3D0=
=20
[ 9920.234680] ipt_LOG: sk=3Dffff880118bd32c0 sk->sk_socket=3Dffff88011=
d0d8c00 file=3Dffff88011cd4e100
[ 9920.234731] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.20.1=
10 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D63704 DF PROTO=3DTCP S=
PT=3D60088 DPT=3D22 WINDOW=3D35 RES=3D0x00 ACK FIN URGP=3D0 UID=3D0 GID=
=3D0=20
[ 9920.235221] ipt_LOG: sk=3Dffff880078998000 sk->sk_socket=3Dffff88007=
8c58300 file=3D          (null)
[ 9920.235271] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.20.1=
10 LEN=3D52 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3DTCP SPT=3D=
60088 DPT=3D22 WINDOW=3D35 RES=3D0x00 ACK URGP=3D0=20


You can see in my log, that the last packet seems to be from a differen=
t socket !
(sk pointer changed to ffff880078998000 !)

Well well well, thats an ACK, in answer to FIN packet received from rem=
ote side.





