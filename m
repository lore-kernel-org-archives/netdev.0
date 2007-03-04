From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: Session ID 0 with PPPoE
Date: Sun, 4 Mar 2007 15:52:38 +0100
Message-ID: <20070304145238.GH28150@florz.florz.dyndns.org>
References: <20070304023000.GF28150@florz.florz.dyndns.org> <20070303.210714.07640494.davem@davemloft.net> <1173014727.12398.19.camel@kdsk1.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mostrows@speakeasy.net
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbf844.pool.mediaWays.net ([217.187.248.68]:4303 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932890AbXCDOwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 09:52:47 -0500
Content-Disposition: inline
In-Reply-To: <1173014727.12398.19.camel@kdsk1.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> >>From the RFC:
> 
> 5.4 The PPPoE Active Discovery Session-confirmation (PADS) packet
> 
>    When the Access Concentrator receives a PADR packet, it prepares to
>    begin a PPP session.  It generates a unique SESSION_ID for the PPPoE
>    session and replies to the Host with a PADS packet.  The
>    DESTINATION_ADDR field is the unicast Ethernet address of the Host
>    that sent the PADR.  The CODE field is set to 0x65 and the SESSION_ID
>    MUST be set to the unique value generated for this PPPoE session.
> 
>    The PADS packet contains exactly one TAG of TAG_TYPE Service-Name,
>    indicating the service under which Access Concentrator has accepted
>    the PPPoE session, and any number of other TAG types.
> 
>    If the Access Concentrator does not like the Service-Name in the
>    PADR, then it MUST reply with a PADS containing a TAG of TAG_TYPE
>    Service-Name-Error (and any number of other TAG types).  In this case
>    the SESSION_ID MUST be set to 0x0000.
> 
> 
> 
> As you can see from the last paragraph, a session id of 0 implies a
> rejection of the PADR.  Thus, you can't possibly get a PADS packet that
> completes and initiates a valid session if the session id is 0.
> 
> Note that the RFC does not prohibit all other aspects of the PADS to be
> structured as if it were a valid success response; the only condition
> and requirement of a failure mode here is the session id.

| [...] then it MUST reply with a PADS containing a TAG of TAG_TYPE
| Service-Name-Error [...]

!?!

To my understanding, the indicator is the Service-Name-Error tag, and
the RFC only states that if such a tag is present (indicating that
the AC "doesn't like" the requested service name and thus rejects the
session request), the session id field must be 0x0000 - not that the
session id field may not be 0x0000 if this tag is not present (which
would indicate that this is a valid session).

> Also 0xffff is reserved for future use. Thus it cannot be used as a
> sentinel value to indicate an invalid session id.

Well, currently it could (IMO, a connect() specifying 0xffff as the
session ID should fail anyway as of now as it is not a valid session id
as per the RFC - and 0xffff in the session id field could be used to mean
basically anything at the protocol level in the future) - however that
probably wouldn't be a good choice for extensibility reasons: If at
some point, a protocol session id field of 0xffff does somehow mean
something that would sensibly be represented as 0xffff in the session
id field of the internal data structure, one would have to change the
code again. So I guess the session id simply shouldn't be overloaded,
not even with an indication of its validity.

> Changing this code would require that the user-space component be
> synchronized with this change; as the socket interface implies that 0 is
> an invalid/unbound session id. 

Well, either that or the indication as to whether the session id is
currently valid should be stored in some different way.

> Lots of badness will occur if 0 is allowed as a session id, and nothing
> will be gained because it can't possibly be a valid session id.

Well, if that was the case, sure. But I still don't see any reason why
it can't be.

Florian
