From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] net: sched: use no more than one page in struct
 fw_head
Date: Mon, 17 Mar 2014 15:28:52 +0000
Message-ID: <20140317152852.GB8956@casper.infradead.org>
References: <53229704.1040808@gmail.com>
 <20140314132834.GS21124@linux.vnet.ibm.com>
 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140314153810.GX21124@linux.vnet.ibm.com>
 <20140314185005.GA17041@linux.vnet.ibm.com>
 <20140314185917.GA18933@linux.vnet.ibm.com>
 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140317135101.GA8956@casper.infradead.org>
 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42930 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805AbaCQP2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:28:54 -0400
Content-Disposition: inline
In-Reply-To: <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/14 at 07:13am, Eric Dumazet wrote:
> On Mon, 2014-03-17 at 13:51 +0000, Thomas Graf wrote:
> > On 03/16/14 at 09:06am, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > In commit b4e9b520ca5d ("[NET_SCHED]: Add mask support to fwmark
> > > classifier") Patrick added an u32 field in fw_head, making it slightly
> > > bigger than one page.
> > > 
> > > Change the layout of this structure and let compiler emit a reciprocal
> > > divide for fw_hash(), as this makes the core more readable and
> > > more efficient those days.
> > 
> > I think you  need to educate me a bit on this. objdump
> > spits out the following:
> > 
> > static u32 fw_hash(u32 handle)
> > {
> >         return handle % HTSIZE;
> >   1d:   bf ff 01 00 00          mov    edi,0x1ff
> >   22:   89 f0                   mov    eax,esi
> >   24:   31 d2                   xor    edx,edx
> >   26:   f7 f7                   div    edi
> > 
> > Doesn't look like a reciprocal div to me. Where did I
> > screw up or why doesn't gcc optimize it properly?
> > --
> 
> Thats because on your cpu, gcc knows the divide is cheaper than anything
> else (a multiply followed by a shift)

OK.

> What are your exact CFLAGS ?

  gcc -Wp,-MD,net/sched/.cls_fw.o.d  -nostdinc -isystem
/usr/lib/gcc/x86_64-redhat-linux/4.8.2/include
-I/home/tgraf/dev/linux/net/arch/x86/include
-Iarch/x86/include/generated  -Iinclude
-I/home/tgraf/dev/linux/net/arch/x86/include/uapi
-Iarch/x86/include/generated/uapi
-I/home/tgraf/dev/linux/net/include/uapi -Iinclude/generated/uapi
-include /home/tgraf/dev/linux/net/include/linux/kconfig.h
-D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs
-fno-strict-aliasing -fno-common -Werror-implicit-function-declaration
-Wno-format-security -fno-delete-null-pointer-checks -Os
-Wno-maybe-uninitialized -m64 -mno-mmx -mno-sse
-mpreferred-stack-boundary=3 -mtune=generic -mno-red-zone
-mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args
-DCONFIG_X86_X32_ABI -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1
-DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_AVX=1
-DCONFIG_AS_AVX2=1 -pipe -Wno-sign-compare
-fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow
-mno-avx -fno-reorder-blocks -fno-ipa-cp-clone -fno-partial-inlining
-Wframe-larger-than=2048 -fno-stack-protector
-Wno-unused-but-set-variable -fno-omit-frame-pointer
-fno-optimize-sibling-calls -g -femit-struct-debug-baseonly
-fno-var-tracking -pg -mfentry -DCC_USING_FENTRY
-fno-inline-functions-called-once -Wdeclaration-after-statement
-Wno-pointer-sign -fno-strict-overflow -fconserve-stack
-Werror=implicit-int -Werror=strict-prototypes -DCC_HAVE_ASM_GOTO
-fprofile-arcs -ftest-coverage  -DMODULE  -D"KBUILD_STR(s)=#s"
-D"KBUILD_BASENAME=KBUILD_STR(cls_fw)"
-D"KBUILD_MODNAME=KBUILD_STR(cls_fw)" -c -o net/sched/.tmp_cls_fw.o
net/sched/cls_fw.c
