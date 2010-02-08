From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPv6:Send an ICMPv6 "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Mon, 08 Feb 2010 15:20:40 +0100
Message-ID: <4B701DB8.3040407@trash.net>
References: <4B62A338.6020106@cn.fujitsu.com> <4B69A75A.2020908@trash.net> <4B701D3E.6000305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	eric.dumazet@gmail.com, randy.dunlap@oracle.com, mst@redhat.com,
	johannes@sipsolutions.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, pablo@netfilter.org,
	ebiederm@xmission.com, adobriyan@gmail.com, brian.haley@hp.com,
	shemminger@vyatta.com, akpm@linux-foundation.org,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B701D3E.6000305@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> Patrick McHardy wrote, at 02/04/2010 12:42 AM:
>> Shan Wei wrote:
>>> @@ -349,17 +378,20 @@ static int nf_ct_frag6_queue(struct nf_ct_frag6_queue *fq, struct sk_buff *skb,
>>>  	else
>>>  		fq->q.fragments = skb;
>>>  
>>> -	skb->dev = NULL;
>>>  	fq->q.stamp = skb->tstamp;
>>>  	fq->q.meat += skb->len;
>>>  	atomic_add(skb->truesize, &nf_init_frags.mem);
>>>  
>>>  	/* The first fragment.
>>>  	 * nhoffset is obtained from the first fragment, of course.
>>> +	 * Reserve dev for sending an ICMP "Fragment Reassembly Timeout"
>>> +	 * message.
>>>  	 */
>>>  	if (offset == 0) {
>>>  		fq->nhoffset = nhoff;
>>>  		fq->q.last_in |= INET_FRAG_FIRST_IN;
>>> +	} else {
>>> +		skb->dev = NULL;
>>>  	}
>> We need to store the iif and perform a lookup later just as in IPv4
>> because the device is not reference counted and might disappear while
>> the fragments are queued.
> 
> There is no net namespace in nf_conntrack_reasm,
> So we can't look up net device according to stored iif.
> 
> How about introducing net namespace to nf_conntrack_reasm?
> There are the following two advantages:
> 1. nf_init_frags can be deleted, because net structure includes netns_frags structure member.
> 
> 2. Record counter value, e.g. IPSTATS_MIB_REASMFAILS if reassamble with fail.
>    Since IPv6 conntrack fails to reassamble fragments, then the original fragment is not forwarded to IPv6 stack. 
>    The counter value can't be recorded. But IPv4 conntrack uses IPv4 defrag code, and records
>    counter value correctly.
> 
> These are just my thoughts, no practice.

Sounds good to me.

