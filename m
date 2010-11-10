From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: sk->sk_socket seems to disappear before connection termination
Date: Wed, 10 Nov 2010 11:53:48 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011101148060.18018@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr> <1289368037.2700.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Howells <dhowells@redhat.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	=?UTF-8?Q?Rafa=C5=82_Maj?= <rafal.maj.it@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289368037.2700.14.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-11-10 06:47, Eric Dumazet wrote:
>Le mercredi 10 novembre 2010 =C3=A0 02:09 +0100, Jan Engelhardt a =C3=A9=
crit :
>> Hi,
>>=20
>> Rafa=C5=82 reported this to us on IRC, paraphrasing what has been ob=
served:
>>=20
>> Using a simple rule like `iptables -A OUTPUT -p tcp --dport 80 -j LO=
G=20
>> --log-uid`, one can observe on creating a connection and terminating
>> it that the trailing packets have skb->sk->sk_socket =3D=3D NULL.
>> Is this intended? Is the socket not retained until after TCP has
>> sent out the closing exchange?
>>=20
>> As I can reproduce:
>>=20
>> $ telnet 134.76.13.21 80
>> Trying 134.76.13.21...
>> Connected to 134.76.13.21.
>> Escape character is '^]'.
>> ^]
>> telnet> ^D
>> Connection closed.
>>=20
>> [491419.500978] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.=
21 LEN=3D60 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35420 DF PROTO=3DTCP S=
PT=3D58613 DPT=3D80 WINDOW=3D5488 RES=3D0x00 SYN URGP=3D0 UID=3D25121 G=
ID=3D100=20
>> [491419.511533] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.=
21 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35421 DF PROTO=3DTCP S=
PT=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0 UID=3D25121 GID=
=3D100=20
>> [491420.052182] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.=
21 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35422 DF PROTO=3DTCP S=
PT=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK FIN URGP=3D0 UID=3D25121=
 GID=3D100=20
>> [491420.063619] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.=
21 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35423 DF PROTO=3DTCP S=
PT=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0=20
>
>Hmmm... skb->sk->sk_socket is really NULL ?
>Are you sure its not skb->sk->sk_socket->file which is NULL ?

I am certain of it, having augmented ipt_LOG/xt_LOGMARK temporarily by=20
appropriate printks.

>In this case, you might need to use sock_i_uid() / sock_i_ino() as a
>fallback ? (expensive because they take a rwlock)

No, sock_i_uid also uses sk->sk_socket. What is interesting though is=20
that sock_i_uid uses SOCK_INODE(sk->sk_socket)->i_uid, but xt_owner use=
s=20
sk->sk_socket->file->f_cred->fsuid. Would you have an idea as to why=20
that is?
Dave Howells (cced) did the last change on it.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
