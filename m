From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Wed, 14 May 2014 10:05:57 +0200
Message-ID: <20140514080557.GB9848@osiris>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
 <20140513.183145.1568789082256942703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, edumazet@google.com, hpa@zytor.com,
	dborkman@redhat.com, netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:39964 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127AbaENIGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 04:06:05 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Wed, 14 May 2014 09:06:04 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3A9611B08079
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 09:06:17 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4E862Bp524788
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 08:06:02 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4E85woa010333
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 02:06:02 -0600
Content-Disposition: inline
In-Reply-To: <20140513.183145.1568789082256942703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 06:31:45PM -0400, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue, 13 May 2014 15:05:55 -0700
> 
> > Fix it by making sure that &header->image[prandom_u32() % hole] and &header
> > are in the same page
> > 
> > Fixes: 314beb9bcabfd ("x86: bpf_jit_comp: secure bpf jit against spraying attacks")
> > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> Applied and queued up for -stable, thank you.

Ok, I didn't see that Alexei already sent a second version when asking
him to also fix s390.
Anyway, here is the s390 version of Alexei's fix which is nearly identical
to the x86 version.

Dave, can you route this via -net?

>From c4fce4d9777f1df9ca0ed503c485c3fd3db7d3ac Mon Sep 17 00:00:00 2001
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Wed, 14 May 2014 09:48:21 +0200
Subject: [PATCH] net: filter: s390: fix JIT address randomization

This is the s390 variant of Alexei's JIT bug fix.
(patch description below stolen from Alexei's patch)

bpf_alloc_binary() adds 128 bytes of room to JITed program image
and rounds it up to the nearest page size. If image size is close
to page size (like 4000), it is rounded to two pages:
round_up(4000 + 4 + 128) == 8192
then 'hole' is computed as 8192 - (4000 + 4) = 4188
If prandom_u32() % hole selects a number >= PAGE_SIZE - sizeof(*header)
then kernel will crash during bpf_jit_free():

kernel BUG at arch/x86/mm/pageattr.c:887!
Call Trace:
 [<ffffffff81037285>] change_page_attr_set_clr+0x135/0x460
 [<ffffffff81694cc0>] ? _raw_spin_unlock_irq+0x30/0x50
 [<ffffffff810378ff>] set_memory_rw+0x2f/0x40
 [<ffffffffa01a0d8d>] bpf_jit_free_deferred+0x2d/0x60
 [<ffffffff8106bf98>] process_one_work+0x1d8/0x6a0
 [<ffffffff8106bf38>] ? process_one_work+0x178/0x6a0
 [<ffffffff8106c90c>] worker_thread+0x11c/0x370

since bpf_jit_free() does:
  unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
  struct bpf_binary_header *header = (void *)addr;
to compute start address of 'bpf_binary_header'
and header->pages will pass junk to:
  set_memory_rw(addr, header->pages);

Fix it by making sure that &header->image[prandom_u32() % hole] and &header
are in the same page.

Fixes: aa2d2c73c21f2 ("s390/bpf,jit: address randomize and write protect jit code")

Reported-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: <stable@vger.kernel.org> # v3.11+
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 452d3ebd9d0f..e9f8fa9337fe 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -811,7 +811,7 @@ static struct bpf_binary_header *bpf_alloc_binary(unsigned int bpfsize,
 		return NULL;
 	memset(header, 0, sz);
 	header->pages = sz / PAGE_SIZE;
-	hole = sz - (bpfsize + sizeof(*header));
+	hole = min(sz - (bpfsize + sizeof(*header)), PAGE_SIZE - sizeof(*header));
 	/* Insert random number of illegal instructions before BPF code
 	 * and make sure the first instruction starts at an even address.
 	 */
-- 
1.8.5.5
