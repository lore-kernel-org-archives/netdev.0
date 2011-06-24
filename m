From: Matt Evans <matt@ozlabs.org>
Subject: [RFC PATCH 0/1] BPF JIT for PPC64
Date: Fri, 24 Jun 2011 16:02:15 +1000
Message-ID: <4E042867.5020902@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59829 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab1FXGCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:02:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Inspired by Eric Dumazet's x86-64 compiler for Berkeley Packet Filter programs,
I've written a BPF compiler for 64-bit PowerPC.  Although it hasn't finished its
strenuous testing regime, I'll have intermittent net access for a couple of
weeks so thought I'd post it for feedback now and submit a 'proper' version when
I'm back.

It's a fairly simple code generator, following a similar structure to the x86
version.  The filter programs are an array of opcode/constant/branch destination
structs, and can perform arithmetic/logical/comparison operations on two virtual
registers A and X, loads from packet headers/data and accesses to local
variables, M[].  Branching is also supported, but only forwards and only within
the extent of the program.

I would probably describe this as more of a "static template binary translator"
than a "JIT" but have kept naming consistent :)


Features include:

- Filter code is generated as an ABI-compliant function, stackframe &
  prologue/epilogue if necessary.

- Simple filters (e.g. RET nn) need no stackframe or save/restore code so
  generate into only an li/blr.

- Local variables, M[], live in registers

- I believe this supports all BPF opcodes, although "complicated" loads from
  negative packet offsets (e.g. SKF_LL_OFF) are not yet supported.

Caveats include:  :)

- Packet data loads call out to simple helper functions (bpf_jit.S) which
  themselves may fall back to a trampoline to skb_copy_bits.  I haven't decided
  whether (as per comments there) it would be better to generate the simple
  loads inline and only call out in the slow case.

- Branches currently generate to "bcc 1f; b <far dest>; 1:" or
  "bcc <near dest> ; nop" so either case is the same size.  Multiple passes of
  assembly are used (the first gets an idea of how big everything is and what
  features are required), the next generates everything at accurate size, the
  third generates everything with accurate branch destination addresses); I
  intend not to nop-pad the short branch case but changing code size may
  result in more passes and a 'settling-down period'.  Kept simple for now.

- Anyone running PPC64 little-endian is doing something both interesting and
  unsupported for this work :-)  (There are some trivial endian assumptions.)

Tested in-situ (tcpdump with varying complexity filters) and with a random BPF
generator; I haven't verified loads from the fall back skb_copy_bits path.  Bug
reports/testing would be very welcome.



Cheers,



Matt
