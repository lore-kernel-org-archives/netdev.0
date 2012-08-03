From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Fri, 3 Aug 2012 09:00:26 -0400
Message-ID: <OF8A71F97C.A020B6E9-ON85257A4F.00434903-85257A4F.004772D6@us.ibm.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>	<OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
	<CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>	<OF675087EF.EDC93ADE-ON85257A4E.004B2D96-85257A4E.004CB6BE@us.ibm.com>
	<CAOLNa-cMkHaFxoWym-oVT6i7ZZ25tZPxaAEcwUuT1TB4kPGfag@mail.gmail.com>	<OFA8EDA0BC.A9D42E39-ON85257A4E.004ECE32-85257A4E.004F3FC7@us.ibm.com> <CAOLNa-e0DB7Vhvv8tcSdW_JSWavpmyNt0vFYHLymh_zDaqUiMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Dragos Ilie <dragos.ilie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:34204 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868Ab2HCNA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2012 09:00:56 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 3 Aug 2012 09:00:54 -0400
In-Reply-To: <CAOLNa-e0DB7Vhvv8tcSdW_JSWavpmyNt0vFYHLymh_zDaqUiMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dragos Ilie <dragos.ilie@gmail.com> wrote on 08/03/2012 04:54:09 AM:
 
> a) Section 5.1.9 states that the QQIC field is meant for other
> multicast routers that are not the current querier. I "grep-ed" after
> mld2q_qqic in the entire kernel source tree and it is not being used
> at all. I take this as a sign that the field is not to be interpreted
> by listeners. Of course, that does not mean we cannot use it, but see
> b) below

        The kernel doesn't use it because it doesn't use the QI in the
timer to switch back to MLDv2 -- the problem you're trying to address.
If you think that's a bug (and I agree it is), the QQIC is how we
determine the QI. Missing functionality isn't evidence we shouldn't
use the QQIC. :-)
 
> b) Section 8.3.1 says that "if an MLDv1 router is present on the link,
> the Querier MUST use the lowest  version of MLD present on the
> network". Also, "if an MLDv1 router is present on the link, the system
> administrator must explicitly configure all MLDv2 routers to act in
> MLDv1 mode". It seems to me that these statements together preclude a
> scenario with MLDv1 and MLDv2 routers mixed together on the same link,
> unless all routers speak MLDv1.
 
        MLDv2 requires MLDv1 compatibility mode so there's no such thing
as an MLDv2 implementation that doesn't support MLDv1. The mechanism
for falling back to MLDv1 is required for exactly the case when there
is a mix of versions on the link; if that could never happen, none
of this code would be necessary or required by RFC.

> The current implementation for MLDv1 compatibility mode works very
> badly. The listeners fail most of the time to join the groups on the
> MLDv1 server.

I'm not sure what you mean here. Certainly you can, as suggested
above, force all hosts on the subnet to use MLDv1 using the
"force_mld_version" sysctl and an MLDv1 querier will also do that.
They'll switch back to MLDv2 too soon, if the v1 queries happen
infrequently which you can trivially work around by querying more
often.

>I suggest  that my patch sent earlier this week is
> pushed upstream, unless there are concerns that it will make things
> worse than they are today. This will improve the behavior of MLDv2
> listeners with MLDv1 routers and keep us compliant with the RFC. What
> do you think?

I think it should be correct, and a fixed QI isn't. If we're going to
do a hack, I think a v2-based QI is better than a fixed value.
However, I was thinking we could directly
measure the v1 QI based on received v1 queries. The main problem with
that is you don't know if you lost one or not, but we could work
around that by using the min of a saved QI and the measured interval
since the last query from the same source. The measured QI with losses
is always a multiple of the actual QI.

So, when we get a v1 query, save a timestamp of it and use the timestamp,
if set, to compute the interval since the last query. If the interval
is less than our current QI, it's the new QI. For the switchback time,
we use QI if set and 125 if not, where not being set would indicate
we haven't gotten more than 2 v1 queries.
        Finally, periodically (e.g., based on query counts, or multiple
larger QIs) reset in case an admin has increased the QI without a
reboot.
        The QI value only matters if it's the same querier, so also
with the timestamp save the source querier IP address and reset
if you get a general query from a different querier.

                                                        +-DLS
