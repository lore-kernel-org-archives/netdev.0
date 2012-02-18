From: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Sat, 18 Feb 2012 22:23:39 +0100
Message-ID: <CAFJW8X8GzyLCH+ybUcMn7ugB1fkn0pYb53Di6yJDQEH7Cdo-Sw@mail.gmail.com>
References: <1329287109.2555.44.camel@edumazet-laptop>
	<CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
	<1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120215.145511.1269077904303781879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:64533 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab2BRVXl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2012 16:23:41 -0500
Received: by qafk1 with SMTP id k1so4741343qaf.19
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2012 13:23:39 -0800 (PST)
In-Reply-To: <20120215.145511.1269077904303781879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I've tested the patch on my Linux box running kernel 3.2.6 and rich of
userspace apps and everything seems to work fine.

Then I used the following test program to verify the patch effects:

// ---------------------------------------------------

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/un.h>
#include <stdio.h>
#include <errno.h>

int main()
{
   int sv[2];
   if(socketpair(AF_UNIX, SOCK_SEQPACKET, 0, sv) !=3D 0)
   {
      printf("socketpair() error %d\n", errno);
      return 1;
   }

   // write two messages of size 3 and 2
   const char msg[] =3D "abc";
   send(sv[1], msg, 2, 0);
   send(sv[1], msg, 3, 0);

   int sz =3D 0;
   if(ioctl(sv[0], FIONREAD, &sz) !=3D 0)
   {
      printf("ioctl() error %d\n", errno);
      return 1;
   }

   printf("ioctl(SIOCINQ) returned %d\n", sz);

   char dummy;
   sz =3D recv(sv[0], &dummy, 0, MSG_PEEK | MSG_TRUNC);
   printf("recv(MSG_TRUNC) returned %d\n", sz);

   return 0;
}

// ----------------------------------------------------------

the output of this program with the patched kernel is, as expected:
ioctl(SIOCINQ) returned 5
recv(MSG_TRUNC) returned 2

which validates the test.

=46urthermore, I found this in the man page of recv:

MSG_TRUNC (since Linux 2.2)
              For raw (AF_PACKET), Internet datagram (since Linux
2.4.27/2.6.8), and netlink (since Linux 2.6.22) sockets: return
              the  real  length  of  the packet or datagram, even when
it was longer than the passed buffer.  Not implemented for
              UNIX domain (unix(7)) sockets.

The "not implemented for unix domain sockets" sounds to me such as no
userland applications should have used this flag, but I wonder why it
was not implemented since kernel 2.2 (?)

Thank you again,
Regards,

Piergiorgio


Il 15 febbraio 2012 20:55, David Miller <davem@davemloft.net> ha scritt=
o:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 15 Feb 2012 13:42:07 +0100
>
>> @@ -1824,7 +1824,7 @@ static int unix_dgram_recvmsg(struct kiocb *io=
cb, struct socket *sock,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (UNIXCB(skb).fp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siocb->scm->fp =3D scm_f=
p_dup(UNIXCB(skb).fp);
>> =A0 =A0 =A0 }
>> - =A0 =A0 err =3D size;
>> + =A0 =A0 err =3D (flags & MSG_TRUNC) ? skb->len : size;
>>
>> =A0 =A0 =A0 scm_recv(sock, msg, siocb->scm, flags);
>
> I'm ok with this, but if it is found to break even one userland appli=
cation
> I'm reverting with impunity.
