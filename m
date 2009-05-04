From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 11:03:39 +0200
Message-ID: <49FEAF6B.5090308@cosmosbay.com>
References: <49FE47A1.7070700@uwaterloo.ca> <49FE9C8C.6090705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Elad Lahav <elahav@uwaterloo.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753926AbZEDJFc@vger.kernel.org>
In-Reply-To: <49FE9C8C.6090705@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Elad Lahav a =E9crit :
>> The attached patch contains an implementation of sendgroup(), a syst=
em
>> call that allows a UDP packet to be transmitted efficiently to multi=
ple
>> recipients. Use cases for this system call include live-streaming an=
d
>> multi-player online games.
>> The basic idea is that the caller maintains a group - a list of IP
>> addresses and UDP ports - and calls sendgroup() with the group list =
and
>> a common payload. Optionally, the call allows for per-recipient data=
 to
>> be prepended or appended to the shared block. The data is copied onc=
e in
>> the kernel into an allocated page, and the per-recipient socket buff=
ers
>> point to that page. Savings come from avoiding both the multiple cal=
ls
>> and the multiple copies of the data required with regular socket
>> operations. We have measured an improvement of 42% in CPU utilisatio=
n
>> when using this system call with the Helix multimedia server (refere=
nce:
>> http://simula.no/~griff/nossdav2008/27-32.pdf).
>>
>> The patch includes two implementations: one as described above and o=
ne
>> that uses the udp_sendmsg() function in a tight loop inside the kern=
el
>> (and thus saves on mode switches, but not on data copies). The latte=
r is
>> provided for reference and benchmarking only.
>>
>> Feedback is welcome.
>>
>=20
> Hi Elad
>=20
> Patch is not inlined, this is really asking for troubles, I doubt man=
y people
> will actually read your patch...
>=20
> My comments are :
>=20
> 1) Lack of latency checks. Sending UDP on 1000 destinations is expens=
ive.
>   A syscall is not preemptable unless special conditions are met.
>=20
> 2) Lack of a 32/64 bits aware API. A 64bit kernel should be able to=20
> run a 32bit application using a sendgroup() syscall.
>=20
> 3) Are footer/header differents for each calls ? Maybe you need
>   something better to avoid extra copies for them at each sendgroup()=
 systemcall
>=20
> 4) One expensive thing on UDP sends is the route cache lookups. You c=
ould avoid
> this cost using 'connected' group setup (see point 3)
> =20
> ie using a different syscall to setup the group (and compute/lookup a=
ll needed routes)
>   (this syscall would be able to add/delete members (with their foote=
r/header) to socket group)
>  =20
> Then sendgroup() would be really light, since it would provide a grou=
p identifier
> (can be a file descriptor -> mapping one group), and the UDP message =
to send.

Ah some other points : You forgot to include netdev  (CCed on my messag=
e),
as some network guys dont read lkml every day :)

On your experiments, did you change NIC txqueue length ? (default being=
 1000)
Using sendgroup() or sendmsg(), you'll hit pretty fast the NIC queue li=
mit anyway...

Also, since 2.6.25 added memory accounting on UDP sockets, you'll proba=
bly need to
increase SO_SNDBUF to avoid being blocked on sendmsg()/sendgroup() call
