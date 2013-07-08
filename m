From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may
 need to happen earlier
Date: Mon, 08 Jul 2013 15:20:26 +0100
Message-ID: <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>,
	"Dion Kant" <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>, <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <51DAA9B202000078000E3357@nat28.tlf.novell.com>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 08.07.13 at 11:59, "Jan Beulich" <JBeulich@suse.com> wrote:
>>>> On 05.07.13 at 16:53, Wei Liu <wei.liu2@citrix.com> wrote:
>> On Fri, Jul 05, 2013 at 10:32:41AM +0100, Jan Beulich wrote:
>>> --- a/drivers/net/xen-netfront.c
>>> +++ b/drivers/net/xen-netfront.c
>>> @@ -831,6 +831,15 @@ static RING_IDX xennet_fill_frags(struct
>>>  			RING_GET_RESPONSE(&np->rx, ++cons);
>>>  		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
>>>  
>>> +		if (nr_frags == MAX_SKB_FRAGS) {
>>> +			unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
>>> +
>>> +			BUG_ON(pull_to <= skb_headlen(skb));
>>> +			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
>> 
>> skb_headlen is in fact "skb->len - skb->data_len". Looking at the
>> caller code:
>> 
>>     while loop {
>>         skb_shinfo(skb)->frags[0].page_offset = rx->offset;
>> 	skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
>> 	skb->data_len = rx->status;
>> 
>> 	i = xennet_fill_frags(np, skb, &tmpq);
>> 
>> 	/*                                                                           
> 
>>                                                                   
>> 	 * Truesize is the actual allocation size, even if the                       
> 
>>                                                                   
>> 	 * allocation is only partially used.                                        
> 
>>                                                                   
>> 	 */
>> 	skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
>> 	skb->len += skb->data_len;
>>     }
>> 
>>     handle_incoming_packet();
>> 
>> You seem to be altering the behavior of the original code, because in
>> your patch the skb->len is incremented before use, while in the original
>> code (which calls skb_headlen in handle_incoming_packet) the skb->len is
>> correctly set.
> 
> Right. So I basically need to keep skb->len up-to-date along with
> ->data_len. Just handed a patch to Dion with that done; I'll defer
> sending a v2 for the upstream code until I know the change works
> for our kernel.

Okay, so with that done (see below) Dion is now seeing the
WARN_ON_ONCE(delta < len) in skb_try_coalesce() triggering. Of
course, with it having crashed before, it's hard to tell whether the
triggering now is an effect of the patch, or just got unmasked by it.

Looking over the ->truesize handling, I can't see how the change
here could break things: RX_COPY_THRESHOLD is already
accounted for by how alloc_skb() gets called, and the increment
right after the call to xennet_fill_frags() should now be even more
correct than before (since __pskb_pull_tail() can drop fragments,
which would then have made this an over-estimation afaict).

That all said with me knowing pretty little about the networking
code, so I'd appreciate if you could point out anything wrong with
my idea of how things work. Additionally - is my fundamental (for
this patch) assumption right that multiple __pskb_pull_tail() call
are cumulative (i.e. calling it twice with a delta of
pull_to - skb_headlen(skb) would indeed end up pulling up to
pull_to, provided there is enough data)?

Jan

--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -831,10 +831,20 @@ static RING_IDX xennet_fill_frags(struct
 			RING_GET_RESPONSE(&np->rx, ++cons);
 		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
 
+		if (nr_frags == MAX_SKB_FRAGS) {
+			unsigned int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
+
+			BUG_ON(pull_to <= skb_headlen(skb));
+			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
+			nr_frags = shinfo->nr_frags;
+		}
+		BUG_ON(nr_frags >= MAX_SKB_FRAGS);
+
 		__skb_fill_page_desc(skb, nr_frags,
 				     skb_frag_page(nfrag),
 				     rx->offset, rx->status);
 
+		skb->len += rx->status;
 		skb->data_len += rx->status;
 
 		skb_shinfo(nskb)->nr_frags = 0;
@@ -929,7 +939,8 @@ static int handle_incoming_queue(struct 
 	while ((skb = __skb_dequeue(rxq)) != NULL) {
 		int pull_to = NETFRONT_SKB_CB(skb)->pull_to;
 
-		__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
+		if (pull_to > skb_headlen(skb))
+			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
 
 		/* Ethernet work: Delayed to here as it peeks the header. */
 		skb->protocol = eth_type_trans(skb, dev);
@@ -1014,7 +1025,7 @@ err:
 
 		skb_shinfo(skb)->frags[0].page_offset = rx->offset;
 		skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
-		skb->data_len = rx->status;
+		skb->len = skb->data_len = rx->status;
 
 		i = xennet_fill_frags(np, skb, &tmpq);
 
@@ -1023,7 +1034,6 @@ err:
                  * allocation is only partially used.
                  */
 		skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
-		skb->len += skb->data_len;
 
 		if (rx->flags & XEN_NETRXF_csum_blank)
 			skb->ip_summed = CHECKSUM_PARTIAL;
