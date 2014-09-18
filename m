From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Thu, 18 Sep 2014 11:04:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409181031260.16485@ja.home.ssi.bg>
References: <54143FB2.9000600@green-communications.fr> <1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr> <alpine.LFD.2.11.1409180749570.4152@ja.home.ssi.bg> <541A7EFA.8070506@green-communications.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51919 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753309AbaIRIEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 04:04:53 -0400
In-Reply-To: <541A7EFA.8070506@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 18 Sep 2014, Nicolas Cavallari wrote:

> On 18/09/2014 07:17, Julian Anastasov wrote:
> > 
> > 	Still, I fail to see how the compiler optimizes
> > the jump, 'goto local_input' still jumps to res.fi check.
> > I tried even likely() after 'local_input:" checks for
> > res.fi and !itag but the 'if (res.fi) {' block is still
> > moved below and reached with jnz. I expected likely() to
> > prefer the res.fi != NULL path.
> 
> Different compiler/arch/options perhaps ?  I'm using Debian's GCC
> 4.9.1-11 on amd64 with a defconfig + CONFIG_DEBUG_INFO. It does this:

	I see, new compilers can do better, I'm on x86 32-bit:

# rpm -qi gcc | grep -e Version -e Date
Version     : 4.8.3
Install Date: Sat 06 Sep 2014 05:56:15 PM EEST
Build Date  : Tue 24 Jun 2014 10:18:10 PM EEST

# make net/ipv4/route.s

---> local_input:
.L1031:
        movl    -56(%ebp), %edx # res.fi, D.55132
        testl   %edx, %edx      # D.55132

---> jump for likely(res.fi != NULL):

        jne     .L1219  #,
.L1095:
        movb    $0, -88(%ebp)   #, %sfp
.L1059:
        movzbl  -88(%ebp), %eax # %sfp, D.55118
        xorl    %edx, %edx      # D.55127
        cmpl    $0, 236(%edi)   #, in_dev_129->cnf.data
        pushl   %eax    # D.55118
        movl    init_net+172, %eax      # init_net.loopback_dev,
        setne   %dl     #, D.55127
        xorl    %ecx, %ecx      #
        call    rt_dst_alloc    #

...

---> no_route:
.L1027:
        movb    $7, -62(%ebp)   #, res.type
        movl    $0, -56(%ebp)   #, res.fi
#APP
# 1773 "net/ipv4/route.c" 1
        incl rt_cache_stat+8    # rt_cache_stat.in_no_route
# 0 "" 2
#NO_APP
.L1214:
        movl    $0, -92(%ebp)   #, %sfp

---> jump to local_input:

        jmp     .L1031  #

Regards

--
Julian Anastasov <ja@ssi.bg>
