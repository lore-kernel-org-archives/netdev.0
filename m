From: Mark Huth <mhuth@mvista.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 16:29:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA2F069.4070005@mvista.com>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>	<1067635446.11564.92.camel@localhost.localdomain> <20031031132331.35a9aaca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



David S. Miller wrote:

>On Fri, 31 Oct 2003 13:24:06 -0800
>Joe Perches <joe@perches.com> wrote:
>
>  
>
>>Why is this a "fix"?  Performance?
>>It seems more like someone's idea of code neatening.
>>    
>>
>
>IPC checksums were being miscomputed in the original code,
>we're as mystified as you are as to why it is that:
>
>	if (sum & 0x10000) {
>		sum++;
>		sum &= 0xffff;
>	}
>
>works while:
>
>	sum = ((sym >> 16) + sum) & 0xffff;
>
>does not.  The theory was that it might be some x86 gcc bug,
>but looking at the assembler diff Arnaldo Carvalho de Melo
>(the appletalk maintainer) showed me between the before and
>after:
>
Nah, they are different algorithms, as the assembler code clearly 
demonstrates.  The above snippet is incomplete, with the crucial 
multiply by 2 or the shift left omitted.  The assembler code reveals 
this crucial piece of information.

>
> 	xorl	%eax, %eax
>-	decl	%ecx
> 	movb	(%ebx), %al
>-	incl	%ebx
> 	addl	%eax, %edx
> 	addl	%edx, %edx
>-	movl	%edx, %eax
>-	shrl	$16, %eax
>-	addl	%edx, %eax
>
The previous instruction adds 0, 1, or 2 to the checksum accumulation. 
 That's because in the case where
the byte added to the accumulation (addl %eax, %edx) causes the 16 bit 
to set, then when multiplied by 2 (addl %edx, %edx) the 17 bit is set 
and the 16 bit is clear.

>-	movzwl	%ax,%edx
>+	testl	$65536, %edx
>+	je	.L982
>
This version adds one to the accumulation iff bit 16 is set following 
the multiply.  The results are clearly different. This latter version 
would be a correct implementation of  feedback shiftregister algorithm, 
assuming that is what is being computed instead of a simple checksum. 
 Not knowing the specification for the algorithm offhand, I can't say 
which is correct.

They will, however, _sometimes_ give the same results.  That probably 
explains the rest of the comments in this thread.

>+	incl	%edx
>+	andl	$65535, %edx
>+.L982:
>+	decl	%ecx
>+	incl	%ebx
> 	cmpl	$-1, %ecx
>
>we still can't see what's wrong.
>
>He did confirm that the change in question makes IPX compute checksums
>correctly.
>
>
>
>  
>
