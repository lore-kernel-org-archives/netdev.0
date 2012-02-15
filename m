From: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Wed, 15 Feb 2012 11:43:35 +0100
Message-ID: <CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
References: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
	<1329287109.2555.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:50137 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab2BOKng convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 05:43:36 -0500
Received: by qafk1 with SMTP id k1so861725qaf.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 02:43:36 -0800 (PST)
In-Reply-To: <1329287109.2555.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 15 febbraio 2012 07:25, Eric Dumazet <eric.dumazet@gmail.com> ha scr=
itto:
> Le mardi 14 f=E9vrier 2012 =E0 23:05 +0100, Piergiorgio Beruto a =E9c=
rit :
>> Hello,
>> I would like to have your opinion regarding what I think could be a
>> misbehaviour of the SIOCINQ ioctl on AF_UNIX domain sockets.
>>
>> I was implementing an IPC user-space library which makes use of a
>> variety of sockets for sending data all around.
>> When dealing with datagram sockets (i.e. SOCK_DGRAM, SOCK_RDM and
>> SOCK_SEQPACKET) I used to implement the following paradigm:
>>
>> 1) issue the SIOCINQ (aka FIONREAD) ioctl and get the "size of the
>> first queued datagram"
>> 2) allocate memory of that size and fill it reading out data from th=
e socket
>>
>> This works very fine for UDP and TIPC (including SOCK_SEQPACKET)
>> sockets but when using AF_UNIX (SEQPACKET) sockets the same ioctl
>> returns instead the number of bytes queued (sum of all pending
>> datagrams) .
>>
>> In short, there is no way (as far as I know) to work out how much
>> memory to allocate in userspace before reading out the datagram.
>> The workaround for this is to use a fixed swap buffer of the max
>> possible size of your packets (assuming you know / can retrieve it
>> somehow) and make a copy of your data (which is bad for performance
>> anyway).
>>
>
> I dont understand.... SIOCINQ returns an upper limit to you.
Yes, there's nothing that "doesn't work", it's a matter of performance
(I am working on strong embedded so I'm quite concerned about both
memory usage and "speed").

The problem is that when the socket queue is filled with short sized
packets, dequeue operation would allocate a lot of "big" chunks of
memory, progressively smaller (first one the size of the queue, second
one =3D queue size - first packet size and so on).

Besides the waste of memory, you get less perfromance as malloc()
would use the heap or mmap() depending on the size of the chunk
(usually 64 bytes) and  the use of mmap is more memory efficient but
quite slower.

>
> So your app can malloc() a big enough buffer.
>
> Yes, SEQPACKET preserves message boundaries so your recvmsg() can fil=
l
> part of the application buffer.
>
>> Looking at the kernel code I've found this in the
>> linux/net/unix/af_unix.c file (my comment with ////)
>>
>> case SIOCINQ:
>> =A0 =A0 =A0 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_state =3D=3D TCP_LISTEN) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&sk->sk_receive_queue.lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_type =3D=3D SOCK_STREAM ||
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_type =3D=3D SOCK_SEQPACKE=
T) { =A0 =A0 =A0 =A0 =A0 //// <--------
>> treats SEQPACKET as SOCK_STREAM
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk(&sk->sk_r=
eceive_queue, skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 amount +=
=3D skb->len;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D skb_peek(&sk->sk=
_receive_queue);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 amount =3D=
 skb->len;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&sk->sk_receive_queue.lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D put_user(amount, (int __user *)a=
rg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>>
>> In my opinion SOCK_SEQPACKETS are similar to SOCK_STREAM because the=
y
>> are "connection oriented" sockets but from the I/O point of view are
>> more similar to datagram ones.
>>
>> My proposal is to remove the above condition from the test and let t=
he
>> function process SOCK_SEQPACKETS as if they were SOCK_DGRAM for this
>> particular ioctl.
>>
>
> This behavior is undocumented in "man unix", so it is "implementation
> dependant"
>
> This change could break some applications.
Ok, that's why I asked :) But if you agree with my objection regarding
performance, what about adding a brand new (linux only) ioctl which
implements the other behaviour? So the code would look something like
this:

case SIOCINQ:
case SIOCPSZ:     //// new packet size ioctl
       {
               struct sk_buff *skb;

               if (sk->sk_state =3D=3D TCP_LISTEN) {
                       err =3D -EINVAL;
                       break;
               }

               spin_lock(&sk->sk_receive_queue.lock);
               if ((sk->sk_type =3D=3D SOCK_STREAM ||
                   sk->sk_type =3D=3D SOCK_SEQPACKET) &&
                   ioctl_code !=3D SIOCPSZ) {       //// have SIOCPSZ
behave as for datagram sockets
                       skb_queue_walk(&sk->sk_receive_queue, skb)
                               amount +=3D skb->len;
               } else {
                       skb =3D skb_peek(&sk->sk_receive_queue);
                       if (skb)
                               amount =3D skb->len;
               }
               spin_unlock(&sk->sk_receive_queue.lock);
               err =3D put_user(amount, (int __user *)arg);
               break;
       }

Thank you again,
Piergiorgio
