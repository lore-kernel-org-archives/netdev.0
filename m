From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: ebpf: issue with clang
Date: Thu, 9 Jun 2016 17:34:18 -0700
Message-ID: <20160610003416.GA70641@ast-mbp.thefacebook.com>
References: <1465506605.23482.10.camel@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34023 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcFJAeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:34:24 -0400
Received: by mail-pf0-f193.google.com with SMTP id 66so1975823pfy.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:34:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1465506605.23482.10.camel@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2016 at 11:10:05PM +0200, Eric Leblond wrote:
> Hello,
>=20
> I'm working on integrating ebpf cluster load balancing for AF_PACKET
> and I've got some problem to get real code inside the EBPF filter.
>=20
> I've tried different command lines in the build process. One of them
> is:
> clang-3.9 -Wall -O2 -emit-llvm -c hash_ports.c -o - | llc-3.9 -march=3D=
bpf -filetype=3Dobj -o hash_ports.bpf
>=20
> If I use that one, then the generated code is almost void. If I remov=
e
> the -O2 then I've got a generated code that fails during load. When n=
ot
> using -O2, I manage to load a trivial filter (return of static value)=
=2E
> =A0
> The C code is the following (a derivative of http-simple-filter.c use=
d
> for testing):
>=20
> int filter(struct __sk_buff *skb) {
> 	uint8_t *cursor =3D 0;
> 	struct ethernet_t *ethernet =3D cursor_advance(cursor, sizeof(*ether=
net));

this is bcc C syntax that is hiding the explicit load_byte/half/word op=
erations
we have to do when using plain C.
If you want to compile C code with clang -O2 -target bpf file.c -c -o f=
ile.o
and copy .o around to be used in tc like:
tc filter add dev eth0 ingress bpf da obj file.o
then plain C should be used like in all samples/bpf/*_kern.c examples.
Other folks like the convenience of bcc that hides clang/llvm invocatio=
n.
It mostly applicable to tracing tools where both bcc-C and
corresponding python or lua bits are in the same file
like in iovisor/bcc/tools/* scripts.
The iovisor/bcc/examples/networking/* (where this http-simple-filter.c =
came from)
are also suitable for networking and relying on pyroute2 to talk to
kernel to create netns, veth and to attach bpf to qdisc.

In summary there are several ways to write bpf C code:
1. plain C syntax as in samples/bpf/*_kern.c
Pro: compiles with clang into .o
Con: .o requires elf loader (integrated into tc already for networking)=
,
but not friendly for tracing that needs recompile for every kernel
due to unstable kprobes
2. bcc C syntax that compiles C on the fly in memory and loads directly
Pro: there is no .o, no extra files, no need to install clang/llvm
Con: bcc is not widely available yet. ubuntu and others already have it=
 in apt.
python and lua may not be for everyone. c++ api is not stable yet.
3. perf+bpf, it is similar to samples/pbf/ C style with few extensions.
If .c file is passed, the perf calls external clang and loads .o eventu=
ally
Pro: out-of-the-box perf and clang work well
Con: not available for networking

Sounds like you want to use it with af_packet then
tools/testing/selftests/net/reuseport_bpf.c
could be a good start too, but there bpf is written in asm.

If you pick bcc style then iovisor-dev@lists.iovisor.org mailing list
is a good place to ask questions. Be sure to subscribe first, since
it rejects non-subscriber emails to reduce spam.
