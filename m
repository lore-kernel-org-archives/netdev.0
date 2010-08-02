From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: RFC: New BGF 'LOOP' instruction
Date: Mon, 2 Aug 2010 12:03:34 +0100
Message-ID: <20100802110334.GK11110@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Udr3zdleqapns69J"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:54215 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751847Ab0HBLLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 07:11:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Udr3zdleqapns69J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

---
 Proposal: Create a new BPF instruction, "LOOP", which can implement a
   specific time-bounded kind of while() loop over packet contents
---

IPv6 packets contain a linked-list of headers. Some other network
protocols may also contain linked-list structure.

BPF cannot implement loops.

Currently therefore, it is impossible to efficiently parse IPv6 packets
without resorting to such annoying tricks as statically unrolling a loop
into a long list of instructions. In IPv6's case this gets very large
very quickly, as different header types have different lengths, or
structure layouts.

I propose to add a new instruction, "LOOP", with the following
semantics:

 BPF_JMP|BPF_LOOP, jt

    If A =3D=3D 0, fallthrough to the next instruction.
      (TODO: Or perhaps this should be considered a hard error which
       immediately aborts the filter, similar to divide by zero?)
    Otherwise:
       X +=3D A.
       If X < len, jump backwards jt instructions.
       Otherwise, fallthrough to the next instruction

The following static checks would be enforced:

 None of the 'jt' preceeding instructions before the LOOP instruction
 (i.e. the body of the loop) may themselves be LOOP instructions, nor may
 they be STX.

The intention of this instruction is to be able to implement a loop in
which successive iterations advance the index register along the packet
buffer. By comparing X to the packet length, we can bound the running
time of the loop instruction, avoiding it locking up the kernel. By
banning STX instructions within the body of the loop, we can ensure that
X must be a strictly monotonically increasing sequence. At absolute
worst, X is increased by 1 each time, meaning at worst the body of the
loop must execute for every byte in the packet. By banning further
nested LOOP instructions, we can ensure at worst a linear running time.


I believe this addition should have minimal impact on existing users of
the filter layer, as it simply adds a new instruction and does not
otherwise change the semantics of any existing code. I also believe it
to be useful in writing filters that process IPv6 packets. I also
believe that the semantics and static checks are sufficient to preserve
the termination guarantee of BPF filter programs, ensuring each packet's
fate is decided in a timely fashion to avoid locking up the kernel.

Any comments on this, while I proceed? Barring any major complaints,
I'll have a hack at some code and present a patch in due course...

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--Udr3zdleqapns69J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMVqYGvLS2TC8cBo0RAt6bAKCPLAMv//k52AinugJNH4giL0zcUQCg8aVx
KuDPU8Tpkt614csEMsza6wg=
=dqWx
-----END PGP SIGNATURE-----

--Udr3zdleqapns69J--
