From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Thu, 01 Dec 2011 11:05:13 +0100
Message-ID: <4ED75159.5000604@trash.net>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com> <1322213787-25796-2-git-send-email-hans@schillstrom.com> <4ED65107.1040309@trash.net> <201112010125.29627.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201112010125.29627.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2011 01:25 AM, Hans Schillstrom wrote:
> On Wednesday, November 30, 2011 16:51:35 Patrick McHardy wrote:
>> On 11/25/2011 10:36 AM, Hans Schillstrom wrote:
>>> +
>>> +hdr_new:
>>> +	/* Get header info */
>>> +	ip6 = (struct ipv6hdr *) (skb->data + nhoff);
>>> +	nexthdr = ip6->nexthdr;
>>> +	hdrlen = sizeof(struct ipv6hdr);
>>> +	hp = skb_header_pointer(skb, nhoff + hdrlen, sizeof(_hdr),&_hdr);
>>> +
>>> +	while (nexthdr) {
>>> +		switch (nexthdr) {
>>> +		case IPPROTO_ICMPV6:
>>> +			/* ICMP Error then move ptr to inner header */
>>> +			if (get_inner6_hdr(skb,&nhoff, hdrlen)) {
>> This doesn't look right. You assume the ICMPv6 header is following
>> the IPv6 header with any other headers in between. If there are
>> other headers, hdrlen will contain the length of the last header.
>
> RFC-4443  "Every ICMPv6 message is preceded by an IPv6 header and zero or more IPv6 extension headers."
> hdrlen is actually previous header length in bytes, to be correct.
> nhoff is the sum of processed headers.
> So in case of an icmp the nhoff will be updated, and hdrlen preset to ipv6hdr size

Right, I missed that you're using nhoff + hdrlen in
get_inner6_hdr().

>>> +				ip6hdrlvl++;
>>> +				if (!pskb_may_pull(skb, sizeof(_hdr) + nhoff))
>>> +					return XT_CONTINUE;
>>> +				goto hdr_new;
>>> +			}
>>> +			nhoff += hdrlen;
>>> +			goto hdr_rdy;
>>> +
>>> +		case NEXTHDR_FRAGMENT:
>>> +			if (!ip6hdrlvl) /* Do not use ports if fragmented */
>>> +				frag = 1;
>> Shouldn't you also check for fragment offset == 0 here?
> According to the RFC "Initialized to zero for transmission; ignored on reception"

No, what I meant is that for the first fragment, you do
have the upper layer header available. But as we already
discussed for a stable identifier you want to ignore it
anyways.

>>> +		case NEXTHDR_TCP:
>>> +		case NEXTHDR_UDP:
>>> +		case NEXTHDR_ESP:
>>> +		case NEXTHDR_AUTH:
>> Don't you want to use the port numbers if only authentication
>> without encryption is used?
> with esp or ah the SPI will be used instead of ports.
> Useful or not I don't know since they are asymmetric in terms of a flow.

Yes, but with AH you could either use the ESP SPI or if no ESP
is used the port numbers of the upper layer protocol.

>> And final question, why not simply use ipv6_skip_exthdr()?
> problems with fragments...

So the probem is that it will return the transport layer protocol
header for fragments with frag_off == 0? We also have ipv6_find_hdr()
which we could modify to indicate this in the frag_off pointer.

