From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix ppro csum_partial for 1 byte unaligned buffers
Date: Wed, 1 Oct 2003 14:12:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001121226.GA11676@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


When using sendfile it can happen that csum_partial is called for memory
areas that are not aligned to a 2 byte boundary. The ppro optimized i386
checksum code handled this slowly, but read upto 3 bytes over the end of the 
buffer. When the skb contents are mapped from highmem this can be fatal
because the end of the buffer can be unmapped.

This patch fixes this in a simple non intrusive way by handling the 
possible fault and recovering from it by using a tolerant byte-by-byte copy.
It does not attempt to align one byte unaligned buffers, because that's 
rather complicated and probably not worth the effort.

Other architectures may want to audit their csum_partial if it handles
this case correctly.

Bug is in 2.4 and 2.6

-Andi

diff -u linux/arch/i386/lib/checksum.S-o linux/arch/i386/lib/checksum.S
--- linux/arch/i386/lib/checksum.S-o	2003-03-07 16:48:01.000000000 +0100
+++ linux/arch/i386/lib/checksum.S	2003-10-01 14:01:31.000000000 +0200
@@ -48,6 +48,9 @@
 	   * least a twofold speedup on 486 and Pentium if it is 4-byte aligned.
 	   * Fortunately, it is easy to convert 2-byte alignment to 4-byte
 	   * alignment for the unrolled loop.
+	   *
+	   * Danger, Will Robinson: with sendfile 2 byte alignment is not guaranteed.
+	   *
 	   */		
 csum_partial:	
 	pushl %esi
@@ -237,18 +240,37 @@
 	movl $0xffffff,%ebx	# by the shll and shrl instructions
 	shll $3,%ecx
 	shrl %cl,%ebx
-	andl -128(%esi),%ebx	# esi is 4-aligned so should be ok
+.Ltail:	
+	andl -128(%esi),%ebx
+.Ttail_finished	
 	addl %ebx,%eax
 	adcl $0,%eax
 80: 
 	testl $1, 12(%esp)
 	jz 90f
 	roll $8, %eax
-90: 
+90:  
 	popl %ebx
 	popl %esi
 	ret
-				
+	
+	.section __ex_table,"a"
+	.long .Ltail,tail_recover
+	.long .Ltail_byte3,.Ltail_byte1
+	.long .Ltail_byte2,.Ltail_finished
+	.previous
+		
+tail_recover:	
+	xorl %ebx,%ebx
+.Ltail_byte3:	
+	movb -126(%esi),%bl
+	shl  $16,%ebx
+.Ltail_byte1:			
+	movb -128(%esi),%bl
+.Ltail_byte2:	
+	movb -127(%esi),%bh
+	jmp .Ltailfinished
+					
 #endif
 
 /*




 
