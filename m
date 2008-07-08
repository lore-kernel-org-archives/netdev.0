From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/04]: VLAN vs. packet socket inconsistencies
Date: Tue, 08 Jul 2008 15:12:33 -0700 (PDT)
Message-ID: <20080708.151233.259338088.davem@davemloft.net>
References: <48733E1B.8010501@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757486AbYGHWMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:12:33 -0400
In-Reply-To: <48733E1B.8010501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Jul 2008 12:14:51 +0200

> There are mainly two remaining problems with this approach:
> 
> - socket filters for VLAN headers don't work properly since they
>    expect the VLAN header to be present. Since with the approach
>    taken by these patches, userspace has to have knowledge about
>    VLAN acceleration anyway, it seems OK to simply add a filter
>    instruction to filter on skb->vlan_tci and have userspace
>    construct its filters accordingly.
> 
> - packet socket auxdata is only available for non-mmaped sockets.
>    For mmaped sockets the only place to store the data is in
>    struct tpacket_hdr, but that would break compatibility. Not sure
>    what to do about this case.
> 
> Comments welcome.

The mmap socket limitation is pretty serious.  It's the only
thing holding me back from just applying these patches right now.

I think we should make a new version of the tpacket_hdr structure
anyways, in order to make it more compat-friendly.  It currently
has "unsigned long" members and other crap.

We can design this thing to be extensible quite easily, by simply
giving it an "offset" field.  My suggestion is:

1) sed 's/tpacket_hdr/tpacket_hdr_old/'

2) Create packet socket option PACKET_NEW_TPHDR which enables
   use of a new tpacket_hdr layout.

3) Make new tpacket_hdr which has the VLAN tag stuff as well
   as an 'offset' field so that we can add more stuff later
   in a backwards compat way.

4) New new tpacket_hdr layout when PACKET_NEW_TPHDR has been
   set.

