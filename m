From: Frank Schreuder <fschreuder@transip.nl>
Subject: Re: reproducable panic eviction work queue
Date: Wed, 22 Jul 2015 12:55:28 +0200
Message-ID: <55AF76A0.7050907@transip.nl>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl>
 <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
 <55AA243D.5020306@cumulusnetworks.com>
 <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
 <55AA717D.8080800@cumulusnetworks.com> <55ACEDE9.3090205@transip.nl>
 <20150720143023.GC11985@breakpoint.cc> <55AE3208.8090403@transip.nl>
 <20150721183453.GL11985@breakpoint.cc> <55AF4FD7.2010009@transip.nl>
 <55AF5193.9090900@transip.nl> <55AF5E2E.5030203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johan Schuijt <johan@transip.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0141.outbound.protection.outlook.com ([157.56.112.141]:36201
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933779AbbGVKzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 06:55:42 -0400
In-Reply-To: <55AF5E2E.5030203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay,

Thanks for this patch. I'm no longer able to reproduce this panic on our 
test environment!
The server has been handling >120k fragmented UDP packets per second for 
over 40 minutes
So far everything is running stable without stacktraces in the logs. All 
other panics happened within 5-10 minutes.

I will let this test environment run for another day or 2. I will inform 
you as soon as something happens!

Thanks,
Frank



Op 7/22/2015 om 11:11 AM schreef Nikolay Aleksandrov:
> On 07/22/2015 10:17 AM, Frank Schreuder wrote:
>> I got some additional information from syslog:
>>
>> Jul 22 09:49:33 dommy0 kernel: [  675.987890] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 22s! [kworker/3:1:42]
>> Jul 22 09:49:42 dommy0 kernel: [  685.114033] INFO: rcu_sched self-detected stall on CPU { 3}  (t=39918 jiffies g=988 c=987 q=23168)
>>
>> Thanks,
>> Frank
>>
>>
> Hi,
> It looks like it's happening because of the evict_again logic, I think we should also
> add Florian's first suggestion about simplifying it to the patch and just skip the
> entry if we can't delete its timer otherwise we can restart the eviction and see
> entries that already had their timer stopped by us and can keep restarting for
> a long time.
> Here's an updated patch that removes the evict_again logic.
>
>
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index e1300b3dd597..56a3a5685f76 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -45,6 +45,7 @@ enum {
>    * @flags: fragment queue flags
>    * @max_size: maximum received fragment size
>    * @net: namespace that this frag belongs to
> + * @list_evictor: list of queues to forcefully evict (e.g. due to low memory)
>    */
>   struct inet_frag_queue {
>   	spinlock_t		lock;
> @@ -59,6 +60,7 @@ struct inet_frag_queue {
>   	__u8			flags;
>   	u16			max_size;
>   	struct netns_frags	*net;
> +	struct hlist_node	list_evictor;
>   };
>   
>   #define INETFRAGS_HASHSZ	1024
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 5e346a082e5f..aaae37949c14 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -138,27 +138,17 @@ evict_again:
>   		if (!inet_fragq_should_evict(fq))
>   			continue;
>   
> -		if (!del_timer(&fq->timer)) {
> -			/* q expiring right now thus increment its refcount so
> -			 * it won't be freed under us and wait until the timer
> -			 * has finished executing then destroy it
> -			 */
> -			atomic_inc(&fq->refcnt);
> -			spin_unlock(&hb->chain_lock);
> -			del_timer_sync(&fq->timer);
> -			inet_frag_put(fq, f);
> -			goto evict_again;
> -		}
> +		if (!del_timer(&fq->timer))
> +			continue;
>   
>   		fq->flags |= INET_FRAG_EVICTED;
> -		hlist_del(&fq->list);
> -		hlist_add_head(&fq->list, &expired);
> +		hlist_add_head(&fq->list_evictor, &expired);
>   		++evicted;
>   	}
>   
>   	spin_unlock(&hb->chain_lock);
>   
> -	hlist_for_each_entry_safe(fq, n, &expired, list)
> +	hlist_for_each_entry_safe(fq, n, &expired, list_evictor)
>   		f->frag_expire((unsigned long) fq);
>   
>   	return evicted;
> @@ -284,8 +274,7 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
>   	struct inet_frag_bucket *hb;
>   
>   	hb = get_frag_bucket_locked(fq, f);
> -	if (!(fq->flags & INET_FRAG_EVICTED))
> -		hlist_del(&fq->list);
> +	hlist_del(&fq->list);
>   	spin_unlock(&hb->chain_lock);
>   }
>   
>
>

-- 

TransIP BV

Schipholweg 11E
2316XB Leiden
E: fschreuder@transip.nl
I: https://www.transip.nl
