From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH]: bonding: Fix 802.3ad no carrier on "no partner found" instance
Date: Fri, 01 Jun 2007 12:15:00 -0700
Message-ID: <22892.1180725300@death>
References: <97949e3e0706010933h6921ca72p9858daa229bcfce6@mail.gmail.com> <9575.1180719013@death> <97949e3e0706011056u4fcf9b88k7d1476a85daf3630@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Laurent Chavey" <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:44525 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761856AbXFATPE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 15:15:04 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l51JF3xj020683
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 15:15:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l51JF2pV558338
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 15:15:03 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l51JF2Jx032431
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 15:15:02 -0400
In-reply-to: <97949e3e0706011056u4fcf9b88k7d1476a85daf3630@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laurent Chavey <chavey@google.com> wrote:

>On 6/1/07, Jay Vosburgh <fubar@us.ibm.com> wrote:
[...]
>>         Prior to the change in question, the carrier state of the ma=
ster
>> device was always on, regardless of the state of the slaves (so even=
 if
>> things didn't work, bonding would claim to be up).
>
>looking at the code, this will only work if there is an actual active
>aggregator. If that is not the case, and as you mention there could
>be an active aggregator before completing all LACP pahses (on all the =
slaves)
>then we would need to add a check (not for the mac) but for the churne=
d state.
>(I added a churned state machine that could be use there, I did not su=
bmit
>the patch yet)

	I'm not exactly sure what you mean, but I'm guessing that you're
saying that the current code won't work properly when there isn't an
active aggregator.  That's true, but the only times there isn't an
active aggregator is when there are no slaves, and temporarily during
802.3ad negoitation (if there are no 802.3ad responses, an aggregator i=
s
chosen from the set after a timeout).  During those times, I believe it
to be correct for the bonding master to be down, as no transmission or
reception is possible.

	I'm not at all sure what you mean by a churned state, but I
don't think any additional state checks are needed here, for the
following reason.

	I checked the 802.3ad standard, and I believe that the switches
I'm testing against are not in compliance with the standard,
particularly the following:

43.3.9 Attaching a link to an Aggregator

Links that are not successful candidates for aggregation (e.g., links
that are attached to other devices that cannot perform aggregation or
links that have been manually con=EF=AC=81gured to be non-aggregatable)=
 are
enabled to operate as individual IEEE 802.3 links. For consistency of
modeling, such a link is regarded as being attached to a compatible
Aggregator that can only be associated with a single link. That is, fro=
m
the perspective of Link Aggregation, non-aggregated links are not a
special case; they compose an aggregation with a maximum membership of
one link.

	The switches I have (Cisco 2960, 2970) do not appear to enable
links that are not successful candidates for aggregation as individual
802.3 links, rather, those links are disabled entirely. =20

	Anyway, in light of this, I don't see a problem with your patch,
I believe it would produce results in compliance with the standard.  It
may result in false "carrier up" for cases of, e.g., negotiation failur=
e
with 802.3ad switches such as I test with, but the cause there appears
to be due to noncompliance on the switch.

	Can you update your patch to change the comments above
bond_3ad_set_carrier() to remove the word "partnered" and note that the
code is implementing compliance with section 43.3.9 of IEEE 802.3, and
then resubmit your patch with the proper "Signed-off-by" attribution?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
