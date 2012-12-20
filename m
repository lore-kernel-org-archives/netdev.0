From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Thu, 20 Dec 2012 15:22:13 +0400
Message-ID: <50D2F4E5.4050904@oktetlabs.ru>
References: <50D1BCC0.2000208@oktetlabs.ru> <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com> <50D1CECE.7090706@oktetlabs.ru> <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com> <20121220073445.GM18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:59813 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752287Ab2LTLWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 06:22:24 -0500
In-Reply-To: <20121220073445.GM18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/12 11:34, Steffen Klassert wrote:
> On Wed, Dec 19, 2012 at 07:37:44PM +0000, Ben Hutchings wrote:
>    
>> On Wed, 2012-12-19 at 18:27 +0400, Yurij M. Plotnikov wrote:
>>      
>>> On 12/19/12 17:35, Ben Hutchings wrote:
>>>        
>>>> On Wed, 2012-12-19 at 17:10 +0400, Yurij M. Plotnikov wrote:
>>>>
>>>>          
>>>>> On kernel 3.7.1 I get strange behaviour of IP_MTU_DISCOVER socket
>>>>> option. The behaviour in case of IP_PMTUDISC_DO and IP_PMTUDISC_WANT
>>>>> values of IP_MTU_DISCOVER socket option on SOCK_DGRAM socket are the
>>>>> same and packet is always sent with "Don't Fragment" bit in case of
>>>>> IP_PMTUDISC_WANT. Also, the value of IP_MTU socket option is not updated.
>>>>>
>>>>>            
>>>> You could try reverting:
>>>>
>>>> commit ee9a8f7ab2edf801b8b514c310455c94acc232f6
>>>> Author: Steffen Klassert<steffen.klassert@secunet.com>
>>>> Date:   Mon Oct 8 00:56:54 2012 +0000
>>>>
>>>>       ipv4: Don't report stale pmtu values to userspace
>>>>
>>>>       We report cached pmtu values even if they are already expired.
>>>>       Change this to not report these values after they are expired
>>>>       and fix a race in the expire time calculation, as suggested by
>>>>       Eric Dumazet.
>>>>
>>>> Still, PMTU information is not supposed to expire for 10 minutes...
>>>>
>>>>
>>>>          
>>> With reverted commit there is no such problem on 3.7.1: IP_MTU is
>>> updated and DF is set only for the first packet in case of
>>> IP_PMTUDISC_WANT.
>>>        
>> [...]
>>
>> So it looks like something is going wrong with the expiry calculation
>> here.
>>
>> This change shouldn't affect the PMTU actually used by the kernel, but
>> could affect Onload since that relies on netlink route updates to keep
>> in synch.  You didn't say you were using Onload, but if you are then we
>> should not bother netdev with this until we can demonstrate a problem
>> that involves only the kernel stack.
>>
>>      
> I'm really surprised that this change can have such an effect,
> it changes nothing at the kernels pmtu handling. When looking
> at the code, I found that we may report a mtu value from a stale
> dst_entry when we query the mtu value with the IP_MTU socket
> option. But a subsequent send() should update the socket cached
> dst_entry, so at most one packet should be affected.
>
> Does the patch below change anything?
>
>
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 3c9d208..1049ce0 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1198,7 +1198,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>   	{
>   		struct dst_entry *dst;
>   		val = 0;
> -		dst = sk_dst_get(sk);
> +		dst = sk_dst_check(sk, 0);
>   		if (dst) {
>   			val = dst_mtu(dst);
>   			dst_release(dst);
>    
With this patch kernel 3.7.1 works perfect. All described problems are 
fixed.
