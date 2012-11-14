From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next] add DOVE extensions for VXLAN
Date: Wed, 14 Nov 2012 05:02:12 -0500
Message-ID: <OF37D107F7.21130384-ON85257AB6.0033825F-85257AB6.003720A9@us.ibm.com>
References: <201211132022.qADKLMrT018535@lab1.dls>	<20121113132842.2414d381@nehalam.linuxnetplumber.net>
	<OFD9622F46.08427B4F-ON85257AB5.00792B0C-85257AB5.007B6F17@us.ibm.com> <20121113144148.66a86bc7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:54011 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161013Ab2KNKCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 05:02:53 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 14 Nov 2012 03:02:52 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D0A9319D803E
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 03:02:16 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAEA2EHs210160
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 03:02:14 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAEA43t7018510
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 03:04:04 -0700
In-Reply-To: <20121113144148.66a86bc7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote on 11/13/2012 05:41:48 PM:


> >         Someone who doesn't want all of them shouldn't use this 
feature.
> > If we're dropping the "dove" flag in favor of individual flags for 
each
> > feature, then I could make this into "l2miss" and "l3miss" flags and
> > they should default off, of course.
> > 
> >                                                         +-DLS
> 
> Maybe a OVS style "here is the homeless packet" message is needed.
> That would allow for controller in user space to populate table
> on as needed basis.

        The netlink notifications are sending just the link information
and one of a MAC address or an IP address, depending on the sort of
miss we have. Sending the whole packet to user space would add up
to 64K of user packet data that is completely useless to us.
        Rate-limiting based on destination means keeping state of
some sort, which means an attacker can present you with new state
to keep on every packet (like sequentially sending to all possible
Internet addresses).
        I think a DoS attack from a hosted VM is no different than
any other, unintentional, disproportionate use of resources by a VM
and is ultimately a matter for the host admin.
        The netlink notifications include minimal information for
filling the forwarding table on demand and even the ordinary VXLAN
way of sending all the user data via multicast will result in
replication of packet data (up to 64K) to send to multiple destinations, 
all
but one of which will ultimately drop it in the unicast dst case. This,
until a valid unicast forwarding table entry is in place.
        I think, by comparison, a (smaller) netlink message locally
on every miss is fairly lightweight. We could keep state of what
destinations we've done notifications on, but then we have to age
these and this does nothing for DoS attacks which only have to send to
lots of different destinations to overflow our state table.

        The code I sent only turns on notifications at all when the
"dove" flag is set and we can split this into separate flags to allow
finer control. But I don't think sending multiple copies of whole
packets remotely or a single copy of the whole packet locally is
better than sending just the address info locally for unknown
destinations.

                                                                +-DLS
