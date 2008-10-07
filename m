From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 09:38:28 -0500
Message-ID: <48EB7464.9090206@linux-foundation.org>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru> <48EB6F2D.100@linux-foundation.org> <20081007142902.GA26302@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	Hugh Dickins <hugh@veritas.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754234AbYJGOmZ@vger.kernel.org>
In-Reply-To: <20081007142902.GA26302@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Oct 07, 2008 at 09:16:13AM -0500, Christoph Lameter (cl@linux-foundation.org) wrote:
>>> I tested skb destruction via RCU path, and got 2.5 times worse numbers
>>> with small-packets-bulk-transfer workload.
>> Was this with regular RCU freeing? This will cool down the cacheline before
>> frees. You need SLAB_DESTROY_BY_RCU to keep the objects cache hot.
> 
> I believe there were no SLAB_DESTROY_BY_RCU 2 yars ago :)

Its been awhile. Hugh created it

> It was pure call_rcu(&skb->rcu, real_skb_freeing), where
> real_skb_freeing() just did usual kfree().

Right. That results in cacheline cooldown. You'd want to recycle the object as
they are cache hot on a per cpu basis. That is screwed up by the delayed
regular rcu processing. We have seen multiple regressions due to cacheline
cooldown.

The only choice in cacheline hot sensitive areas is to deal with the
complexity that comes with SLAB_DESTROY_BY_RCU or give up on RCU.
