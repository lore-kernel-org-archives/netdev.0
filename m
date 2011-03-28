From: Viral Mehta <Viral.Mehta@lntinfotech.com>
Subject: RE: zero copy for relay server
Date: Mon, 28 Mar 2011 23:48:31 +0530
Message-ID: <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>,<1301331138.3182.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.241.243]:2361 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309Ab1C1SSh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 14:18:37 -0400
In-Reply-To: <1301331138.3182.43.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From: Eric Dumazet [eric.dumazet@gmail.com]

>Le lundi 28 mars 2011 =E0 21:57 +0530, Viral Mehta a =E9crit :
>> Hi,
>> I am implementing a particular application where
>> my application acts nothing but like Relay Server.
>>
>> Relay server accepts connection from machine A.
>> It also accepts connection from Machine B.
>>
>> Machine A and B are on different LAN/subnnets.
>> Now, there are two connections.
>> What server is supposed to do is RECV packets from machine A and SEN=
D same
>> to machine B.
>>
>> Pseudo Code is something like,
>> while(1)
>> {
>> recvagain:
>>    n =3D3D recv(incoming_fd, &buf, 8192, ...)
>>    if(n < 0)
>>         goto recvagain;
>>    send(outgoing_fd, &buf, n, ...);
>> }
>>
>> Now the question is,
>> I want to avoid kernel-user copy for such application.
>> I found that a syscall like "sendfile"; I wanted to know if there is=
 any
>> similar thing exists in-kernel which can take 2 socket descriptors..=
=2E.
>>
>> If not, is it possible ? I would like to implement the same if someo=
ne
>> can suggest some pointers.

>linux way (if you want to avoid netfilter stuff and use userland code)
>is to use splice() system call, and a pipe between two sockets.

Yes, I want to avoid netfilter stuff.
I know it but I think it is more complicated than an application progra=
mmer should know.

>/* skeleton : must add error checking to exit the loop properly */
>int fds[2];
>pipe(fds);
>
>while (1) {
>        splice(incoming_fd, NULL, fds[1], NULL, 65536, 0);
>        splice(fds[0], NULL, outgoing_fd, NULL, 65536, 0);
>}

Still, these are two system calls.
In addition to this, many things to handle,
1. if the incoming_fd is blocking, then it will block till 64K data rea=
d. Why so ?
2. I believe underlying PIPE that we are using will also have some size=
 limit
    (like in user space 4K or 64K, not sure)

So, all in all
Why cant we have just one system call which really transfers "length"
bytes of data form one socket to another ? Recv "length" bytes of data
from socket A and send to socket B.

I wanted to understand if there are any limitations or concerns that we=
 still do
not have any such system call .... ?

>This way, messages dont cross kernel<>user boundary.

>The pipe is acting as a buffer between the two sockets.




______________________________________________________________________

The contents of this e-mail and any attachment(s) may contain confident=
ial or privileged information for the intended recipient(s). Unintended=
 recipients are prohibited from taking action on the basis of informati=
on in this e-mail and  using or disseminating the information,  and mus=
t notify the sender and delete it from their system. L&T Infotech will =
not accept responsibility or liability for the accuracy or completeness=
 of, or the presence of any virus or disabling code in this e-mail"

______________________________________________________________________
