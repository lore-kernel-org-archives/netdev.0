From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] xfrm: Add oif to dst lookups
Date: Tue, 15 Sep 2015 07:47:20 -0600
Message-ID: <55F82168.5080304@cumulusnetworks.com>
References: <1439247491-80410-1-git-send-email-dsa@cumulusnetworks.com>
 <20150915092838.GK25499@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33039 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbbIONrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 09:47:23 -0400
Received: by pacex6 with SMTP id ex6so177901254pac.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 06:47:23 -0700 (PDT)
In-Reply-To: <20150915092838.GK25499@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen:

On 9/15/15 3:28 AM, Steffen Klassert wrote:
> On Mon, Aug 10, 2015 at 04:58:11PM -0600, David Ahern wrote:
>> Rules can be installed that direct route lookups to specific tables based
>> on oif. Plumb the oif through the xfrm lookups so it gets set in the flow
>> struct and passed to the resolver routines.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> David, this change broke vti tunnels.
>
>> @@ -1690,8 +1694,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
>>
>>   		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
>>   			family = xfrm[i]->props.family;
>> -			dst = xfrm_dst_lookup(xfrm[i], tos, &saddr, &daddr,
>> -					      family);
>> +			dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif,
>> +					      &saddr, &daddr, family);
>
> Passing the original output interface to xfrm_dst_lookup will generate
> a routing loop whenever the original output interface is not identical
> to the tunnel endpoint, like it is with vti. We can not ask for a route
> through a specific interface here. This is the lookup for the tunnel
> endpoints, so it must return a route through the local tunnel endpoint
> device.
>
> I don't know how you are going to use this with your vrf changes, so
> I'm not sure how to fix this in a way that it works with vrf. Please
> look into this.
>

I wonder if it is failing in fib_table_lookup() at this point:

                                 if (flp->flowi4_oif &&
                                     flp->flowi4_oif != nh->nh_oif)
                                         continue;

(for this case flp->flowi4_flags does not have FLOWI_FLAG_VRFSRC set).

There are FIB tracepoints that would help shed some light, combined with 
a probe on exit:

perf probe -a 'fib_table_lookup_ret=fib_table_lookup%return ret=%ax'
perf record -e fib:* -e probe:* -a
perf script

I have not used VTI mode before. I'll look into it today. If possible 
can you send me config commands to reproduce?

Thanks,
David
