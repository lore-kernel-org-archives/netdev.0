From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 4/5] udp: memory limitation by using udp_mem
Date: Wed, 21 Nov 2007 18:25:19 -0500
Message-ID: <4744BE5F.3060901@redhat.com>
References: <473CBDAD.1010708@redhat.com>	<473CBF16.8040001@redhat.com> <20071115.152353.100893781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, satoshi.oshima.fk@hitachi.com,
	billfink@mindspring.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbXKUXh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 18:37:58 -0500
In-Reply-To: <20071115.152353.100893781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Thu, 15 Nov 2007 16:50:14 -0500
> 
>> +static inline int __ip_check_max_skb_pages(struct sock *sk, int size)
>> +{
>> +	switch(sk->sk_protocol) {
>> +	case IPPROTO_UDP:
>> +		if (atomic_read(sk->sk_prot->memory_allocated) + size
>> +		    > sk->sk_prot->sysctl_mem[0])
>> +			return -ENOBUFS;
>> +		/* Fall through */	
>> +	default:
>> +		break;
>> +	}
>> +	return 0;
>> +}
>> +
<snip>
> 
> These special case checks are all over the place.
> 
> We don't have tests all over the place to see if a socket is TCP or
> DCCP or SCTP in order to implement memory accounting there, because we
> did it for connection oriented protocols cleanly, seperating things
> via callbacks etc.
> 
> I would like to see the datagram memory accounting work similarly.

Hello,

I'm still thinking this and focusing on enhancement of above function.
However, I feel difficulty because socket buffer allocation of UDP
sending packet is in IP layer: ip_append_data(). Moreover, the function
is called from several protocols including TCP. This makes setting
callback hard without changing function interface or core data structure.

Then, I would like to know if the following implementation could be
acceptable.

 - Adding sk_datagram_{rw}mem_schedule() as a memory schedule function
   for datagram protocols.

 - Adding sk_wmem_schedule().
   In the function, sk_stream_wmem_schedule() is called if the caller
   socket is stream protocols. Moreover, sk_datagram_wmem_schedule()
   is called if the socket is datagram like this:

   int sk_wmem_schedule(struct sock *sk, int size)
   {
	    ...
	    switch (sk->sk_type) {
	    case SOCK_STREAM:
	            return sk_stream_wmem_schedule(sk, size);
	    case SOCK_DGRAM:
	            return sk_datagram_wmem_schedule(sk, size);
	    default:
	            return 1;
	    }
   }

 - In ip_append_data(), sk_wmem_schedule() is called to execute
   memory accounting.

Please let me know if you have any comments about this.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
