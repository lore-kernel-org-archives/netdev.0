From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target 	for HASH
 based fwmark
Date: Thu, 01 Dec 2011 12:24:26 +0100
Message-ID: <4ED763EA.50307@trash.net>
References: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2011 12:05 PM, Hans Schillstrom wrote:
>>>> And final question, why not simply use ipv6_skip_exthdr()?
>>> problems with fragments...
>> So the probem is that it will return the transport layer protocol
>> header for fragments with frag_off == 0? We also have ipv6_find_hdr()
>> which we could modify to indicate this in the frag_off pointer.
> ipv6_find_hdr() will do the trick with a light modification
> What about a wrapper like:
>
> int __ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> 		  int target, unsigned short *fragoff,  int *fragflg)
> {
> ...
> 		if (nexthdr == NEXTHDR_FRAGMENT) {
> 			unsigned short _frag_off;
> 			__be16 *fp;
>
> 			if (fragflg)
> 			        fragflg = 1;
> 			fp = skb_header_pointer(skb,
> 						start+offsetof(struct frag_hdr,
> 							       frag_off),
> 						sizeof(_frag_off),
> 						&_frag_off);
>
> ...
> }
>
> int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> 		  int target, unsigned short *fragoff)
> {
>          return __ipv6_find_hdr(skb, offset, terget, fragoff, NULL);
> }

Hmm that would require to change all current callers. I was more
thinking of unconditionally setting *frag_off in case of
fragments, then you can initialize it to some impossible value
like 0xffff and determine the presence of a fragment header
based on its value after calling ipv6_find_hdr().

