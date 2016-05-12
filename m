From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH nf V2] netfilter: fix oops in nfqueue during netns error unwinding
Date: Thu, 12 May 2016 11:15:24 -0500
Message-ID: <87twi3qmlf.fsf@x220.int.ebiederm.org>
References: <1462981273-21676-1-git-send-email-fw@strlen.de>
	<20160512094725.GB1777@salvia>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	dale.4d@gmail.com, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160512094725.GB1777@salvia> (Pablo Neira Ayuso's message of
	"Thu, 12 May 2016 11:47:25 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On Wed, May 11, 2016 at 05:41:13PM +0200, Florian Westphal wrote:
>> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
>> index 5baa8e2..9722819 100644
>> --- a/net/netfilter/nf_queue.c
>> +++ b/net/netfilter/nf_queue.c
>> @@ -102,6 +102,13 @@ void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
>>  {
>>  	const struct nf_queue_handler *qh;
>>  
>> +	/* netns wasn't initialized, error unwind in progress.
>> +	 * Its possible that the nfq netns init function was not even
>> +	 * called, in which case nfq pernetns data is in undefined state.
>> +	 */
>> +	if (!net->list.next)
>> +		return;
>
> Thanks Florian.
>
> Question for the netns folks: Is this a stable assumption? My only
> concern with this is that it relies on internal the netns
> representation, so I'd like to make sure this thing doesn't break
> again.
>
> Let me know, thanks.

Ugh. I got distracted before I finished replying.

I don't think the analysis is correct.

The unwind and the netns exit path should maintain the same constraints.
If they don't there is a bug, perhaps in initialization ordering.

Code should be able to count on net_generic() from the beginning of the
corresponding .init to the end of the corresponding .fini

Something like that is not happening and if we can I would like to track
down why.

Otherwise we need code like the above all over the place.

Eric
