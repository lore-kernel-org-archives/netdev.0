From: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: Possible problem with e6afc8ac ("udp: remove headers from UDP
 packets before queueing")
Date: Wed, 1 Jun 2016 16:44:09 -0400
Message-ID: <0b1fde4f-57ef-8c5e-147f-10c4a51fb2b0@tycho.nsa.gov>
References: <CAHC9VhS0oH8p55_3yOcQGJWx8WmokHW=kSrKOM6tKPM1XoPjGA@mail.gmail.com>
 <1464808695.5939.167.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: samanthakumar-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
In-Reply-To: <1464808695.5939.167.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 06/01/2016 03:18 PM, Eric Dumazet wrote:
> On Wed, 2016-06-01 at 15:01 -0400, Paul Moore wrote:
>> Hello,
>>
>> I'm currently trying to debug a problem with 4.7-rc1 and labeled
>> networking over UDP.  I'm having some difficulty with the latest
>> 4.7-rc1 builds on my test system at the moment so I haven't been able
>> to concisely identify the problem, but looking through the commits in
>> 4.7-rc1 I think there may be a problem with the following:
>>
>>   commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac
>>   Author: samanthakumar <samanthakumar-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>   Date:   Tue Apr 5 12:41:15 2016 -0400
>>
>>    udp: remove headers from UDP packets before queueing
>>
>>    Remove UDP transport headers before queueing packets for reception.
>>    This change simplifies a follow-up patch to add MSG_PEEK support.
>>
>>    Signed-off-by: Sam Kumar <samanthakumar-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>    Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>>
>> ... it appears that this commit changes things so that sk_filter() is
>> only called when sk->sk_filter is not NULL.  While this is fine for
>> the traditional socket filter case, it causes problems with LSMs that
>> make use of security_sock_rcv_skb() to enforce per-packet access
>> controls.
>>
>> Hopefully I'll get 4.7-rc1 booting soon and I can do a proper
>> bisection test around this patch, but I wanted to mention this now in
>> case others are seeing the same problem.
>>
> 
> Thanks for the report. Please try following fix.
> 
> sk_filter() got additional features like the skb_pfmemalloc() things and
> security_sock_rcv_skb()

This resolved the SELinux regression for me.

Tested-by: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>

> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index d56c0559b477..0ff31d97d485 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1618,12 +1618,12 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  		}
>  	}
>  
> -	if (rcu_access_pointer(sk->sk_filter)) {
> -		if (udp_lib_checksum_complete(skb))
> +	if (rcu_access_pointer(sk->sk_filter) &&
> +	    udp_lib_checksum_complete(skb))
>  			goto csum_error;
> -		if (sk_filter(sk, skb))
> -			goto drop;
> -	}
> +
> +	if (sk_filter(sk, skb))
> +		goto drop;
>  
>  	udp_csum_pull_header(skb);
>  	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 2da1896af934..f421c9f23c5b 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -653,12 +653,12 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  		}
>  	}
>  
> -	if (rcu_access_pointer(sk->sk_filter)) {
> -		if (udp_lib_checksum_complete(skb))
> -			goto csum_error;
> -		if (sk_filter(sk, skb))
> -			goto drop;
> -	}
> +	if (rcu_access_pointer(sk->sk_filter) &&
> +	    udp_lib_checksum_complete(skb))
> +		goto csum_error;
> +
> +	if (sk_filter(sk, skb))
> +		goto drop;
>  
>  	udp_csum_pull_header(skb);
>  	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
> 
> 
> _______________________________________________
> Selinux mailing list
> Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
> To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
> To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
> 

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
