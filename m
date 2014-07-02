From: Dan Aloni <dan@kernelim.com>
Subject: Re: net: pretty odd panic in netfilter
Date: Wed, 2 Jul 2014 10:20:39 +0300
Message-ID: <20140702072039.GA15488@gmail.com>
References: <53B37B61.3020901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53B37B61.3020901@oracle.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2014 at 11:24:17PM -0400, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on a pretty odd corruption(?) in the code - a pretty odd
> one.
> 
> Here's the issue I've hit:
> 
> [ 3640.805823] BUG: unable to handle kernel paging request at ffffffffffffff84
>[..]
> [ 3640.840752] Code: 4c 89 65 e8 49 89 cc 0f 97 c1 83 fa 01 0f 95 c0 48 89 5d e0 31 db 83 fa 04 4c 89 6d f0 0f 95 c3 4c 89 75 f8 21 55 55 fb 01 48 19 <d2> 48 83 e2 f0 48 83 c2 20 48 89 d0 48 83 f0 30 84 c9 48 0f 45
> [ 3640.840752] RIP nf_nat_packet (net/netfilter/nf_nat_core.c:482)
> [ 3640.840752]  RSP <ffff88014608b958>
> [ 3640.840752] CR2: ffffffffffffff84
> 
> Two odd things here:
> 
> 1. The code section seems to point mid-instruction:
> 
>     19dc:       0f 95 c3                setne  %bl
>     19df:       4c 89 75 f8             mov    %r14,-0x8(%rbp)
>     19e3:       21 c3                   and    %eax,%ebx
>     19e5:       83 fb 01                cmp    $0x1,%ebx
>     19e8:       48 19 d2                sbb    %rdx,%rdx  <=== The end of this (0xd2)
>     19eb:       48 83 e2 f0             and    $0xfffffffffffffff0,%rdx
>     19ef:       48 83 c2 20             add    $0x20,%rdx
>     19f3:       48 89 d0                mov    %rdx,%rax
>     19f6:       48 83 f0 30             xor    $0x30,%rax
> 
> 2. There isn't anything in that area that dereferences memory:
> 
>         enum nf_nat_manip_type mtype = HOOK2MANIP(hooknum);
> 
>         if (mtype == NF_NAT_MANIP_SRC)
>                 statusbit = IPS_SRC_NAT;
>         else
>                 statusbit = IPS_DST_NAT;

Hi Sasha,

The fault registers are consistent with the 'rorb %cl,-0x7d(%rax)' starting
at the place where you have 0xd2. But the problem started earlier:

    "75 f8 21 55 55 fb 01 48 19 <d2> 48 83 e2 f0"

What should have been according to objdump:

    "75 f8 21 c3 83 fb 01 48 19 <d2> 48 83 e2 f0"
              ^^^^^ 
These instructions should not have been modified, even by relocation. 
So we only need to figure out what overwrote with '0x5555'.

-- 
Dan Aloni
