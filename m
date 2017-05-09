From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] driver: vrf: Fix one possible use-after-free issue
Date: Tue, 9 May 2017 11:21:02 +0200
Message-ID: <20170509092102.GB16263@breakpoint.cc>
References: <1494320069-39638-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43070 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752620AbdEIJVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 05:21:35 -0400
Content-Disposition: inline
In-Reply-To: <1494320069-39638-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gfree.wind@vip.163.com <gfree.wind@vip.163.com> wrote:
> When one netfilter rule or hook stoles the skb and return NF_STOLEN,
> it means the skb is taken by the rule, and other modules should not
> touch this skb ever. Maybe the skb is queued or freed directly by the
> rule.
> 
> Now uses the nf_hook instead of NF_HOOK to get the result of netfilter,
> and check the return value of nf_hook. Only when its value equals 1, it
> means the skb could go ahead. Or reset the skb as NULL.
> 
> BTW, because vrf_rcv_finish is empty function, so needn't invoke it
> even though nf_hook returns 1.

Thats a bug then.

The okfn (if called) takes ownership of skb and must free it eventually.
Otherwise userspace queueing leaks skb on reinjection.

(see nf_reinject() and its use of okfn()).
