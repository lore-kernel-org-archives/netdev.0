From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 13:23:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031132331.35a9aaca.davem@redhat.com>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
	<1067635446.11564.92.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>
In-Reply-To: <1067635446.11564.92.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 31 Oct 2003 13:24:06 -0800
Joe Perches <joe@perches.com> wrote:

> Why is this a "fix"?  Performance?
> It seems more like someone's idea of code neatening.

IPC checksums were being miscomputed in the original code,
we're as mystified as you are as to why it is that:

	if (sum & 0x10000) {
		sum++;
		sum &= 0xffff;
	}

works while:

	sum = ((sym >> 16) + sum) & 0xffff;

does not.  The theory was that it might be some x86 gcc bug,
but looking at the assembler diff Arnaldo Carvalho de Melo
(the appletalk maintainer) showed me between the before and
after:

 	xorl	%eax, %eax
-	decl	%ecx
 	movb	(%ebx), %al
-	incl	%ebx
 	addl	%eax, %edx
 	addl	%edx, %edx
-	movl	%edx, %eax
-	shrl	$16, %eax
-	addl	%edx, %eax
-	movzwl	%ax,%edx
+	testl	$65536, %edx
+	je	.L982
+	incl	%edx
+	andl	$65535, %edx
+.L982:
+	decl	%ecx
+	incl	%ebx
 	cmpl	$-1, %ecx

we still can't see what's wrong.

He did confirm that the change in question makes IPX compute checksums
correctly.
