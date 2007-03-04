From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: Session ID 0 with PPPoE
Date: Sun, 04 Mar 2007 07:25:26 -0600
Message-ID: <1173014727.12398.19.camel@kdsk1.austin.ibm.com>
References: <20070304023000.GF28150@florz.florz.dyndns.org>
	 <20070303.210714.07640494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: florz@gmx.de, netdev@vger.kernel.org, mostrows@speakeasy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:42672 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbXCDNZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 08:25:34 -0500
In-Reply-To: <20070303.210714.07640494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From the RFC:

5.4 The PPPoE Active Discovery Session-confirmation (PADS) packet

   When the Access Concentrator receives a PADR packet, it prepares to
   begin a PPP session.  It generates a unique SESSION_ID for the PPPoE
   session and replies to the Host with a PADS packet.  The
   DESTINATION_ADDR field is the unicast Ethernet address of the Host
   that sent the PADR.  The CODE field is set to 0x65 and the SESSION_ID
   MUST be set to the unique value generated for this PPPoE session.

   The PADS packet contains exactly one TAG of TAG_TYPE Service-Name,
   indicating the service under which Access Concentrator has accepted
   the PPPoE session, and any number of other TAG types.

   If the Access Concentrator does not like the Service-Name in the
   PADR, then it MUST reply with a PADS containing a TAG of TAG_TYPE
   Service-Name-Error (and any number of other TAG types).  In this case
   the SESSION_ID MUST be set to 0x0000.



As you can see from the last paragraph, a session id of 0 implies a
rejection of the PADR.  Thus, you can't possibly get a PADS packet that
completes and initiates a valid session if the session id is 0.

Note that the RFC does not prohibit all other aspects of the PADS to be
structured as if it were a valid success response; the only condition
and requirement of a failure mode here is the session id.

Also 0xffff is reserved for future use. Thus it cannot be used as a
sentinel value to indicate an invalid session id.

Changing this code would require that the user-space component be
synchronized with this change; as the socket interface implies that 0 is
an invalid/unbound session id. 

Lots of badness will occur if 0 is allowed as a session id, and nothing
will be gained because it can't possibly be a valid session id.

-- 
Michal Ostrowski <mostrows@earthlink.net>


On Sat, 2007-03-03 at 21:07 -0800, David Miller wrote:
> From: Florian Zumbiehl <florz@gmx.de>
> Date: Sun, 4 Mar 2007 03:30:00 +0100
> 
> > I noticed that the PPPoE code doesn't allow session id 0x0000 to be used
> > for an actual session but rather considers 0 a special value denoting
> > that the socket is unbound. Now, when reading RFC 2516, I couldn't really
> > find anything that would forbid 0x0000 as a session id. Only 0xffff "is
> > reserved for future use and MUST NOT be used", while 0x0000 is specified
> > as the only allowed value for the session id field on certain types of
> > packets, but neither can I find any statement that forbids 0x0000 as
> > an ordinary session identifier, nor can I find any reasons that would
> > prevent PPPoE from functioning properly with a session id of 0x0000.
> > 
> > Does anyone of you see any reason why a server would not be allowed to
> > select 0x0000 as the session id for a PPPoE session?
> 
> I can't, feel free to provide a patch to remove this limitation
> if it's important to you.
> 


