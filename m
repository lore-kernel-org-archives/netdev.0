From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [E1000-devel] [PATCH net-next] igbvf: fix setting
 addr_assign_type if PF is up
Date: Wed, 9 Jan 2013 18:56:36 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B539A@FMSMSX107.amr.corp.intel.com>
References: <1357725564-5581-1-git-send-email-sassmann@kpanic.de>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B527A@FMSMSX107.amr.corp.intel.com>
 <50EDAFC6.3070700@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19998 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932478Ab3AIS4i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 13:56:38 -0500
In-Reply-To: <50EDAFC6.3070700@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> When the PF is up and igbvf is loaded the MAC address is not
> >> generated using eth_hw_addr_random(). This results in
> >> addr_assign_type not to be set.
> >> Make sure it gets set.
> >>
> >
> > NAK - In this case, the address may or may not be random. The user may
> > have (and should have!) explicitly set this address from the host to
> > ensure that the VF device receives the same address each time it
> boots.
> 
> Maybe you can give me some advice on this then. Why is there different
> behaviour depending on the PF being up or down? The problem I'm facing
> is that if the user did not set a MAC address for the VF manually and
> the PF is up during igbvf_probe it will not be labelled as random
> although it is.
> What about checking IGB_VF_FLAG_PF_SET_MAC and only set NET_ADDR_RANDOM
> if the flag is cleared?
> 

The difference in behavior is because we cannot get any MAC address at all
if the PF is down. The interface won't operate at all in this case, but if
the PF comes up sometime later, we can start working. The other alternative
is to leave the MAC address as all zeros and forcing the user to assign
an address manually. We chose to use a random address to at least give it
a chance of working once the PF woke up.

Currently, the PF has no way to communicate to the VF whether or not the
MAC address is random or assigned. The VF cannot check the
IGB_VF_FLAG_PF_SET_MAC flag because that only exists in the PF driver. To
propagate this flag down to the VF driver would require changes to the
PF/VF communication protocol.

In any case, I'm not sure that's the correct thing to do. From a policy
viewpoint, we don't want the VF to know what's happening in the PF. It
should not know how or why the MAC address was assigned, just like it
should not know whether or not the PF has placed it on a VLAN. VF devices
are not to be trusted and should not be given more information about the
state of the PF and host OS than is absolutely necessary to operate.

What's your use case here, Stefan? Why is this flag important to you?
As far as I can tell, nothing in the kernel ever looks at this flag.

-Mitch
