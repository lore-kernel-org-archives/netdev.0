From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/9] nfp: bpf: stack support in offload
Date: Mon, 23 Oct 2017 11:58:05 -0700
Message-ID: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:46212 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdJWS6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:25 -0400
Received: by mail-pg0-f41.google.com with SMTP id k7so12490515pga.3
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series brings stack support for offload.

We use the LMEM (Local memory) register file as memory to store
the stack.  Since this is a register file we need to do appropriate
shifts on unaligned accesses.  Verifier's state tracking helps us
with that.

LMEM can't be accessed directly, so we add support for setting
pointer registers through which one can read/write LMEM.

This set does not support accessing the stack when the alignment 
is not known.  This can be added later (most likely using the byte_align 
instructions).  There is also a number of optimizations which have been
left out:
 - in more complex non aligned accesses, double shift and rotation
   can save us a cycle.  This, however, leads to code explosion 
   since all access sizes have to be coded separately;
 - since setting LM pointers costs around 5 cycles, we should be
   tracking their values to make sure we don't move them when
   they're already set correctly for earlier access;
 - in case of 8 byte access aligned to 4 bytes and crossing 
   32 byte boundary but not crossing a 64 byte boundary we don't
   have to increment the pointer, but this seems like a pretty
   rare case to justify the added complexity.


Jakub Kicinski (9):
  nfp: bpf: add helper for emitting nops
  nfp: bpf: refactor nfp_bpf_check_ptr()
  nfp: bpf: add stack write support
  nfp: bpf: add stack read support
  nfp: bpf: optimize the RMW for stack accesses
  nfp: bpf: allow stack accesses via modified stack registers
  nfp: bpf: support accessing the stack beyond 64 bytes
  nfp: bpf: support stack accesses via non-constant pointers
  nfp: bpf: optimize mov64 a little

 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 357 +++++++++++++++++++++-
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |   8 +
 drivers/net/ethernet/netronome/nfp/bpf/offload.c  |   8 +
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c |  64 +++-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h      |   5 +
 5 files changed, 420 insertions(+), 22 deletions(-)

-- 
2.14.1
