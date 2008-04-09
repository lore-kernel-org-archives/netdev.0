From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: xfrm_user: fix selector family initialization
Date: Wed, 09 Apr 2008 17:38:55 +0200
Message-ID: <47FCE30F.8060400@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net> <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl> <47F4CF29.2000104@trash.net> <47F4E12B.3040508@trash.net> <BAY103-DAV125214C1E537F51083DAB6B2F70@phx.gbl> <47F4EB73.1040705@trash.net> <47FBC2AF.7050508@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030903000403080308030708"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Kazunori MIYAZAWA <kazunori@miyazawa.org>,
	"David S. Miller" <davem@davemloft.net>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51109 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbYDIPi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 11:38:58 -0400
In-Reply-To: <47FBC2AF.7050508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030903000403080308030708
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> The problem appears to be that openswan doesn't initialize the
>> selectors family when adding new SAs. xfrm_init_state() uses
>> the family to decide whether to set up inter family SAs or
>> regular SAs. We used to fix up the family in xfrm_user, but
>> this is now only done for transport mode SAs.
>>
>> -       /*
>> -        * Set inner address family if the KM left it as zero.
>> -        * See comment in validate_tmpl.
>> -        */
>> -       if (!x->sel.family)
>> +       if (x->props.mode == XFRM_MODE_TRANSPORT)
>>                 x->sel.family = p->family;
>> +
>>
>> Reverting this part should fix it, but would break inter family
>> tunnels again. It seems we need a different indication for
>> xfrm_init_state() for inter family SAs.
>>
>> Kazunori, any ideas?
> 
> 
> Did you have a chance to look into this? This is most likely
> going to break a lot of setups, so a fix is really needed
> before 2.6.25 is released.

<sigh>

Marco, could you test this patch please?



--------------030903000403080308030708
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 712e842d9d39b21da439c043242d8863a8eca7a3
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Apr 9 15:25:45 2008 +0200

    [XFRM]: xfrm_user: fix selector family initialization
    
    Commit df9dcb45 ([IPSEC]: Fix inter address family IPsec tunnel handling)
    broke openswan by removing the selector initialization for tunnel mode
    in case it is uninitialized.
    
    This patch restores the initialization, fixing openswan, but probably
    breaking inter-family tunnels again (unknown since the patch author
    disappeared). The correct thing for inter-family tunnels is probably
    to simply initialize the selector family explicitly.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 5d96f27..019d21d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -288,7 +288,7 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
 
-	if (x->props.mode == XFRM_MODE_TRANSPORT)
+	if (!x->sel.family)
 		x->sel.family = p->family;
 
 }

--------------030903000403080308030708--
