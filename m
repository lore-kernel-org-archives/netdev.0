From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v2 net] bpf: do not use reciprocal divide
Date: Fri, 17 Jan 2014 09:59:16 +0100
Message-ID: <20140117085916.GA4208@osiris>
References: <1389795716.31367.333.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389795926.31367.334.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389797407.31367.340.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140115.170230.640619926492650356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, schwidefsky@de.ibm.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	dborkman@redhat.com, darkjames-ws@darkjames.pl, mgherzan@gmail.com,
	rmk+kernel@arm.linux.org.uk, matt@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39010 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbaAQI7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 03:59:21 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Fri, 17 Jan 2014 08:59:20 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3B45E1B08070
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 08:58:41 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0H8x5W063701036
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 08:59:06 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0H8xGkn029241
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 01:59:17 -0700
Content-Disposition: inline
In-Reply-To: <20140115.170230.640619926492650356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 05:02:30PM -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 15 Jan 2014 06:50:07 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > At first Jakub Zawadzki noticed that some divisions by reciprocal_divide
> > were not correct. (off by one in some cases)
> > http://www.wireshark.org/~darkjames/reciprocal-buggy.c
> > 
> > He could also show this with BPF:
> > http://www.wireshark.org/~darkjames/set-and-dump-filter-k-bug.c
> > 
> > The reciprocal divide in linux kernel is not generic enough,
> > lets remove its use in BPF, as it is not worth the pain with
> > current cpus.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
> 
> Applied and queued up for -stable, thanks Eric.

While thinking a bit more the s390 variant is still broken with special
casing the "divide with 1" case (see below).

Could you please also apply the patch below to your tree? It would only
generate a merge conflict, that would need fixing, if it would sit in the
s390 tree.

>From bf0f2dc84dd3774944fc4dddef8c7e699277aa96 Mon Sep 17 00:00:00 2001
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Fri, 17 Jan 2014 09:37:15 +0100
Subject: [PATCH] s390/bpf,jit: fix 32 bit divisions, use unsigned divide
 instructions

The s390 bpf jit compiler emits the signed divide instructions "dr" and "d"
for unsigned divisions.
This can cause problems: the dividend will be zero extended to a 64 bit value
and the divisor is the 32 bit signed value as specified A or X accumulator,
even though A and X are supposed to be treated as unsigned values.

The divide instrunctions will generate an exception if the result cannot be
expressed with a 32 bit signed value.
This is the case if e.g. the dividend is 0xffffffff and the divisor either 1
or also 0xffffffff (signed: -1).

To avoid all these issues simply use unsigned divide instructions.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index fc0fa77728e1..708d60e40066 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -368,16 +368,16 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		EMIT4_PCREL(0xa7840000, (jit->ret0_ip - jit->prg));
 		/* lhi %r4,0 */
 		EMIT4(0xa7480000);
-		/* dr %r4,%r12 */
-		EMIT2(0x1d4c);
+		/* dlr %r4,%r12 */
+		EMIT4(0xb997004c);
 		break;
 	case BPF_S_ALU_DIV_K: /* A /= K */
 		if (K == 1)
 			break;
 		/* lhi %r4,0 */
 		EMIT4(0xa7480000);
-		/* d %r4,<d(K)>(%r13) */
-		EMIT4_DISP(0x5d40d000, EMIT_CONST(K));
+		/* dl %r4,<d(K)>(%r13) */
+		EMIT6_DISP(0xe340d000, 0x0097, EMIT_CONST(K));
 		break;
 	case BPF_S_ALU_MOD_X: /* A %= X */
 		jit->seen |= SEEN_XREG | SEEN_RET0;
@@ -387,8 +387,8 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		EMIT4_PCREL(0xa7840000, (jit->ret0_ip - jit->prg));
 		/* lhi %r4,0 */
 		EMIT4(0xa7480000);
-		/* dr %r4,%r12 */
-		EMIT2(0x1d4c);
+		/* dlr %r4,%r12 */
+		EMIT4(0xb997004c);
 		/* lr %r5,%r4 */
 		EMIT2(0x1854);
 		break;
@@ -400,8 +400,8 @@ static int bpf_jit_insn(struct bpf_jit *jit, struct sock_filter *filter,
 		}
 		/* lhi %r4,0 */
 		EMIT4(0xa7480000);
-		/* d %r4,<d(K)>(%r13) */
-		EMIT4_DISP(0x5d40d000, EMIT_CONST(K));
+		/* dl %r4,<d(K)>(%r13) */
+		EMIT6_DISP(0xe340d000, 0x0097, EMIT_CONST(K));
 		/* lr %r5,%r4 */
 		EMIT2(0x1854);
 		break;
-- 
1.8.4.5
