From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 2/2] conntrack: enable to tune gc parameters
Date: Mon, 10 Oct 2016 17:24:25 +0200
Message-ID: <cdda5290-c49c-e841-6ba5-10b30fd04fc0@6wind.com>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
 <1476094704-17452-3-git-send-email-nicolas.dichtel@6wind.com>
 <20161010140424.GB21057@breakpoint.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, pablo@netfilter.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161010140424.GB21057@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 10/10/2016 à 16:04, Florian Westphal a écrit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>> After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to remove
>> timed-out entries"), netlink conntrack deletion events may be sent with a
>> huge delay. It could be interesting to let the user tweak gc parameters
>> depending on its use case.
> 
> Hmm, care to elaborate?
> 
> I am not against doing this but I'd like to hear/read your use case.
> 
> The expectation is that in almot all cases eviction will happen from
> packet path.  The gc worker is jusdt there for case where a busy system
> goes idle.
It was precisely that case. After a period of activity, the event is sent a long
time after the timeout. If the router does not manage a lot of flows, why not
trying to parse more entries instead of the default 1/64 of the table?
In fact, I don't understand why using GC_MAX_BUCKETS_DIV instead of using always
GC_MAX_BUCKETS whatever the size of the table is.

> 
>> +nf_conntrack_gc_max_evicts - INTEGER
>> +	The maximum number of entries to be evicted during a run of gc.
>> +	This sysctl is only writeable in the initial net namespace.
> 
> Hmmm, do you have any advice on sizing this one?
In fact, no ;-)
I really hesitate to expose the four values or just a subset. My goal was also
to get feedback. I can remove this one.

> 
> I think a better change might be (instead of adding htis knob) to
> resched the gc worker for immediate re-executaion in case the entire
> "budget" was used.  What do you think?
Even if it's not directly related to my problem, I think it's a good idea.

> 
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -983,7 +983,7 @@ static void gc_worker(struct work_struct *work)
>                 return;
>  
>         ratio = scanned ? expired_count * 100 / scanned : 0;
> -       if (ratio >= 90)
> +       if (ratio >= 90 || expired_count == GC_MAX_EVICTS)
>                 next_run = 0;
> 
