From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 09 Aug 2006 11:36:03 +0300
Message-ID: <44D99E73.1060305@tcs.hut.fi>
References: <20060808221651.GS14627@postel.suug.ch>	<20060808.164345.91207648.davem@davemloft.net>	<44D98133.8040707@tcs.hut.fi> <20060808.233442.41636358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:59143 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1030461AbWHIIgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:36:05 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.233442.41636358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ville Nuorvala <vnuorval@tcs.hut.fi>
> Date: Wed, 09 Aug 2006 09:31:15 +0300
> 
>> But the ip6_null_entry not always discarded after a failed route lookup!
>> On a forwarding router it triggers the ICMPv6 Destination Unreachable
>> message to the sender.
> 
> Good point, but I remember that in some cases the caller only wants a
> real entry or an error.

That's technically true, but the IPv6 code has largely been built around
the assumption that the route lookup produces a valid pointer to a
rt6_info entry.

Of the three original route lookup functions (ip6_route_input,
ip6_route_output and rt6_lookup), rt6_lookup was the only one that was
allowed to produce a NULL entry. Of these three rt6_lookup was also the
only one not actually being used for routing.

The function that absolutely requires ip6_null_entry is ip6_route_input.

As for ip6_route_output, even if it can return NULL or an error code, we
still need to check for dst->error separately in all the places we call
the function.

There is also one more issue with ip6_null_entry: previously it has
always been the result of an unsuccessful route lookup, now it can also
be the result of a successful application of a FR_ACT_UNREACHABLE policy
rule. From a networking point of view these two cases should IMO be
considered equivalent and should therefore trigger the same response.
This will however not be true if NULL (or an error code) is the result
of an unsuccessful route lookup.

> Perhaps both cases can be accomodated with a SHIM inline for the
> forwarding case that returns &ip6_null_entry when IS_ERR(retval).

If no one else is worried about the FR_ACT_UNREACHABLE inconsistency, I
can of course move the ip6_null_entry fallback code snippet to
ip6_route_input and perhaps ip6_route_output, while letting the NULL
route fall through fib6_rule_lookup and rt6_lookup.

Regards,
Ville
