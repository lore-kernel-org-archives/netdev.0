From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Tue, 11 Jul 2006 00:01:14 +0200
Message-ID: <200607110001.14812.stefan@loplof.de>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <200607091049.31628.stefan@loplof.de> <20060710095603.0b197eec@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natreg.rzone.de ([81.169.145.183]:56726 "EHLO natreg.rzone.de")
	by vger.kernel.org with ESMTP id S965031AbWGJV7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 17:59:22 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060710095603.0b197eec@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 10. Juli 2006 18:56 schrieb Stephen Hemminger:

> 1. I think vlan code should never be using the state bits directly at all.
> It makes the code error prone if the bits ever change, and it means
> that the proper callbacks are not being done. The existing
> vlan_transfer_operstate does what you want. VLAN_LINK_STATE_MASK etc,
> should go.

I just realized why 2.6.16 explicitely transfers LINK_STATE_PRESENT. This flag 
is positive true, and the code just assumes that it is always set in 
real_dev:

 new_dev->state = real_dev->state & VLAN_LINK_STATE_INITIAL_MASK;

So I think the fix for 2.6.17-stable should be:

-       new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
+       new_dev->state = real_dev->state & (1<<__LINK_STATE_NOCARRIER) | 
(1<<__LINK_STATE_DORMANT)) | (1<<__LINK_STATE_PRESENT); , dropping 
VLAN_LINK_STATE_INITIAL_MASK.

I can produce and test such a patch tomorrow evening, if someone needs it 
faster, feel free to go ahead ;-)

For the rest of your comment and 

> 3. All checks for IFF_UP should be using netif_running instead.
> IFF_UP is a leftover BSDism.

ACK. However,

> 2. The vlan device should not be marked as up when it
> is registered.

this is a userspace visible API change I don't like, but you are right it 
should use dev_open(). 

I would take responsibility to implement this on one of the next two weekends. 
Should be 2.6.19 stuff IMHO.

Stefan
