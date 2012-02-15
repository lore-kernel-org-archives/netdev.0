From: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Wed, 15 Feb 2012 18:36:29 +0100
Message-ID: <CAFJW8X_zvqVP+ZZO1BOFHa0XeywnieszMoSub_VKMhoy55J4Og@mail.gmail.com>
References: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
	<1329287109.2555.44.camel@edumazet-laptop>
	<CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
	<1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60898 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab2BORga convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 12:36:30 -0500
Received: by qadc10 with SMTP id c10so3349918qad.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 09:36:29 -0800 (PST)
In-Reply-To: <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I take the recvmsg( ... MSG_PEEK|MSG_TRUNC) *USUALLY* returns the
size of the next packet (which would solve my problem without any ugly
& deprecated ioctl) when passing a "too small buffer" but as you said
AF_UNIX sockets do not implement this behavior...

Are you proposing to implement such patch in the kernel to fix this?
Do you want me to test it?


Il 15 febbraio 2012 13:42, Eric Dumazet <eric.dumazet@gmail.com> ha scr=
itto:
> Le mercredi 15 f=E9vrier 2012 =E0 11:43 +0100, Piergiorgio Beruto a =E9=
crit :
>
>> Yes, there's nothing that "doesn't work", it's a matter of performan=
ce
>> (I am working on strong embedded so I'm quite concerned about both
>> memory usage and "speed").
>>
>> The problem is that when the socket queue is filled with short sized
>> packets, dequeue operation would allocate a lot of "big" chunks of
>> memory, progressively smaller (first one the size of the queue, seco=
nd
>> one =3D queue size - first packet size and so on).
>>
>> Besides the waste of memory, you get less perfromance as malloc()
>> would use the heap or mmap() depending on the size of the chunk
>> (usually 64 bytes) and =A0the use of mmap is more memory efficient b=
ut
>> quite slower.
>
> I see
>
>> Ok, that's why I asked :) But if you agree with my objection regardi=
ng
>> performance, what about adding a brand new (linux only) ioctl which
>> implements the other behaviour? So the code would look something lik=
e
>> this:
>>
>> case SIOCINQ:
>> case SIOCPSZ: =A0 =A0 //// new packet size ioctl
>> =A0 =A0 =A0 =A0{
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk->sk_state =3D=3D TCP_LISTEN) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EINVAL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&sk->sk_receive_queue.lock)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((sk->sk_type =3D=3D SOCK_STREAM |=
|
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_type =3D=3D SOCK_SEQPA=
CKET) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioctl_code !=3D SIOCPSZ) { =A0=
 =A0 =A0 //// have SIOCPSZ
>> behave as for datagram sockets
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_queue_walk(&sk->s=
k_receive_queue, skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0amoun=
t +=3D skb->len;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D skb_peek(&sk-=
>sk_receive_queue);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0amoun=
t =3D skb->len;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&sk->sk_receive_queue.loc=
k);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D put_user(amount, (int __user =
*)arg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> =A0 =A0 =A0 =A0}
>
> ioctl() are deprecated, and such a change has ramification (for examp=
le
> on strace tool)
>
> You could use a recvmsg( ... MSG_PEEK|MSG_TRUNC) to get size of next
> packet (passing a small buffer)
>
> Ah... it seems af_unix doesnt handle MSG_TRUNC semantic as
> UDP/RAW/NETLINK sockets do.
>
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 85d3bb7..70d9414 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1824,7 +1824,7 @@ static int unix_dgram_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (UNIXCB(skb).fp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0siocb->scm->fp =3D scm=
_fp_dup(UNIXCB(skb).fp);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 err =3D size;
> + =A0 =A0 =A0 err =3D (flags & MSG_TRUNC) ? skb->len : size;
>
> =A0 =A0 =A0 =A0scm_recv(sock, msg, siocb->scm, flags);
>
>
>
