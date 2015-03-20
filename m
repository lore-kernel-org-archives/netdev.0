From: Daniel Mack <daniel@zonque.org>
Subject: Re: cgroup matches in INPUT chain
Date: Fri, 20 Mar 2015 14:57:39 +0100
Message-ID: <550C2753.9020608@zonque.org>
References: <550B1852.2020209@zonque.org> <20150319185807.GA3845@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Alexey Perevalov <a.perevalov@samsung.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:42971 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbbCTN5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 09:57:42 -0400
In-Reply-To: <20150319185807.GA3845@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 03/19/2015 07:58 PM, Florian Westphal wrote:
> Daniel Mack <daniel@zonque.org> wrote:
>> In my tests, however, NF_INET_LOCAL_IN is iterated before early_demux()
>> is called,
> 
> Early demux occurs after PRE_ROUTING but before LOCAL_IN.

Hmm, you're right, except it isn't in my case. I'm not familiar with
that code, so please bear with me :)

In my simple test setup, when skbs are dequeued by process_backlog(),
they have skb->_skb_refdst set, and hence ip_rcv_finish() does not call
into early_demux() prior to iterating the INPUT chain:

ip_rcv_finish()
    if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL)
        ...
        ipprot->early_demux(skb);
        ...

Therefore, cgroup_mt() in xt_cgroup.c will be called with skb->sk ==
NULL, which makes the match callback ineffective. From looking at the
code, I assume xt_owner has the same problem.

However, when the skb is processed directly from the NIC's interrupt
handler, early_demux() is called as expected, and the match succeeds.

Any pointers how this can be solved would be greatly appreciated.


Thanks,
Daniel
