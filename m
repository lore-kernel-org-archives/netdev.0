From: Paolo Galtieri <pgaltieri@mvista.com>
Subject: Re: Bug in SCTP with SCTP_BINDX_REM_ADDR
Date: Thu, 05 Apr 2007 13:25:45 -0700
Message-ID: <46155B49.4030206@mvista.com>
References: <4614FAE6.3070409@mvista.com> <461548E6.4030008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homer.mvista.com ([63.81.120.158]:8460 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbXDEUZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 16:25:43 -0400
In-Reply-To: <461548E6.4030008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's the revises patch

Paolo

Signed-off-by: Paolo Galtieri <pgaltieri@mvista.com>

--- net/sctp/socket.c.orig      2007-04-05 12:59:15.000000000 -0700
+++ net/sctp/socket.c   2007-04-05 13:11:37.000000000 -0700
@@ -627,6 +627,12 @@ int sctp_bindx_rem(struct sock *sk, stru
                        retval = -EINVAL;
                        goto err_bindx_rem;
                }
+
+               if (!af->addr_valid(&saveaddr, sp)) {
+                       retval = -EADDRNOTAVAIL;
+                       goto err_bindx_rem;
+               }
+
                if (sa_addr->v4.sin_port != htons(bp->port)) {
                        retval = -EINVAL;
                        goto err_bindx_rem;


Vlad Yasevich wrote:
> Hi Paolo
>
> Paolo Galtieri wrote:
>> What is happening is that the check for IPV6_ADDR_MAPPED that occurs
>> during the add is missing when you do the remove and hence the IPv6
>> address is never mapped to the IPv4 address causing the lookup to
>> fail.  Below is the patch to add the necessary checks to do the
>> mapping.  This patch is against 2.6.21-rc5
>>
>> Does this make sense?  Any comments are appreciated.
>>
>
> Yes, it makes perfect sense; however, I think you can just use
> af->addr_valid() instead of adding a special case below.
>
> If that works, can you regenerate the patch and provide a
> Signed-off-by line so I can incorporate that.
>
> Thanks
> -vlad
>
>> Thank you,
>> Paolo
>>
>> I've attached the test program - compile as gcc -o bindx-test-ipv6 
>> bindx-test-ipv6.c -lsctp
>> ================================ >8 
>> ==========================================
>> --- net/sctp/socket.c.orig      2007-04-04 13:22:59.000000000 -0700
>> +++ net/sctp/socket.c   2007-04-04 13:25:35.000000000 -0700
>> @@ -627,6 +627,27 @@ int sctp_bindx_rem(struct sock *sk, stru
>>                        retval = -EINVAL;
>>                        goto err_bindx_rem;
>>                }
>> +               /*
>> +                * It's possible that we mapped an IPV6 addr to an 
>> IPV4 addr
>> +                * during the sctp_bindx_add() operation.  This will 
>> happen if
>> +                * the IPV6 address we assigned to an interface is a 
>> mapped
>> +                * address, e.g. ::ffff:192.0.2.128.  If we have 
>> mapped an IPV6
>> +                * address to an IPV4 address during the add we need 
>> to make
>> +                * sure we do the same thing during the remove, 
>> otherwise we
>> +                * wont find a match on the address_list.
>> +                */
>> +
>> +               if (af->sa_family == AF_INET6) {
>> +                       struct in6_addr *in6;
>> +                       int type;
>> +
>> +                       in6 = (struct in6_addr *)&sa_addr->v6.sin6_addr;
>> +                       type = ipv6_addr_type(in6);
>> +
>> +                       if (type == IPV6_ADDR_MAPPED)
>> +                               sctp_v6_map_v4(sa_addr);
>> +               }
>> +
>>                if (sa_addr->v4.sin_port != htons(bp->port)) {
>>                        retval = -EINVAL;
>>                        goto err_bindx_rem;
>>
>>
>
>
