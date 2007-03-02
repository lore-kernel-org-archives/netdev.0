From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Fri, 2 Mar 2007 10:56:23 +0100
Message-ID: <200703021056.24100.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <20070217131302.GA22732@2ka.mipt.ru> <20070302085246.GA30951@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_IT/5FzyqISvdmTQ"
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40974 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422989AbXCBJ4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 04:56:31 -0500
In-Reply-To: <20070302085246.GA30951@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_IT/5FzyqISvdmTQ
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 02 March 2007 09:52, Evgeniy Polyakov wrote:

> Ok, I've ran an analysis of linked lists and trie traversals and found
> that (at least on x86) optimized one list traversal is about 4 (!)
> times faster than one bit lookup in trie traversal (or actually one
> lookup in binary tree-like structure) - that is because of the fact
> that trie traversal needs to have more instructions per lookup, and at
> least one additional branch which can not be predicted.
>
> Tests with rdtsc shows that one bit lookup in trie (actually it is any
> lookup in binary tree structures) is about 3-4 times slower than one
> lookup in linked list.
>
> Since hash table usually has upto 4 elements in each hash entry,
> competing binary tree/trie stucture must get an entry in one lookup,
> which is essentially impossible with usual tree/trie implementations.
>
> Things dramatically change when linked list became too long, but it
> should not happend with proper resizing of the hash table, wildcards
> implementation also introduce additional requirements, which can not be
> easily solved in hash tables.
>
> So I get my words about tree/trie implementation instead of hash table
> for socket lookup back.
>
> Interested reader can find more details on tests, asm outputs and
> conclusions at:
> http://tservice.net.ru/~s0mbre/blog/2007/03/01#2007_03_01

Thank you for this report. (Still avoiding cache misses studies, while they 
obviously are the limiting factor)

Anyqay, if data is in cache and you want optimum performance from your cpu,
you may try to use an algorithm without conditional branches :
(well 4 in this case for the whole 32 bits tests)

gcc -O2 -S -march=i686 test1.c


--Boundary-00=_IT/5FzyqISvdmTQ
Content-Type: text/plain;
  charset="koi8-r";
  name="test1.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="test1.c"

struct node {
	struct node *left;
	struct node *right;
	int value;
	};
struct node *head;
int v1;

#define PASS2(bit) \
	n2 = n1->left; \
	right = n1->right; \
    if (value & (1<<bit)) \
        n2 = right; \
	n1 = n2->left; \
	right = n2->right; \
	if (value & (2<<bit)) \
		n1 = right;

main()
{
int j;
unsigned int value = v1;
struct node *n1 = head, *n2, *right;
for (j=0; j<4; ++j) {
	PASS2(0)
	PASS2(2)
	PASS2(4)
	PASS2(6)
	value >>= 8;
	}
printf("result=%p\n", n1);
}

--Boundary-00=_IT/5FzyqISvdmTQ
Content-Type: text/plain;
  charset="koi8-r";
  name="test1.s"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="test1.s"

	.file	"test1.c"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"result=%p\n"
	.text
	.p2align 4,,15
.globl main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	xorl	%ebx, %ebx
	pushl	%ecx
	subl	$16, %esp
	movl	v1, %ecx
	movl	head, %edx
	.p2align 4,,7
.L2:
	movl	4(%edx), %eax
	testb	$1, %cl
	cmove	(%edx), %eax
	testb	$2, %cl
	movl	4(%eax), %edx
	cmove	(%eax), %edx
	testb	$4, %cl
	movl	4(%edx), %eax
	cmove	(%edx), %eax
	testb	$8, %cl
	movl	4(%eax), %edx
	cmove	(%eax), %edx
	testb	$16, %cl
	movl	4(%edx), %eax
	cmove	(%edx), %eax
	testb	$32, %cl
	movl	4(%eax), %edx
	cmove	(%eax), %edx
	testb	$64, %cl
	movl	4(%edx), %eax
	cmove	(%edx), %eax
	testb	%cl, %cl
	movl	4(%eax), %edx
	cmovns	(%eax), %edx
	addl	$1, %ebx
	cmpl	$4, %ebx
	je	.L19
	shrl	$8, %ecx
	jmp	.L2
	.p2align 4,,7
.L19:
	movl	%edx, 4(%esp)
	movl	$.LC0, (%esp)
	call	printf
	addl	$16, %esp
	popl	%ecx
	popl	%ebx
	popl	%ebp
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.comm	head,4,4
	.comm	v1,4,4
	.ident	"GCC: (GNU) 4.1.2 20060928 (prerelease) (Ubuntu 4.1.1-13ubuntu5)"
	.section	.note.GNU-stack,"",@progbits

--Boundary-00=_IT/5FzyqISvdmTQ--
