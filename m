From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v4 PATCH 1/2] NETFILTER module xt_hmark, new target
	for HASH based fwmark
Date: Thu, 1 Dec 2011 12:05:14 +0100 (CET)
Message-ID: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:39325 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741Ab1LALFR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 06:05:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On 12/01/2011 01:25 AM, Hans Schillstrom wrote:
>> On Wednesday, November 30, 2011 16:51:35 Patrick McHardy wrote:
>>> On 11/25/2011 10:36 AM, Hans Schillstrom wrote:
>>>> +
>>>> +hdr_new:
>>>> +	/* Get header info */
>>>> +	ip6 = (struct ipv6hdr *) (skb->data + nhoff);
>>>> +	nexthdr = ip6->nexthdr;
>>>> +	hdrlen = sizeof(struct ipv6hdr);
>>>> +	hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),&_hdr);
>>>> +
>>>> +	while (nexthdr) {
>>>> +		switch (nexthdr) {
>>>> +		case IPPROTO_ICMPV6:
>>>> +			/* ICMP Error then move ptr to inner header */
>>>> +			if (get_inner6_hdr(skb,&nhoff, hdrlen)) {
>>> This doesn't look right. You assume the ICMPv6 header is following
>>> the IPv6 header with any other headers in between. If there are
>>> other headers, hdrlen will contain the length of the last header.
>>
>> RFC-4443  "Every ICMPv6 message is preceded by an IPv6 header and zero or more IPv6 extension headers."
>> hdrlen is actually previous header length in bytes, to be correct.
>> nhoff is the sum of processed headers.
>> So in case of an icmp the nhoff will be updated, and hdrlen preset to ipv6hdr size
>
>Right, I missed that you're using nhoff + hdrlen in
>get_inner6_hdr().
>
>>>> +				ip6hdrlvl++;
>>>> +				if (!pskb_may_pull(skb, sizeof(_hdr) + nhoff))
>>>> +					return XT_CONTINUE;
>>>> +				goto hdr_new;
>>>> +			}
>>>> +			nhoff += hdrlen;
>>>> +			goto hdr_rdy;
>>>> +
>>>> +		case NEXTHDR_FRAGMENT:
>>>> +			if (!ip6hdrlvl) /* Do not use ports if fragmented */
>>>> +				frag = 1;
>>> Shouldn't you also check for fragment offset == 0 here?
>> According to the RFC "Initialized to zero for transmission; ignored on reception"
>
>No, what I meant is that for the first fragment, you do
>have the upper layer header available. But as we already
>discussed for a stable identifier you want to ignore it
>anyways.
>
>>>> +		case NEXTHDR_TCP:
>>>> +		case NEXTHDR_UDP:
>>>> +		case NEXTHDR_ESP:
>>>> +		case NEXTHDR_AUTH:
>>> Don't you want to use the port numbers if only authentication
>>> without encryption is used?
>> with esp or ah the SPI will be used instead of ports.
>> Useful or not I don't know since they are asymmetric in terms of a flow.
>
>Yes, but with AH you could either use the ESP SPI or if no ESP
>is used the port numbers of the upper layer protocol.
>

The intention was to treat ESP & AH in the same way,
but as you say why not use the upper layer 
 
>>> And final question, why not simply use ipv6_skip_exthdr()?
>> problems with fragments...
>
>So the probem is that it will return the transport layer protocol
>header for fragments with frag_off == 0? We also have ipv6_find_hdr()
>which we could modify to indicate this in the frag_off pointer.

ipv6_find_hdr() will do the trick with a light modification
What about a wrapper like:

int __ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
		  int target, unsigned short *fragoff,  int *fragflg)
{
...
		if (nexthdr == NEXTHDR_FRAGMENT) {
			unsigned short _frag_off;
			__be16 *fp;

			if (fragflg)
			        fragflg = 1;
			fp = skb_header_pointer(skb,
						start+offsetof(struct frag_hdr,
							       frag_off),
						sizeof(_frag_off),
						&_frag_off);

...
}

int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
		  int target, unsigned short *fragoff) 
{
        return __ipv6_find_hdr(skb, offset, terget, fragoff, NULL);
}
