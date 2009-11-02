From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Mon, 02 Nov 2009 18:42:02 +0100
Message-ID: <4AEF19EA.6020003@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AEEB6D2.7090505@gmail.com> <4AEEBAC6.7020308@gmail.com> <4AEED23A.7070009@gmail.com> <4AEEDBBC.40800@gmail.com> <4AEF1534.4090506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756430AbZKBRmC@vger.kernel.org>
In-Reply-To: <4AEF1534.4090506@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>> Large part of network code is run by softirq handler, and a softirq
>> handler
>> is not preemptable with another softirq (including itself).
>>
> Thank you.  That's helpful to know, as some existing locks have a "bh=
".
> I've never figured out the ip_local_deliver_finish() context.
>=20
> Knowing that there can only be one instance of the tcp stack running =
at
> any one time, and the cpu never changes even after being interrupted,=
 will
> make it much easier to code.

Correction :

There is one instance of sofirq handler running per cpu.

So TCP (or UDP) stack can run simultaneously on several (and eventually=
 all online) cpus.

This is why we still need some locks in various places.


>>
> (No, I've not yet added locks; obviously, I'm still asking about them=
=2E)
>=20
> Unlikely, as it was easy to reproduce by changing one line, without
> *any* of
> my code present.  Usually works, but doesn't work with tcpdump runnin=
g on
> the interface:

Yes, tcpdump has the nasty habit to consume a lot of ram, queuing a cop=
y of
all network traffic on an af_packet socket. (or using a mmap buffer, it=
 depends
on libpcap version you use)

>=20
>  struct sock *tcp_create_openreq_child(struct sock *sk, struct
> request_sock *req, struct sk_buff *skb)
>  {
> -    struct sock *newsk =3D inet_csk_clone(sk, req, GFP_ATOMIC);
> +    struct sock *newsk =3D inet_csk_clone(sk, req, GFP_KERNEL);

Here you want a GFP_KERNEL allocation, that is allowed to sleep if ther=
e is not
enough available memory. (It's allowed to sleep to let some processes t=
o free
bit of ram, eventually)

But as the caller of tcp_create_openreq_child() runs from {soft}irq con=
text,
its not allowed to sleep at all, even 10 usecs.

Therefore, linux kernel kindly warns you that's its illegal and deadloc=
kable.

Dont change GFP_ATOMIC here, its really there for a valid reason.
And be prepared to get a NULL result from allocation.

If your machine has problems when running tcpdump, maybe it lacks some =
ram, maybe you could
tune tcpdump socket to not exhaust all LOWMEM.
I see your kernel is 32bits, so you have only 860 MB of kernel memory, =
called LOWMEM.
I believe last kernels might have some problems in OOM situations...=20
