From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Flow control config vs status
Date: Fri, 07 Oct 2011 22:38:53 +0100
Message-ID: <1318023533.2771.91.camel@bwh-desktop>
References: <20111007211918.GA7388@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9184 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab1JGVi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 17:38:56 -0400
In-Reply-To: <20111007211918.GA7388@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-07 at 14:19 -0700, Matt Carlson wrote:
> Hi Ben.  I've been encountering with a small problem with how ethtool
> handles flow control settings.
> 
> When the admin runs 'ethtool -A ...', ethtool will run an
> ETHTOOL_GPAUSEPARAM query, check the new settings against the 'old',
> and then issue ETHTOOL_SPAUSEPARAM if they don't match.  My problem is
> that the tg3 driver returns the flow control status in a
> ETHTOOL_GPAUSEPARAM query, not the configuration.

That's a bug in the driver.

> So, as an example of the problem, if the local side sets
> 'ethtool -A ethx rx on tx on autoneg on', and then the remote side sets
> 'ethtool -A ethy rx off tx off autoneg off', the link will autoneg to rx
> off, tx off.  Then, the local side will be unable to turn off rx or tx
> flow control because ethtool will act on the current link flow control
> status, not the config.
> 
> The tg3 isn't the only driver that reports flow control status through
> ETHTOOL_GPAUSEPARAM.  The e1000e, bnx2, and bnx2x drivers do this as
> well.
> 
> The ETHTOOL_GSET query does make room for flow control advertisements,
> but a device doesn't have to advertise its flow control settings if flow
> control autoneg is turned off.

But if flow control autoneg is off then ETHTOOL_GPAUSEPARAM / ethtool -a
already tells you all you need to know.

> I'm thinking this interface doesn't really solve the problem.
> 
> Any recommendations?

ethtool -a should always show the administrative configuration.  If it
shows that flow control autoneg is on, the administrator can then run
ethtool with no options to see what the link partner advertised.

Now, not everyone has memorised IEEE 802.3 table 28B-3, so maybe if
autoneg is enabled then 'ethtool -a' should also call ETHTOOL_GSET and
work out and display the result of autonegotiation of flow control.
That would have to be conditional on lp_advertising being non-zero.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
