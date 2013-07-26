From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bonding: use pre-defined macro in bond_mode_name
 instead of magic number 0
Date: Fri, 26 Jul 2013 14:25:58 -0700
Message-ID: <1374873958.2009.9.camel@joe-AO722>
References: <51EF79E6.9060309@gmail.com>
	 <1374649819.18818.5.camel@joe-AO722>
	 <20130726.135330.232525167518786234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shhuiw@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47514 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932765Ab3GZV0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 17:26:00 -0400
In-Reply-To: <20130726.135330.232525167518786234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-26 at 13:53 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 24 Jul 2013 00:10:19 -0700
> 
> > Probably be simpler, less confusing, and more normal style
> > to use a switch case.
> > 
> >       switch (mode) {
> >       case BOND_MODE_ROUNDROBIN:
> >               return "load balancing (round-robin)";
> >       case BOND_MODE_ACTIVEBACKUP:
> >               return "fault-tolerance (active-backup)";
> >       case BOND_MODE_XOR:
> >               return "load balancing (xor)";
> >       case BOND_MODE_BROADCAST;
> >               return "fault-tolerance (broadcast)";
> >       case BOND_MODE_8023AD:
> >               return "IEEE 802.3ad Dynamic link aggregation";
> >       case BOND_MODE_TLB:
> >               return "transmit load balancing";
> >       case BOND_MODE_ALB:
> >               return "adaptive load balancing";
> >       default:
> >               return "unknown";
> >       }
> 
> I have to say that I do not prefer this approach.
> 
> I have a good idea what the compiler ends up outputting for the above,
> and the "indexed table of strings" approach is much less code.
> 

just fyi: it doesn't seem like "much less" to at least gcc 4.7

$ cat t1.c
#include <stdio.h>
#include <stdlib.h>

const char * __attribute__((noinline)) string1(int index)
{
  static const char *strings[] = {
    [0] = "String10",
    [1] = "String11",
    [2] = "String12",
    [3] = "String13",
    [4] = "String14",
    [5] = "String15",
  };
  if (index < 0 || index > 5)
    return NULL;
  return strings[index];
}

const char * __attribute__((noinline)) string2(int index)
{
  switch (index) {
  case 0: return "String20";
  case 1: return "String21";
  case 2: return "String22";
  case 3: return "String23";
  case 4: return "String24";
  case 5: return "String25";
  }
  return NULL;
}

int main(int argc, char** argv)
{
  int val;

  srand(time(NULL));
  val = rand()%6;
  printf("1: %s, 2: %s\n", string1(val), string2(val));
  return 0;
}
$ gcc -S -O2 t1.c
$ cat t1.s
	.file	"t1.c"
	.text
	.p2align 4,,15
	.globl	string1
	.type	string1, @function
string1:
.LFB38:
	.cfi_startproc
	movl	4(%esp), %eax
	cmpl	$5, %eax
	ja	.L3
	movl	strings.2633(,%eax,4), %eax
	ret
	.p2align 4,,7
	.p2align 3
.L3:
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE38:
	.size	string1, .-string1
	.p2align 4,,15
	.globl	string2
	.type	string2, @function
string2:
.LFB39:
	.cfi_startproc
	movl	4(%esp), %edx
	xorl	%eax, %eax
	cmpl	$5, %edx
	ja	.L6
	movl	CSWTCH.5(,%edx,4), %eax
.L6:
	rep
	ret
	.cfi_endproc
.LFE39:
	.size	string2, .-string2
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"1: %s, 2: %s\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4,,15
	.globl	main
	.type	main, @function
main:
.LFB40:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%esi
	pushl	%ebx
	.cfi_offset 6, -12
	.cfi_offset 3, -16
	movl	$715827883, %ebx
	andl	$-16, %esp
	subl	$16, %esp
	movl	$0, (%esp)
	call	time
	movl	%eax, (%esp)
	call	srand
	call	rand
	movl	%eax, %ecx
	imull	%ebx
	movl	%ecx, %eax
	sarl	$31, %eax
	movl	%edx, %ebx
	subl	%eax, %ebx
	leal	(%ebx,%ebx,2), %eax
	movl	%ecx, %ebx
	addl	%eax, %eax
	subl	%eax, %ebx
	movl	%ebx, (%esp)
	call	string2
	movl	%ebx, (%esp)
	movl	%eax, %esi
	call	string1
	movl	%esi, 12(%esp)
	movl	$.LC0, 4(%esp)
	movl	$1, (%esp)
	movl	%eax, 8(%esp)
	call	__printf_chk
	leal	-8(%ebp), %esp
	xorl	%eax, %eax
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE40:
	.size	main, .-main
	.section	.rodata.str1.1
.LC1:
	.string	"String10"
.LC2:
	.string	"String11"
.LC3:
	.string	"String12"
.LC4:
	.string	"String13"
.LC5:
	.string	"String14"
.LC6:
	.string	"String15"
	.section	.rodata
	.align 4
	.type	strings.2633, @object
	.size	strings.2633, 24
strings.2633:
	.long	.LC1
	.long	.LC2
	.long	.LC3
	.long	.LC4
	.long	.LC5
	.long	.LC6
	.section	.rodata.str1.1
.LC7:
	.string	"String20"
.LC8:
	.string	"String21"
.LC9:
	.string	"String22"
.LC10:
	.string	"String23"
.LC11:
	.string	"String24"
.LC12:
	.string	"String25"
	.section	.rodata
	.align 4
	.type	CSWTCH.5, @object
	.size	CSWTCH.5, 24
CSWTCH.5:
	.long	.LC7
	.long	.LC8
	.long	.LC9
	.long	.LC10
	.long	.LC11
	.long	.LC12
	.ident	"GCC: (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3"
	.section	.note.GNU-stack,"",@progbits
