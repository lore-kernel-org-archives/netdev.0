From: Glenn Wurster <gwurster@scs.carleton.ca>
Subject: Re: [PATCH linux-2.6 v2] IPv6: Temp addresses are immediately deleted.
Date: Sat, 16 Oct 2010 14:42:17 -0400
Message-ID: <201010161442.18748.gwurster@scs.carleton.ca>
References: <20100927171010.GB7106@adams.ccsl.carleton.ca> <20100928.233028.112599117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 69-55-236-88.in-addr.arpa.johncompanies.com ([69.55.236.88]:60436
	"EHLO external.dropship.ath.cx" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753429Ab0JPSnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:43:16 -0400
In-Reply-To: <20100928.233028.112599117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 29, 2010 02:30:28 am David Miller wrote:
> From: Glenn Wurster <gwurster@scs.carleton.ca>
> Date: Mon, 27 Sep 2010 13:10:10 -0400
> 
> > There is a bug in the interaction between ipv6_create_tempaddr and
> > addrconf_verify.  Because ipv6_create_tempaddr uses the cstamp and tstamp
> > from the public address in creating a private address, if we have not
> > received a router advertisement in a while, tstamp + temp_valid_lft might
> > be < now.  If this happens, the new address is created inside
> > ipv6_create_tempaddr, then the loop within addrconf_verify starts again
> > and the address is immediately deleted.  We are left with no temporary
> > addresses on the interface, and no more will be created until the public
> > IP address is updated.  To avoid this, set the expiry time to be the
> > minimum of the time left on the public address or the config option PLUS
> > the current age of the public interface.
> > 
> > Version 2, now with 100% fewer line wraps.  Thanks to David Miller for
> > pointing out the line wrapping issue.
> > 
> > Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>
> 
> This can only happen if we apply your other patch, which I showed
> was incorrect as per RFCs.
> 
> We only create temporary address when public addresses are created,
> and this is the point where we are handling a router advertisement
> with non-zero Valid Lifetime.
> 
> Therefore I'm not applying this patch either.

No, the first patch was to create a temporary address if none exists.  Like 
Brian Haley pointed out, that patch accommodates the case where we set 
use_tempaddr to a non-zero value after the interface had been brought up.

This patch accommodates the case where the router is only broadcasting 
advertisements every x seconds, and yet the user has set the valid_lft to be 
something less than x.  In this setup, the condition I mentioned in the patch 
description happens, where the new temporary address is created, but the last 
modification time on that temporary address is set to the time of the last 
router advertisement, which was more than valid_lft seconds ago.  In this 
case, the temporary address is immediately deleted, and we are left with no 
temporary address on the interface.  Furthermore, because all temporary 
addresses get deleted by the time the next router advertisement arrives, we 
are left with not being able to use temporary addresses until we move 
networks.

I tested this patch alone, and it works as intended, allowing temporary 
addresses to continue to be created and deleted between received router 
advertisements.

You can easily test the bug by setting tmp_valid_lft to 60 and then running 
radvd.  The defaults for radvd seem to be a minimum retransmit on unsolicited 
router advertisements of 200 seconds (http://linux.die.net/man/5/radvd.conf), 
much higher than the 60 seconds it is going to take for the temporary address 
to expire. 

Glenn.
