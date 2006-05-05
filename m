From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [x86_64, NET] smp_rmb() in dst_destroy() seems very expensive, ditto
 in kfree_skb()
Date: Fri, 05 May 2006 10:49:39 +0200
Message-ID: <445B11A3.1020407@cosmosbay.com>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>	<4459574D.6000303@candelatech.com>	<cbec11ac0605031859n5ef0babcib5f970da1ced7df7@mail.gmail.com> <20060504.162546.88959729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.wanadoo.fr ([193.252.22.28]:53405 "EHLO smtp3.wanadoo.fr")
	by vger.kernel.org with ESMTP id S1030341AbWEEItp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 04:49:45 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf0302.wanadoo.fr (SMTP Server) with ESMTP id 22E761C00B25
	for <netdev@vger.kernel.org>; Fri,  5 May 2006 10:49:44 +0200 (CEST)
To: "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>
In-Reply-To: <20060504.162546.88959729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a dual opteron box, I noticed high oprofile numbers in net/core/dst.c 
, function dst_destroy(struct dst_entry * dst)

It appears the smb_rmb() done at the begining of  dst_destroy() is the 
killer  (this is a lfence machine instruction, that apparently is doing 
a *lot* of things... may be IO related...) that is responsible for 80% 
of the cpu time used by the whole function.

I dont understand very much all variety of available barriers, and why 
this smb_rmb() is used in dst_destroy().
I missed the corresponding wmb that should be done somewhere in the dst 
code.

Do we have an alternative to smp_rmb() in the dst_destroy()/ kfree_skb()
context ?

Documentation/memory-barriers.txt mentions several 'advanced barrier 
functions' but I'm really lost.




ffffffff803b5f80 <dst_destroy>: /* dst_destroy total: 237528  0.5635 */
   163 3.9e-04 :ffffffff803b5f80:       push   %r12
  3483  0.0083 :ffffffff803b5f82:       push   %rbp
               :ffffffff803b5f83:       mov    %rdi,%rbp
     7 1.7e-05 :ffffffff803b5f86:       push   %rbx
   201 4.8e-04 :ffffffff803b5f87:       lfence
192133  0.4558 :ffffffff803b5f8a:       data16
               :ffffffff803b5f8b:       data16
               :ffffffff803b5f8c:       nop
     4 9.5e-06 :ffffffff803b5f8d:       data16
               :ffffffff803b5f8e:       data16
               :ffffffff803b5f8f:       nop
               :ffffffff803b5f90:       mov    0x90(%rbp),%rdi



ffffffff803ae8a0 <kfree_skb>: /* kfree_skb total: 145240  0.3446 */
  1873  0.0044 :ffffffff803ae8a0:       test   %rdi,%rdi
  2127  0.0050 :ffffffff803ae8a3:       je     ffffffff803ae8c7 
<kfree_skb+0x27>
    81 1.9e-04 :ffffffff803ae8a5:       mov    0xbc(%rdi),%eax
     1 2.4e-06 :ffffffff803ae8ab:       dec    %eax
  2303  0.0055 :ffffffff803ae8ad:       jne    ffffffff803ae8b4 
<kfree_skb+0x14>
   221 5.2e-04 :ffffffff803ae8af:       lfence
137609  0.3265 :ffffffff803ae8b2:       jmp    ffffffff803ae8c2 
<kfree_skb+0x22>
               :ffffffff803ae8b4:       lock decl 0xbc(%rdi)
    38 9.0e-05 :ffffffff803ae8bb:       sete   %al
    86 2.0e-04 :ffffffff803ae8be:       test   %al,%al
               :ffffffff803ae8c0:       je     ffffffff803ae8c7 
<kfree_skb+0x27>
   806  0.0019 :ffffffff803ae8c2:       jmpq   ffffffff803ae7d0 
<__kfree_skb>
    95 2.3e-04 :ffffffff803ae8c7:       repz retq

Thank you

Eric




