From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Thu, 03 Apr 2008 16:36:35 +0200
Message-ID: <47F4EB73.1040705@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net> <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl> <47F4CF29.2000104@trash.net> <47F4E12B.3040508@trash.net> <BAY103-DAV125214C1E537F51083DAB6B2F70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kazunori MIYAZAWA <kazunori@miyazawa.org>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537AbYDCOgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 10:36:41 -0400
In-Reply-To: <BAY103-DAV125214C1E537F51083DAB6B2F70@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:
> Patrick McHardy wrote:
> 
>> Manually adding SAs works fine for me, can you figure out what
>> kind of SA openswan was trying to add?
> 
> I have sent you the output of ip -s x s
> and ip -s x p when openswan is working with
> 2.6.25-rc8 with the commit df9dcb458 reverted.
> Let me know you need ssh access to my 2.6.25
> box.

The problem appears to be that openswan doesn't initialize the
selectors family when adding new SAs. xfrm_init_state() uses
the family to decide whether to set up inter family SAs or
regular SAs. We used to fix up the family in xfrm_user, but
this is now only done for transport mode SAs.

-       /*
-        * Set inner address family if the KM left it as zero.
-        * See comment in validate_tmpl.
-        */
-       if (!x->sel.family)
+       if (x->props.mode == XFRM_MODE_TRANSPORT)
                 x->sel.family = p->family;
+

Reverting this part should fix it, but would break inter family
tunnels again. It seems we need a different indication for
xfrm_init_state() for inter family SAs.

Kazunori, any ideas?

