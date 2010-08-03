From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 08:18:08 +0100
Message-ID: <20100803071807.GP11110@cel.leo>
References: <20100802110334.GK11110@cel.leo>
 <20100802201629.GA5973@nuttenaction>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AxgMqx9CFPETEpvO"
To: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:59008 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755305Ab0HCHSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 03:18:10 -0400
Content-Disposition: inline
In-Reply-To: <20100802201629.GA5973@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AxgMqx9CFPETEpvO
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 02, 2010 at 10:16:29PM +0200, Hagen Paul Pfeifer wrote:
> In general: BPF was constructed to address filters rules in a generic man=
ner
> and BPF does not contain any special protocol specific optimization - nor=
 any
> sophisticated connection tracking functionality. In general you should
> pre-filter unneeded packets and shift the real high level filtering to so=
me
> post-processing step. tcpdump filter capabilities are limited and where n=
ever
> designed to filter _any_ traffic. For example: you are lost if you want t=
o match
> transport layer fields like port number where the underlying IPv{4,6} pac=
ket
> is fragmented.

Oh, I am quite aware of the futility in trying to, for example, match up
IPv4 fragments.

There's nothing about my suggestion that is in any way IPv6-specific. I
used IPv6 simply as an example to motivate the suggestion. It could
quite easily apply to any other sort of protocol that uses a linked-list
of headers.

> Furthermore, I doubt that the loop provides any significant advantages.=
=20
> IPv6 extension header parsing is not that straight forward. For example=
=20
> check  the IPSec AH Extension header where the extension header length=20
> must interpreted differently because of a IPSec AH protcol defect. I assu=
me
> that a straight forward pcap encoded BPF opcode (composed of jump and load
> instructions) is more efficient as an highly flexible loop construct.=20

I'm not sure I follow your logic here.

By my understanding, pcap's IPv6 header parsing filter is a 6-times
statically-unrolled loop, where each loop body has to parse some
headers. I'm already aware that various headers are hard to parse.

Allow me some pseudocode... Currently, pcap has to do the equivalent of:

X =3D 0
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
X +=3D A
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
X +=3D A
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
X +=3D A
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
X +=3D A
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
X +=3D A
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
X +=3D A
got:
  ... continue with filter.

That "load A with its length" is the IPv6-specific part; I'm not
suggesting that my LOOP suggestion in any way helps that. It's a
difficult problem, sure. What I _am_ suggesting is that this static
unrolling can be avoided, instead becoming:

X =3D 0
start:
Look at header at [X]; if it's what we want goto 'got'; else load A with
its length.
LOOP to start
got:
  ... continue with filter.

This results also in a shorter program, because there is a hard limit on
the total number of instructions in a filter.

> Last but not least I am interested in a RFC patch as well as a pcap patch=
 (see
> pcap-opt.c). You should not underrate the effort to generate an generic I=
Pv6
> extension header opcode optimizer - without this the newly introduced opc=
ode
> is pointless.

As above; I was under the impression that pcap already -does- contain
code to have a reasonable attempt to hunt down the requested IPv6
header, which is what implements "ipv6 protochain". I'll quote from
pcap-filter(7):

       ip6 protochain protocol
              True  if the packet is IPv6 packet, and contains protocol hea=
der
              with type protocol in its protocol header chain.  For example,
                   ip6 protochain 6
              matches any IPv6 packet with TCP protocol header in the proto=
col
              header  chain.  The packet may contain, for example, authenti=
ca=E2=80=90
              tion  header,  routing  header,  or  hop-by-hop  option  head=
er,
              between  IPv6  header  and  TCP header.  The BPF code emitted=
 by
              this primitive is complex and cannot be  optimized  by  the  =
BPF
              optimizer code, so this can be somewhat slow.


> PS: the LOOP opcode must be secure against any ressource attack -> the lo=
op
> must be break after n iterations.

Which is -exactly- what it does. I'll quote my original:

       X +=3D A.
       If X < len, jump backwards jt instructions.
       Otherwise, fallthrough to the next instruction
  ...
  The intention of this instruction is to be able to implement a loop in
  which successive iterations advance the index register along the packet
  buffer. By comparing X to the packet length, we can bound the running
  time of the loop instruction, avoiding it locking up the kernel. By
  banning STX instructions within the body of the loop, we can ensure that
  X must be a strictly monotonically increasing sequence. At absolute
  worst, X is increased by 1 each time, meaning at worst the body of the
  loop must execute for every byte in the packet.

Is this sufficiently secure, or do you suggest a further limit is
required?

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--AxgMqx9CFPETEpvO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMV8KvvLS2TC8cBo0RAkxtAJ9WwK3FqNvT2ygcR9lKbSVonFg2VwCeJIcT
HWcOeNy+1q7+1T8QbMDGjtE=
=AM5y
-----END PGP SIGNATURE-----

--AxgMqx9CFPETEpvO--
