From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool physical identify vs netlink locking?
Date: Wed, 30 Mar 2011 01:07:56 +0100
Message-ID: <1301443676.10056.57.camel@localhost>
References: <20110329135252.116bf5e0@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48848 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605Ab1C3AID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 20:08:03 -0400
In-Reply-To: <20110329135252.116bf5e0@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-29 at 13:52 -0700, Stephen Hemminger wrote:
> Right now if an administrator uses the ethtool function to identify network
> interface, the netlink lock can be held indefinitely. In other words, doing
> "ethtool -p eth1" will stop all other netlink activity. This is bad, imagine
> the case of an operator doing that to find a NIC in a rack, and because of
> the netlink lockout all routing daemon activity stops.

Also, glibc can enumerate devices during name lookup now (if I remember
correctly), so new connections to servers that do reverse name lookups
tend to stall immediately.

> There are several possible solutions but most involve fixing all the device
> drivers (24). Options:
> 
> 1. Have device driver drop and reacquire rtnl() while blinking
> 2. Have ethtool core drop rtnl before calling device driver
> 3. Add per-device ethtool rtnl lock
> 
> #1 is the least disruption

but nasty!

> #2 means additional locking maybe required for each device driver
> #3 seems like excessive overhead.

In the sfc driver, physical ID used to be delegated to the PHY
operations.  Then I realised that it was pointless to use a PHY's blink
mode where it was available and a periodic timer on the host where it
wasn't, when the latter would work for all of them.  So I would propose:

4. Define a ethtool operation 'set_id_state' with an argument that sets
identification on/off/inactive/active (the last optional, for any driver
that really wants to do this differently).  When this is defined, the
ethtool core runs the loop and acquires the lock each time it calls this
operation.

This requires changes to every driver, though not all at once.  As an
additional benefit, it should result in consistent behaviour for the
count = 0 case.

The core ethtool function would look something like:

static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
{
	struct ethtool_value id;
	int rc;

	if (!dev->ethtool_ops->phys_id && !dev->ethtool_ops->set_id_led)
		return -EOPNOTSUPP;

	if (copy_from_user(&id, useraddr, sizeof(id)))
		return -EFAULT;

	if (!dev->ethtool_ops->set_id_led)
		/* Do it the old way */
		return dev->ethtool_ops->phys_id(dev, id.data);

	rc = dev->ethtool_ops->set_id_state(dev, ETHTOOL_ID_ACTIVE);
	if (rc && rc != -EINVAL)
		return rc;

	dev_hold(dev);
	rtnl_unlock();

	if (rc == 0) {
		/* Driver will handle this itself */
		schedule_timeout_interruptible(
			id.data ? id.data : MAX_SCHEDULE_TIMEOUT);
	} else {
		/* Driver expects to be called periodically */
		do {
			rtnl_lock();
			rc = dev->ethtool_ops->set_id_state(dev, ETHTOOL_ID_ON);
			rtnl_unlock();
			if (rc)
				break;
			schedule_timeout_interruptible(HZ / 2);

			rtnl_lock();
			rc = dev->ethtool_ops->set_id_state(dev, ETHTOOL_ID_OFF);
			rtnl_unlock();
			if (rc)
				break;
			schedule_timeout_interruptible(HZ / 2);
		} while (!signal_pending(current) &&
			 (id.data == 0 || --id.data != 0));
	}

	rtnl_lock();
	dev_put(dev);

	(void)dev->ethtool_ops->set_id_state(dev, ETHTOOL_ID_INACTIVE);
	return rc;
}

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

