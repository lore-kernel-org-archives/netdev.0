From: "'Naveen N. Rao'" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit
 endian operations
Date: Tue, 24 Jan 2017 00:52:27 +0530
Message-ID: <20170123192227.GE3820@naverao1-tp.localdomain>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
 <20170113175201.GD3470@naverao1-tp.localdomain>
 <1484492458.11927.17.camel@au1.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        Madhavan Srinivasan <maddy@linux.vnet.ibm.com>,
        Michael Ellerman <mpe@ellerman.id.au>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42441 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751280AbdAWTXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:23:25 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0NJIhtK064433
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 14:23:23 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
        by mx0a-001b2d01.pphosted.com with ESMTP id 285gpum4ww-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 14:23:23 -0500
Received: from localhost
        by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Tue, 24 Jan 2017 05:23:20 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
        by d23dlp02.au.ibm.com (Postfix) with ESMTP id B52522BB0057
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 06:23:18 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0NJNAbf18022584
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 06:23:18 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0NJMjW3022236
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 06:22:46 +1100
Content-Disposition: inline
In-Reply-To: <1484492458.11927.17.camel@au1.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/01/15 09:00AM, Benjamin Herrenschmidt wrote:
> On Fri, 2017-01-13 at 23:22 +0530, 'Naveen N. Rao' wrote:
> > > That rather depends on whether the processor has a store to load forwarder
> > > that will satisfy the read from the store buffer.
> > > I don't know about ppc, but at least some x86 will do that.
> > 
> > Interesting - good to know that.
> > 
> > However, I don't think powerpc does that and in-register swap is likely 
> > faster regardless. Note also that gcc prefers this form at higher 
> > optimization levels.
> 
> Of course powerpc has a load-store forwarder these days, however, I
> wouldn't be surprised if the in-register form was still faster on some
> implementations, but this needs to be tested.

Thanks for clarifying! To test this, I wrote a simple (perhaps naive) 
test that just issues a whole lot of endian swaps and in _that_ test, it 
does look like the load-store forwarder is doing pretty well.

The tests:

bpf-bswap.S:
-----------
	.file   "bpf-bswap.S"
        .abiversion 2
        .section        ".text"
        .align 2
        .globl main
        .type   main, @function
main:
        mflr    0
        std     0,16(1)
        stdu    1,-32760(1)
	addi	3,1,32
	li	4,0
	li	5,32720
	li	11,32720
	mulli	11,11,8
	li	10,0
	li	7,16
1:	ldx	6,3,4
	stdx	6,1,7
	ldbrx	6,1,7
	stdx	6,3,4
	addi	4,4,8
	cmpd	4,5
	beq	2f
	b	1b
2:	addi	10,10,1
	li	4,0
	cmpd	10,11
	beq	3f
	b	1b
3:	li	3,0
        addi	1,1,32760
        ld      0,16(1)
	mtlr	0
	blr

bpf-bswap-reg.S:
---------------
	.file   "bpf-bswap-reg.S"
        .abiversion 2
        .section        ".text"
        .align 2
        .globl main
        .type   main, @function
main:
        mflr    0
        std     0,16(1)
        stdu    1,-32760(1)
	addi	3,1,32
	li	4,0
	li	5,32720
	li	11,32720
	mulli	11,11,8
	li	10,0
1:	ldx	6,3,4
	rldicl	7,6,32,32
	rlwinm	8,6,24,0,31
	rlwimi	8,6,8,8,15
	rlwinm	9,7,24,0,31
	rlwimi	8,6,8,24,31
	rlwimi	9,7,8,8,15
	rlwimi	9,7,8,24,31
	rldicr	8,8,32,31
	or	6,8,9
	stdx	6,3,4
	addi	4,4,8
	cmpd	4,5
	beq	2f
	b	1b
2:	addi	10,10,1
	li	4,0
	cmpd	10,11
	beq	3f
	b	1b
3:	li	3,0
        addi	1,1,32760
        ld      0,16(1)
	mtlr	0
	blr

Profiling the two variants:

# perf stat ./bpf-bswap

 Performance counter stats for './bpf-bswap':

       1395.979224      task-clock (msec)         #    0.999 CPUs utilized          
                 0      context-switches          #    0.000 K/sec                  
                 0      cpu-migrations            #    0.000 K/sec                  
                45      page-faults               #    0.032 K/sec                  
     4,651,874,673      cycles                    #    3.332 GHz                      (66.87%)
         3,141,186      stalled-cycles-frontend   #    0.07% frontend cycles idle     (50.57%)
     1,117,289,485      stalled-cycles-backend    #   24.02% backend cycles idle      (50.57%)
     8,565,963,861      instructions              #    1.84  insn per cycle         
                                                  #    0.13  stalled cycles per insn  (67.05%)
     2,174,029,771      branches                  # 1557.351 M/sec                    (49.69%)
           262,656      branch-misses             #    0.01% of all branches          (50.05%)

       1.396893189 seconds time elapsed

# perf stat ./bpf-bswap-reg

 Performance counter stats for './bpf-bswap-reg':

       1819.758102      task-clock (msec)         #    0.999 CPUs utilized          
                 3      context-switches          #    0.002 K/sec                  
                 0      cpu-migrations            #    0.000 K/sec                  
                44      page-faults               #    0.024 K/sec                  
     6,034,777,602      cycles                    #    3.316 GHz                      (66.83%)
         2,010,983      stalled-cycles-frontend   #    0.03% frontend cycles idle     (50.47%)
     1,024,975,759      stalled-cycles-backend    #   16.98% backend cycles idle      (50.52%)
    16,043,732,849      instructions              #    2.66  insn per cycle         
                                                  #    0.06  stalled cycles per insn  (67.01%)
     2,148,710,750      branches                  # 1180.767 M/sec                    (49.57%)
           268,046      branch-misses             #    0.01% of all branches          (49.52%)

       1.821501345 seconds time elapsed


This is all in a POWER8 vm. On POWER7, the in-register variant is around 
4 times faster than the ldbrx variant.

So, yes, unless I've missed something, the ldbrx variant seems to 
perform better, if not on par with the in-register swap variant on 
POWER8.

> 
> Ideally, you'd want to try to "optimize" load+swap or swap+store
> though.

Agreed. This is already the case with BPF for packet access - those use 
skb helpers which issue the appropriate lhbrx/lwbrx/ldbrx. The newer 
BPF_FROM_LE/BPF_FROM_BE are for endian operations with other BPF 
programs.

We can probably implement an extra pass to detect use of endian swap and 
try to match it up with a previous load or a subsequent store though...

Thanks!
- Naveen
