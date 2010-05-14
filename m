From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from	nf_conntrack_sip
Date: Fri, 14 May 2010 21:26:02 +0200
Message-ID: <4BEDA3CA.4030407@trash.net>
References: <20100514180138.GF15969@obsidianresearch.com> <4BED92AF.50704@trash.net> <20100514182601.GJ15969@obsidianresearch.com> <4BED99A3.2050404@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301010302090201070608"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BED99A3.2050404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090301010302090201070608
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Jason Gunthorpe wrote:
>> On Fri, May 14, 2010 at 08:13:03PM +0200, Patrick McHardy wrote:
>>> Your patch is based on an old version, the current version also
>>> supports TCP. I'll commit this patch to my tree after some testing.
>> Thanks!
>>
>>> diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
>>> index b20f427..45750cc 100644
>>> +++ b/net/netfilter/nf_conntrack_sip.c
>>> @@ -1393,10 +1393,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
>>>  
>>>  	nf_ct_refresh(ct, skb, sip_timeout * HZ);
>>>  
>>> -	if (skb_is_nonlinear(skb)) {
>>> -		pr_debug("Copy of skbuff not supported yet.\n");
>>> +	if (unlikely(skb_linearize(skb)))
>>>  		return NF_ACCEPT;
>>> -	}
>> Should this be NF_DROP? As I understand it skb_linearize only failes
>> if it runs out of memory, which probably means dropping is OK. But
>> passing a packet that might need rewriting could be harmful..
> 
> We so far also didn't rewrite the packet. But agreed, its
> a corner case and dropping it is the safer choice.

This is what I've added to my tree. Tested with asterisk and TSO
enabled NIC, which fails without this patch.

--------------090301010302090201070608
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit a1d7c1b4b8dfbc5ecadcff9284d64bb6ad4c0196
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri May 14 21:18:17 2010 +0200

    netfilter: nf_ct_sip: handle non-linear skbs
    
    Handle non-linear skbs by linearizing them instead of silently failing.
    Long term the helper should be fixed to either work with non-linear skbs
    directly by using the string search API or work on a copy of the data.
    
    Based on patch by Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index b20f427..53d8922 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1393,10 +1393,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (skb_is_nonlinear(skb)) {
-		pr_debug("Copy of skbuff not supported yet.\n");
-		return NF_ACCEPT;
-	}
+	if (unlikely(skb_linearize(skb)))
+		return NF_DROP;
 
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
@@ -1455,10 +1453,8 @@ static int sip_help_udp(struct sk_buff *skb, unsigned int protoff,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (skb_is_nonlinear(skb)) {
-		pr_debug("Copy of skbuff not supported yet.\n");
-		return NF_ACCEPT;
-	}
+	if (unlikely(skb_linearize(skb)))
+		return NF_DROP;
 
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;

--------------090301010302090201070608--
