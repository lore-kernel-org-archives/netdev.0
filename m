From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Wed, 16 Jan 2008 16:28:09 +0200
Message-ID: <478E1479.3020204@iki.fi>
References: <478A038B.4090900@iki.fi> <1200491531.4457.91.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:57478 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbYAPO1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 09:27:09 -0500
Received: by fk-out-0910.google.com with SMTP id z23so87557fkz.5
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 06:27:07 -0800 (PST)
In-Reply-To: <1200491531.4457.91.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Sun, 2008-13-01 at 14:26 +0200, Timo Ter=E4s wrote:
>> I tried to address all these problems, and added the xfrm_policy
>> and xfrm_state structure to a new linked list that is used solely
>> for dumping. This way the dumps can be done in O(n) and have an
>> iterator point to them. I also modified to af_key to stop dumping
>> when receive queue is filling up and continue it from a callback at
>> recvfrom() when there's more room.
>>
>> But I'd like to hear about:
>> - if the approach is ok (adding the entries in one more list)?
>> - if the new/modified variables, structures and function names are o=
k?
>> - if I should port these against net-2.6 or net-2.6.25 git tree?
>> - if I should split this to more than one commit? (maybe xfrm core,
>> xfrm user and af_key parts?)
>=20
> To answer your last 2 questions:
> There are two issues that are inter-mingled in there. The most
> important is pf_key not being robust on dump. The other being the
> accurracy of netlink dumping - this has much broader implications. I
> think you need to separate the patches into those two at least and
> prioritize on the pf_key as a patch that you push in. I would also
> try to make the pf_key dumping approach to mirror what netlink does
> today - in the worst case it would be as innacurate as netlink; which
> is not bad. I think youll find no resistance getting such a patch in.

Creating a separate af_key patch would not be a big problem. I was
just hoping avoiding it as the xfrm_state / xfrm_policy changes
modify the API and requires changing af_key also.

> To answer your first 2 questions:
>=20
> My main dilema with your approach is the policy of maintaining such a
>  list in the kernel and memory consumption needed vs the innacuracy=20
> of netlink dumps.With your approach of maintaining extra SA/P D, i
> would need double the RAM amount.

No. I'm not creating second copies of the SADB/SPD entries. The entries
are just added to one more list. Memory requirements go up on per entry
(figures based on 2.6.22.9 kernel):
sizeof(struct xfrm_policy) 636 -> 644 bytes
sizeof(struct xfrm_state)  452 -> 460 bytes

=46or 400K entries it would take about 3 megs of more memory. Where the
total database size is around 240-250 megs.

> Netlink dumping gives up accuracy[1], uses 50% of the memory you are=20
> proposing but abuses more cpu cycles. User space could maintain the
> list you are proposing instead - and compensate for the innaccuracies
> by watching events[2] Of course that shifts the accuracy to events
> which could be lost on their way to user space. This issue is
> alleviated a little more with your approach of keeping the list in
> the kernel and adding new updates to the tail of the dump list
> (which, btw, your patch didnt seem to do); however, even if you solve
> that: ** you are still will be faced with challenges of not being
> atomic on updates; example an entry already on your dump list could
> be deleted before being read by user space. I cant see you solving
> that without abusing a _lot_ more cpu (trying to find the entry on
> the dump list that may have gotten updated or deleted). Theres also
> the issue of how long to keep the dump list before aging it out and
> how to deal with multiple users.

If more entries are added, you can get notifications of them.
=20
Cheers,
  Timo

