From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: Re: [PATCHv2] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Thu, 18 Sep 2014 08:43:06 +0200
Message-ID: <541A7EFA.8070506@green-communications.fr>
References: <54143FB2.9000600@green-communications.fr> <1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr> <alpine.LFD.2.11.1409180749570.4152@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.tech.numericable.fr ([82.216.111.37]:54090 "EHLO
	smtp1.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaIRGnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 02:43:13 -0400
In-Reply-To: <alpine.LFD.2.11.1409180749570.4152@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/09/2014 07:17, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 15 Sep 2014, Nicolas Cavallari wrote:
> 
>> If we cache them, the kernel will reuse them, independently of
>> whether forwarding is enabled or not.  Which means that if forwarding is
>> disabled on the input interface where the first routing request comes
>> from, then that unreachable result will be cached and reused for
>> other interfaces, even if forwarding is enabled on them.
>>
>> This can be verified with two interfaces A and B and an output interface
>> C, where B has forwarding enabled, but not A and trying
>> ip route get $dst iif A from $src && ip route get $dst iif B from $src
>>
>> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
> 
> 	Looks good to me,
> 
> Reviewed-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Still, I fail to see how the compiler optimizes
> the jump, 'goto local_input' still jumps to res.fi check.
> I tried even likely() after 'local_input:" checks for
> res.fi and !itag but the 'if (res.fi) {' block is still
> moved below and reached with jnz. I expected likely() to
> prefer the res.fi != NULL path.

Different compiler/arch/options perhaps ?  I'm using Debian's GCC
4.9.1-11 on amd64 with a defconfig + CONFIG_DEBUG_INFO. It does this:

.LBE2727:
        .loc 1 1800 0
        movb    $7, -102(%rbp)  #, res.type
        .loc 1 1801 0
        movq    $0, -96(%rbp)   #, res.fi
        xorl    %ecx, %ecx      # D.60248
        .loc 1 1653 0
        xorl    %r12d, %r12d    # flags
.LVL737:
        .loc 1 1749 0
        xorl    %r15d, %r15d    # do_cache
.LVL738:
        jmp     .L784   #

where .L784 is :
        .loc 1 1762 0
        movl    324(%r11), %edi # in_dev_74->cnf.data,
        xorl    %esi, %esi      # D.60250
.LVL601:
        movq    %r10, -128(%rbp)        # skb, %sfp
        testl   %edi, %edi      #
        movq    264(%r14), %rdi # _75->loopback_dev, _75->loopback_dev
        setne   %sil    #, D.60250
        xorl    %edx, %edx      #
.LVL602:
        call    rt_dst_alloc    #

As for the res.fi and itag check in local_input, it jumps only when the
test fails.
