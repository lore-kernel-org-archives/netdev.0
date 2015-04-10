From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: use jump label patching for ingress qdisc
 in __netif_receive_skb_core
Date: Sat, 11 Apr 2015 00:34:46 +0200
Message-ID: <55285006.9040805@iogearbox.net>
References: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net> <1428705014.25985.331.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, ast@plumgrid.com,
	edumazet@google.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49504 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbbDJWe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 18:34:56 -0400
In-Reply-To: <1428705014.25985.331.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2015 12:30 AM, Eric Dumazet wrote:
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
>
> The cost of the extra conditional on MIPS was OK to avoid a call to
> __net_timestamp(), but maybe not to avoid a simple dereference ?

Thanks for the review! I could change that test into a macro and
test if CONFIG_JUMP_LABEL=n to make that if (1) effectively.
