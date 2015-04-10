From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: use jump label patching for ingress qdisc
 in __netif_receive_skb_core
Date: Fri, 10 Apr 2015 15:40:00 -0700
Message-ID: <55285140.9030902@plumgrid.com>
References: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net> <1428705014.25985.331.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, edumazet@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36691 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125AbbDJWkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 18:40:02 -0400
Received: by pdea3 with SMTP id a3so36096811pde.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 15:40:01 -0700 (PDT)
In-Reply-To: <1428705014.25985.331.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/15 3:30 PM, Eric Dumazet wrote:
> On Fri, 2015-04-10 at 23:07 +0200, Daniel Borkmann wrote:
>> Even if we make use of classifier and actions from the egress
>> path, we're going into handle_ing() executing additional code
>> on a per-packet cost for ingress qdisc, just to realize that
>> nothing is attached on ingress.
>>
>> Instead, this can just be blinded out as a no-op entirely with
>> the use of a static key. On input fast-path, we already make
>> use of static keys in various places, e.g. skb time stamping,
>> in RPS, etc. It makes sense to not waste time when we're assured
>> that no ingress qdisc is attached anywhere.
>>
>> Enabling/disabling of that code path is being done via two
>> helpers, namely net_{inc,dec}_ingress_queue(), that are being
>> invoked under RTNL mutex when a ingress qdisc is being either
>> initialized or destructed.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> My concern about jump labels is they add a conditional on arches where
> CONFIG_JUMP_LABEL=n
>
> They look great on x86, but not sure about say MIPS.

mips has HAVE_ARCH_JUMP_LABEL, so it should be fast there.
I think all major archs are covered:
arch/arm/Kconfig:       select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL
arch/arm64/Kconfig:     select HAVE_ARCH_JUMP_LABEL
arch/mips/Kconfig:      select HAVE_ARCH_JUMP_LABEL
arch/powerpc/Kconfig:   select HAVE_ARCH_JUMP_LABEL
arch/s390/Kconfig:      select HAVE_ARCH_JUMP_LABEL if !MARCH_G5
arch/sparc/Kconfig:     select HAVE_ARCH_JUMP_LABEL if SPARC64
arch/x86/Kconfig:       select HAVE_ARCH_JUMP_LABEL
