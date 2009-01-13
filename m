From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Wed, 14 Jan 2009 00:15:04 +0100
Message-ID: <496D2078.9080302@cosmosbay.com>
References: <E1LKrp3-004Tub-IR@intern.SerNet.DE> <20090113123702.ad29cd13.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Volker.Lendecke@SerNet.DE, linux-kernel@vger.kernel.org,
	Steven French <sfrench@us.ibm.com>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46468 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbZAMXP5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:15:57 -0500
In-Reply-To: <20090113123702.ad29cd13.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton a =E9crit :
> (cc's added)
>=20
> On Thu, 8 Jan 2009 11:13:51 +0100
> Volker Lendecke <Volker.Lendecke@SerNet.DE> wrote:
>=20
>> Hi!
>>
>> While implementing splice support in Samba for better
>> performance I found it blocking when trying to pull data off
>> tcp into a pipe when the recvq was full. Attached find a
>> test program that shows this behaviour, on another host I
>> started
>>
>> netcat 192.168.19.10 4711 < /dev/zero
>>
>> vlendec@lenny:~$ uname -a
>> Linux lenny 2.6.28-06857-g5cbd04a #7 Wed Jan 7 10:10:42 CET 2009 x86=
_64 =3D GNU/Linux
>> vlendec@lenny:~$ gcc -o splicetest /host/home/vlendec/splicetest.c -=
O3 -Wall
>> vlendec@lenny:~$ ./splicetest out 65536 &
>> [1] 697
>> vlendec@lenny:~$ strace -p 697
>> Process 697 attached - interrupt to quit
>> splice(0x3, 0, 0x5, 0, 0x56a0, 0x1)     =3D 22176
>> splice(0x7, 0, 0x4, 0, 0x10000, 0x1^C <unfinished ...>

Volker, your splice() is a blocking one, from tcp socket to a pipe ?

If no other thread is reading the pipe, then you might block forever
in splice_to_pipe() as soon pipe is full (16 pages).

As pages are not necessarly full (each skb will use at least one page, =
even if=20
its length is small), it is not really possible to use splice() like th=
is.

In your case, only safe way with current kernel would be to call splice=
()
asking for no more than 16 bytes, that would be really insane for your =
needs.

You may prefer a non blocking mode, at least when calling splice_to_pip=
e()

Maybe SPLICE_F_NONBLOCK splice() flag should only apply on pipe side.
tcp_splice_read() should not use this flag to select a blocking/nonblok=
ing
mode on the source socket, but underlying file flag.

This way, your program could let socket in blocking mode, yet call spli=
ce()
with SPLICE_F_NONBLOCK flag to not block on pipe.


