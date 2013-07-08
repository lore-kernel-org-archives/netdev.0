From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] xen-netfront: pull on receive skb may need to
 happen earlier
Date: Mon, 08 Jul 2013 10:59:46 +0100
Message-ID: <51DAA9B202000078000E3357@nat28.tlf.novell.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>, <davem@davemloft.net>,
	"Dion Kant" <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130705145319.GB9050@zion.uk.xensource.com>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 05.07.13 at 16:53, Wei Liu <wei.liu2@citrix.com> wrote:
> On Fri, Jul 05, 2013 at 10:32:41AM +0100, Jan Beulich wrote:
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -831,6 +831,15 @@ static RING_IDX xennet_fill_frags(struct
>>  			RING_GET_RESPONSE(&np->rx, ++cons);
>>  		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
>>  
>> +		if (nr_frags == MAX_SKB_FRAGS) {
>> +			unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
>> +
>> +			BUG_ON(pull_to <= skb_headlen(skb));
>> +			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
> 
> skb_headlen is in fact "skb->len - skb->data_len". Looking at the
> caller code:
> 
>     while loop {
>         skb_shinfo(skb)->frags[0].page_offset = rx->offset;
> 	skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
> 	skb->data_len = rx->status;
> 
> 	i = xennet_fill_frags(np, skb, &tmpq);
> 
> 	/*                                                                           
>                                                                   
> 	 * Truesize is the actual allocation size, even if the                       
>                                                                   
> 	 * allocation is only partially used.                                        
>                                                                   
> 	 */
> 	skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
> 	skb->len += skb->data_len;
>     }
> 
>     handle_incoming_packet();
> 
> You seem to be altering the behavior of the original code, because in
> your patch the skb->len is incremented before use, while in the original
> code (which calls skb_headlen in handle_incoming_packet) the skb->len is
> correctly set.

Right. So I basically need to keep skb->len up-to-date along with
->data_len. Just handed a patch to Dion with that done; I'll defer
sending a v2 for the upstream code until I know the change works
for our kernel.

Jan
