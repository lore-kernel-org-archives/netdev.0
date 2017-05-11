From: David Miller <davem@davemloft.net>
Subject: BPF relocations
Date: Thu, 11 May 2017 15:31:18 -0400 (EDT)
Message-ID: <20170511.153118.2082025756694634804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752210AbdEKTbU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 15:31:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I haven't done more work on bintuils BPF support because we
need to figure out exactly what to do with relocations.  So
I've been trying to spend time thinking about this.

As far as I can tell the 64-bit BPF relocation llvm uses
is used in two situations:

1) 64-bit relocations against data

2) 64-bit relocations against ldimm64 instructions

If this is true it's a very bad decision that has ramifications for us
right now.

One must always explicitly define relocations as being against data or
instruction fields.  You cannot use the same relocation for both kinds
of transformations, somehow trying to figure out what to do
"contextually".  That doesn't work.

Right now in binutils I gave this relocation with value "1" the name
R_BPF_DATA_64.  But it's not correct as explained above.

I'm using it as a data relocation so that dwarf2 information emitted
by llvm gets handled correctly by binutils.

The only real dependency upon relocation "1" being used against
instructions is the ELF parser that records the relocations against
MAP sections which get applied to ldimm64 instructions.

So I propose:

1) We define the set of relocations as follows:

  RELOC_NUMBER (R_BPF_NONE, 0)
  RELOC_NUMBER (R_BPF_OLD_64, 1)
  RELOC_NUMBER (R_BPF_INSN_64, 2)
  RELOC_NUMBER (R_BPF_INSN_32, 3)
  RELOC_NUMBER (R_BPF_INSN_16, 4)
  RELOC_NUMBER (R_BPF_WDISP16, 5)
  RELOC_NUMBER (R_BPF_DATA_8,  8)
  RELOC_NUMBER (R_BPF_DATA_16, 9)
  RELOC_NUMBER (R_BPF_DATA_32, 10)
  RELOC_NUMBER (R_BPF_DATA_64, 11)

2) LLVM is changed to have relocations:

	#define R_BPF_OLD_64_64	1  /* deprecated, do not use */
	#define R_BPF_INSN_64	2  /* 64-bit instruction relocation */
	#define R_BPF_64_32	10 /* 32-bit data relocation */
	#define R_BPF_DATA_64	11 /* 64-bit data relocation */

   and emit 64-bit relocations against instructions and data using
   R_BPF_INSN_64 and R_BPF_DATA_64, respectively.  Keep the llvm code
   around for interpreting R_BPF_OLD_64_64 so that interaction with
   older binaries keeps working.

3) The existing loaders should continue to function properly, and with
   suitable changes alongside the list in #1 to binutils it will still
   properly read dwarf2 information in both old and new binaries.

4) Add explicit relocation number checks to the ELF loaders, they
   should accept both "1" and "2" for MAP relocations against ldimm64

Comments?
