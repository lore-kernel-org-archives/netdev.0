From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [Xen-devel] [PATCH net v5] xen-netback: fix fragment
 detection in checksum setup
Date: Tue, 10 Dec 2013 16:58:29 +0000
Message-ID: <52A75645020000780010C01B@nat28.tlf.novell.com>
References: <1386092369-13618-1-git-send-email-paul.durrant@citrix.com>
 <52A74B56020000780010BFB9@nat28.tlf.novell.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD01ACF1F@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	"Zoltan Kiss" <zoltan.kiss@citrix.com>,
	"David Miller" <davem@davemloft.net>,
	"xen-devel" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Paul Durrant" <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:47214 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab3LJQ6d convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 10 Dec 2013 11:58:33 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01ACF1F@AMSPEX01CL01.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 10.12.13 at 17:24, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>>  -----Original Message-----
>> From: Jan Beulich [mailto:JBeulich@suse.com]
>> Sent: 10 December 2013 16:12
>> To: Paul Durrant
>> Cc: David Vrabel; Ian Campbell; Wei Liu; Zoltan Kiss; David Miller; 
> xen-devel;
>> netdev@vger.kernel.org 
>> Subject: Re: [Xen-devel] [PATCH net v5] xen-netback: fix fragment detection
>> in checksum setup
>> 
>> >>> On 03.12.13 at 18:39, Paul Durrant <paul.durrant@citrix.com> wrote:
>> >  static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
>> >  			     int recalculate_partial_csum)
>> >  {
>> > -	struct iphdr *iph = (void *)skb->data;
>> > -	unsigned int header_size;
>> >  	unsigned int off;
>> > -	int err = -EPROTO;
>> > +	bool fragment;
>> > +	int err;
>> > +
>> > +	fragment = false;
>> > +
>> > +	err = maybe_pull_tail(skb,
>> > +			      sizeof(struct iphdr),
>> > +			      MAX_IP_HDR_LEN);
>> > +	if (err < 0)
>> > +		goto out;
>> >
>> > -	off = sizeof(struct iphdr);
>> > +	if (ip_hdr(skb)->frag_off & htons(IP_OFFSET | IP_MF))
>> > +		fragment = true;
>> 
>> You don't seem to be using "fragment" anywhere.
>> 
>> >
>> > -	header_size = skb->network_header + off + MAX_IPOPTLEN;
>> > -	maybe_pull_tail(skb, header_size);
>> > +	off = ip_hdrlen(skb);
>> >
>> > -	off = iph->ihl * 4;
>> > +	err = -EPROTO;
>> >
>> > -	switch (iph->protocol) {
>> > +	switch (ip_hdr(skb)->protocol) {
>> >  	case IPPROTO_TCP:
>> >  		if (!skb_partial_csum_set(skb, off,
>> >  					  offsetof(struct tcphdr, check)))
>> >  			goto out;
>> >
>> >  		if (recalculate_partial_csum) {
>> > -			struct tcphdr *tcph = tcp_hdr(skb);
>> > -
>> > -			header_size = skb->network_header +
>> > -				off +
>> > -				sizeof(struct tcphdr);
>> > -			maybe_pull_tail(skb, header_size);
>> > -
>> > -			tcph->check = ~csum_tcpudp_magic(iph->saddr, iph-
>> >daddr,
>> > -							 skb->len - off,
>> > -							 IPPROTO_TCP, 0);
>> > +			err = maybe_pull_tail(skb,
>> > +					      off + sizeof(struct tcphdr),
>> > +					      MAX_IP_HDR_LEN);
>> 
>> Is it really necessary/worthwhile to specify MAX_IP_HDR_LEN
>> here? Other than in the IPv6 case you're not risking to need
>> another pull if you simply used off + sizeof(struct tcphdr) instead.
>> 
> 
> Yes, I guess that's true but if we decide to pull up at all then is it 
> harmful to pull more than we absolutely need?

_If_ we manage to pull anything here, it means we weren't able to
pull up to the max anyway, so it seems a little odd to try again.

Another question: Don't the skb_partial_csum_set() calls require
the respective pulls to have happened already?

Jan
