From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 04 Apr 2010 09:28:43 +0300
Message-ID: <4BB8319B.3040209@iki.fi>
References: <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi> <20100404020657.GA8520@gondor.apana.org.au> <4BB828B1.5090109@iki.fi> <20100404055830.GA9484@gondor.apana.org.au> <4BB82C90.70809@iki.fi> <20100404061941.GA9642@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:45179 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab0DDG2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 02:28:47 -0400
Received: by ey-out-2122.google.com with SMTP id 9so66834eyd.5
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 23:28:46 -0700 (PDT)
In-Reply-To: <20100404061941.GA9642@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Apr 04, 2010 at 09:07:12AM +0300, Timo Ter=E4s wrote:
>> With 1/4 only, the bundle deletion is not touched. In that case
>> the policy GC deletes explicitly the bundles. The bundles get
>> deleted immediately, and only the struct xfrm_policy might get
>> held up allocated longer.
>>
>> The code flow would be:
>> 1. xfrm_policy_kill() queues to GC
>> 2. xfrm_policy_gc_kill() called from xfrm_policy_gc_task()
>>    frees all bundles in that policy
>> 3. xfrm_policy_gc_kill() releases it's reference
>> 4. ... time passes (flush, randomization, or flow hit occurs)
>> 5. flow cache releases it's final reference, calls
>>    xfrm_policy_destroy() which only frees the xfrm_policy memory
>=20
> With 1/4 only, you've removed the flow cache flush when policies
> are deleted.  However, you don't add the flow cache flush to the
> NETDEV_DOWN case until 2/4.  So with only 1/4, bundles (and hence
> netdev objects) may be held for up to 10 minutes.

No. The flow cache flush removal does not prevent bundle deletion.
The flow cache flush is in current code *after* deleting the bundles
from the policy. Freeing bundles and flushing cache are completely
two separate things in current code. Only in 2/4 the bundle deletion
becomes dependent on flow cache flush.

Please, read xfrm_policy_kill() and xfrm_policy_gc_kill() in current
code, and after applying 1/4. The diff of 1/4 is not as informative
as the bundle deletion code is not shown there (since it's not touched)=
=2E

The only reason why current code does flow cache flush on policy
removal, is to make sure that it's not the flow cache atomic_dec
to drop last reference; if that happened xfrm_policy_destroy would
not get ever called.
