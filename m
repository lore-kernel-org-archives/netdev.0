From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH 1/3] [NET] Do pmtu check in transport layer
Date: Mon, 09 Apr 2007 12:23:50 -0400
Message-ID: <461A6896.1050308@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu> <4619FBEE.70103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:50155 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966166AbXDIQ2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 12:28:54 -0400
In-Reply-To: <4619FBEE.70103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> John Heffner wrote:
>> Check the pmtu check at the transport layer (for UDP, ICMP and raw), and
>> send a local error if socket is PMTUDISC_DO and packet is too big.  This is
>> actually a pure bugfix for ipv6.  For ipv4, it allows us to do pmtu checks
>> in the same way as for ipv6.
>>
>> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>> index d096332..593acf7 100644
>> --- a/net/ipv4/ip_output.c
>> +++ b/net/ipv4/ip_output.c
>> @@ -822,7 +822,9 @@ int ip_append_data(struct sock *sk,
>>  	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
>>  	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
>>  
>> -	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
>> +	if (inet->cork.length + length > 0xFFFF - fragheaderlen ||
>> +	    (inet->pmtudisc >= IP_PMTUDISC_DO &&
>> +	     inet->cork.length + length > mtu)) {
>>  		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
>>  		return -EMSGSIZE;
>>  	}
> 
> 
> This makes ping report an incorrect MTU when IPsec is used since we're
> only accounting for the additional header_len, not the trailer_len
> (which is not easily changeable). Additionally it will report different
> MTUs for the first and following fragments when the socket is corked
> because only the first fragment includes the header_len. It also can't
> deal with things like NAT and routing by fwmark that change the route.
> The old behaviour was that we get an ICMP frag. required with the MTU
> of the final route, while this will always report the MTU of the
> initially chosen route.
> 
> For all these reasons I think it should be reverted to the old
> behaviour.

You're right, this is no good.  I think the other problems are fixable, 
but NAT really screws this.

Unfortunately, there is still a real problem with ipv6, in that the 
output side does not generate a packet too big ICMP like ipv4.  Also, it 
feels kind of undesirable be rely on local ICMP instead of direct error 
message delivery.  I'll try to generate a new patch.

Thanks,
   -John
