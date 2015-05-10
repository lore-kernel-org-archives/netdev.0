From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 10:45:42 -0700
Message-ID: <554F9946.9040707@plumgrid.com>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org> <1431277170-4618-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38223 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbEJRpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 13:45:45 -0400
Received: by igbhj9 with SMTP id hj9so54592328igb.1
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 10:45:44 -0700 (PDT)
In-Reply-To: <1431277170-4618-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/15 9:59 AM, Pablo Neira Ayuso wrote:
> The qdisc ingress filtering code is embedded into the core most likely because
> at that time we had no RCU in place to define a hook. This is semantically
> wrong as this violates the most basic rules of encapsulation.

Yet another attempt to sneak in 'qdisc_ingress_hook' to kill TC ?
Just add another hook for netfilter. Seriously. Enough of these
politics.

> On top of that, this special qdisc does not enqueue anything at all, so we can
> skip the enqueue indirection from qdisc_enqueue_root() which is doing things
> that we don't need.

Daniel's patch does that as well, but in much cleaner way.
Looks like you're stealing our ideas to hide overhead that you're
adding to ingress qdisc. Not cool.

> This reduces the pollution of the super-critical ingress path, where
> most users don't need this as it has been stated many times before.
> e.g. 24824a09 ("net: dynamic ingress_queue allocation").

Again, Daniel's patch accelerates super-critical ingress path even more.
Care to carefully read it first?

> As a result, this improves performance in the super-critical ingress:
>
> Before:
>
> Result: OK: 4767946(c4767946+d0) usec, 100000000 (60byte,0frags)
>    20973388pps 10067Mb/sec (10067226240bps) errors: 100000000
>
> After:
>
> Result: OK: 4747078(c4747078+d0) usec, 100000000 (60byte,0frags)
>    21065587pps 10111Mb/sec (10111481760bps) errors: 100000000
>
> This is roughly 92199pps, ~0.42% more performance on my old box.

funny, how the gain from removal of qdisc_enqueue_root() is offsetted
by added extra overhead. Compare your 0.42% with clean gains achieved by
Daniel's patch set.
