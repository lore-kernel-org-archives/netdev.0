From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.14 regression: huge latency in read/select on tun
Date: Thu, 03 Apr 2014 06:19:36 -0700
Message-ID: <1396531176.12330.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <533C381E.9090103@odi.ch>
	 <1396456973.3989.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <533D133A.3090008@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ortwin =?ISO-8859-1?Q?Gl=FCck?= <odi@odi.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533D133A.3090008@odi.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-04-03 at 09:52 +0200, Ortwin Gl=C3=BCck wrote:
> On 02.04.2014 18:42, Eric Dumazet wrote:
> > You could post a tcpdump maybe ?
>=20
> This is a dump from on the tun interface (traffic inside the tunnel).
> It's an scp upload of a 2MB file. I aborted after a while when not mu=
ch
> progress was seen anymore, but you get the idea.
>=20
> What I see:
> - Frame 28: long delay because I had to enter the key password
> - Frame 31: the packets seems to be out of order. It has a sequence
> number that is far ahead of previously sent sequence no's. Some
> duplicates and retransmissions follow. That pattern repeats randomly =
all
> over the trace.
> - from Frame 73 on: ping pong of ACKs and data, while the data is
> delayed by ~200ms caused by the select(). The ping pong also shows th=
at
> there are virtually no packets in flight (see also Window size).

It seems TSO support is broken.

Your trace have no 'big' packets but holes like :

00:41:35.832695 IP 10.243.88.168.35846 > 10.185.85.69.22: Flags [.], ac=
k 6093, win 310, options [nop,nop,TS val 78054 ecr 3191538976], length =
0
00:41:35.855990 IP 10.243.88.168.35846 > 10.185.85.69.22: Flags [P.], s=
eq 6696:6776, ack 6093, win 310, options [nop,nop,TS val 78060 ecr 3191=
538976], length 80
00:41:36.047465 IP 10.185.85.69.22 > 10.243.88.168.35846: Flags [P.], s=
eq 6093:6141, ack 6776, win 218, options [nop,nop,TS val 3191539191 ecr=
 78060], length 48

missing 6776:14144 sequence (6 segments)

00:41:36.048766 IP 10.243.88.168.35846 > 10.185.85.69.22: Flags [.], se=
q 14144:15372, ack 6141, win 310, options [nop,nop,TS val 78108 ecr 319=
1539191], length 1228
00:41:36.057995 IP 10.185.85.69.22 > 10.243.88.168.35846: Flags [.], ac=
k 6776, win 218, options [nop,nop,TS val 3191539202 ecr 78060,nop,nop,s=
ack 1 {14144:15372}], length 0

You are 'saved' because retransmits do not use TSO :

00:41:36.058050 IP 10.243.88.168.35846 > 10.185.85.69.22: Flags [.], se=
q 6776:8004, ack 6141, win 310, options [nop,nop,TS val 78110 ecr 31915=
39202], length 1228
00:41:36.058070 IP 10.243.88.168.35846 > 10.185.85.69.22: Flags [.], se=
q 8004:9232, ack 6141, win 310, options [nop,nop,TS val 78110 ecr 31915=
39202], length 1228

Also receiver seems to be unable to open TCP window, but thats a second=
ary problem.
