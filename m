From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] ipmr: delete redundant variable
Date: Thu, 24 Jul 2008 15:37:21 +0800
Message-ID: <48883131.9070805@cn.fujitsu.com>
References: <48868D54.6050701@cn.fujitsu.com> <200807231003.05848.netdev@axxeo.de> <4886FB56.20905@cn.fujitsu.com> <200807231405.39515.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60598 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbYGXHi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 03:38:59 -0400
In-Reply-To: <200807231405.39515.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Oeser said the following on 2008-7-23 20:05:
> But please check the generated assembly yourself on a CISC and RISC
> machine to get an idea of the effects. It will be a nice learning 
> experience I enjoyed myself already.
> 

I did the experiment.

I used the following C code to compare which approach is better and get
a result that two are same on performance.

----main.c
#define maxvif 32

struct vif {
	int *dev;
	unsigned long bytes_in, bytyes_out;
	unsigned long pkt_in, pkt_out;
	unsigned long rate_limit;
	unsigned char threshhold;
	unsigned short flags;
	int	local, remote;
	int	link;
};

struct vif vif_table[maxvif];

int main()
{
	struct vif *v;
	int ct;

	v = &vif_table[0];
	for (ct = 0; ct < maxvif; ct++, v++)
		if(v->link==1)
			break;
	return 0;
}
---

---main2.c
#define maxvif 32

struct vif {
	int *dev;
	unsigned long bytes_in, bytyes_out;
	unsigned long pkt_in, pkt_out;
	unsigned long rate_limit;
	unsigned char threshhold;
	unsigned short flags;
	int	local, remote;
	int	link;
};

struct vif vif_table[maxvif];

int main()
{
	struct vif *v;
	int ct;

	v = &vif_table[0];
	for (ct = 0; ct < maxvif; ct++)
		if(vif_table[ct].link==1)
			break;
	return 0;
}
---

Use gcc -S -O2 to compile:
---x86 asm main.s
	.file	"main.c"
	.text
	.p2align 4,,15
.globl main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	movl	$vif_table, %eax
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	jmp	.L2
	.p2align 4,,7
.L8:
	cmpl	$vif_table+1240, %eax
	je	.L3
	addl	$40, %eax
.L2:
	cmpl	$1, 36(%eax)
	jne	.L8
.L3:
	popl	%ecx
	xorl	%eax, %eax
	popl	%ebp
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.comm	vif_table,1280,32
	.ident	"GCC: (GNU) 4.1.2 20070115 (prerelease) (SUSE Linux)"
	.section	.note.GNU-stack,"",@progbits
---

---x86 asm main2.s
	.file	"main2.c"
	.text
	.p2align 4,,15
.globl main
	.type	main, @function
main:
	leal	4(%esp), %ecx
	andl	$-16, %esp
	pushl	-4(%ecx)
	xorl	%eax, %eax
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	jmp	.L2
	.p2align 4,,7
.L8:
	addl	$40, %eax
	cmpl	$1280, %eax
	je	.L3
.L2:
	cmpl	$1, vif_table+36(%eax)
	jne	.L8
.L3:
	popl	%ecx
	xorl	%eax, %eax
	popl	%ebp
	leal	-4(%ecx), %esp
	ret
	.size	main, .-main
	.comm	vif_table,1280,32
	.ident	"GCC: (GNU) 4.1.2 20070115 (prerelease) (SUSE Linux)"
	.section	.note.GNU-stack,"",@progbits
---

In loop area, main.s and main2.s have the following difference:
main.s :
	cmpl	$vif_table+1240, %eax
	cmpl	$1, 36(%eax)
main2.s:
	cmpl	$1280, %eax
	cmpl	$1, vif_table+36(%eax)
The difference can't cause different performance.

OK. Here is the asm on SPARC(not cross compile)
---main.s
                       	.global main                

			main:
/* 000000	  21 */		sethi	%hi(vif_table),%o5
/* 0x0004	  22 */		or	%g0,0,%o4
/* 0x0008	  21 */		add	%o5,%lo(vif_table),%o3
/* 0x000c	  23 */		ld	[%o3+36],%o5

			.L900000106:
/* 0x0010	  23 */		cmp	%o5,1
/* 0x0014	     */		be,pn	%icc,.L77000028
/* 0x0018	  22 */		add	%o4,1,%o4

			.L77000025:
/* 0x001c	  22 */		add	%o3,40,%o3
/* 0x0020	     */		cmp	%o4,32
/* 0x0024	     */		bl,a,pt	%icc,.L900000106
/* 0x0028	  23 */		ld	[%o3+36],%o5

			.L77000028:
/* 0x002c	  22 */		retl	! Result =  %o0
/* 0x0030	     */		or	%g0,0,%o0
/* 0x0034	   0 */		.type	main,2
/* 0x0034	   0 */		.size	main,(.-main)
/* 0x0034	   0 */		.global	__fsr_init_value
/* 0x0034	     */		 __fsr_init_value=0
---

---main2.s
                       	.global main   

			main:
/* 000000	  22 */		sethi	%hi(vif_table+36),%o5
/* 0x0004	     */		or	%g0,0,%o3
/* 0x0008	     */		add	%o5,%lo(vif_table+36),%o4
/* 0x000c	  23 */		ld	[%o5+%lo(vif_table+36)],%o5

			.L900000106:
/* 0x0010	  23 */		cmp	%o5,1
/* 0x0014	     */		be,pn	%icc,.L77000028
/* 0x0018	  22 */		add	%o4,40,%o4

			.L77000025:
/* 0x001c	  22 */		add	%o3,1,%o3
/* 0x0020	     */		cmp	%o3,32
/* 0x0024	     */		bl,a,pt	%icc,.L900000106
/* 0x0028	  23 */		ld	[%o4],%o5

			.L77000028:
/* 0x002c	  22 */		retl	! Result =  %o0
/* 0x0030	     */		or	%g0,0,%o0
/* 0x0034	   0 */		.type	main,2
/* 0x0034	   0 */		.size	main,(.-main)
/* 0x0034	   0 */		.global	__fsr_init_value
/* 0x0034	     */		 __fsr_init_value=0
---

In loop area, they are both ptr+sizeof(struct).

Now, we can get a conclusion that current compiler can do optimize the index accessing.
:)

Ingo, if you have any different opinion, it will be appreciated that you can share. :)

