From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: don't hold RTNL during ethtool phys_id
Date: Wed, 6 Apr 2011 17:20:29 -0700
Message-ID: <201104061720.30219.leedom@chelsio.com>
References: <20110406170929.6e427b36@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6239 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab1DGAVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 20:21:03 -0400
In-Reply-To: <20110406170929.6e427b36@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Stephen Hemminger <shemminger@linux-foundation.org>
| Date: Wednesday, April 06, 2011 05:09 pm
| 
| The Chelsio cxgb4 drivers implement blinking in a unique way by
| waiting on the mailbox. This patch cleans it up slightly by no longer
| holding the system wide network configuration lock during the process.
| 
| The patch also uses correct semantics for the time argument
| which is supposed to be in seconds; and zero is supposed
| to signify infinite blinking.
| 
| This is still a bad firmware interface design for this
| since it means the board is basically hung while doing the blink.
| But fixing it correctly would require hardware and firmware
| documentation. With that information the device could be converted
| to the new set_phys_id.
| 
| Compile tested only.
| 
| Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

  Are you assuming that the firmware won't respond with a command completion 
until the LED blinking is complete?  If so, that's a bad assumption.  The 
firmware runs as an asynchronous real-time OS.  The LED blinking simply becomes 
a thread of activity within the OS and the command completes immediately.

Casey

| ---
|  drivers/net/cxgb4/cxgb4_main.c     |   17 ++++++++++++++---
|  drivers/net/cxgb4vf/cxgb4vf_main.c |   21 +++++++++++++++++++--
|  2 files changed, 33 insertions(+), 5 deletions(-)
| 
| --- a/drivers/net/cxgb4/cxgb4_main.c	2011-04-06 16:49:02.045648800 -0700
| +++ b/drivers/net/cxgb4/cxgb4_main.c	2011-04-06 17:00:59.508851692 -0700
| @@ -1339,12 +1339,23 @@ static int restart_autoneg(struct net_de
|  static int identify_port(struct net_device *dev, u32 data)
|  {
|  	struct adapter *adap = netdev2adap(dev);
| +	int rc;
| +	unsigned long blinks;
| 
|  	if (data == 0)
| -		data = 2;     /* default to 2 seconds */
| +		blinks = UINT_MAX;
| +	else
| +		blinks = 2*data + data/2;
| 
| -	return t4_identify_port(adap, adap->fn, netdev2pinfo(dev)->viid,
| -				data * 5);
| +	/* Don't block networking updates while blink is in progress */
| +	dev_hold(dev);
| +	rtnl_unlock();
| +
| +	rc = t4_identify_port(adap, adap->fn, netdev2pinfo(dev)->viid,
| +			      blinks);
| +	rtnl_lock();
| +	dev_put(dev);
| +	return rc;
|  }
| 
|  static unsigned int from_fw_linkcaps(unsigned int type, unsigned int caps)
| --- a/drivers/net/cxgb4vf/cxgb4vf_main.c	2011-04-06 16:49:09.989728600
| -0700 +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c	2011-04-06
| 17:02:38.609846223 -0700 @@ -43,6 +43,7 @@
|  #include <linux/etherdevice.h>
|  #include <linux/debugfs.h>
|  #include <linux/ethtool.h>
| +#include <linux/rtnetlink.h>
| 
|  #include "t4vf_common.h"
|  #include "t4vf_defs.h"
| @@ -1352,11 +1353,27 @@ static int cxgb4vf_set_rx_csum(struct ne
|  /*
|   * Identify the port by blinking the port's LED.
|   */
| -static int cxgb4vf_phys_id(struct net_device *dev, u32 id)
| +static int cxgb4vf_phys_id(struct net_device *dev, u32 data)
|  {
|  	struct port_info *pi = netdev_priv(dev);
| +	int rc;
| +	unsigned int blinks;
| 
| -	return t4vf_identify_port(pi->adapter, pi->viid, 5);
| +	if (data == 0)
| +		blinks = UINT_MAX;
| +	else
| +		blinks = 2*data + data/2;
| +
| +	/* Don't block networking updates while blink is in progress */
| +	dev_hold(dev);
| +	rtnl_unlock();
| +
| +	rc =  t4vf_identify_port(pi->adapter, pi->viid, blinks);
| +
| +	rtnl_lock();
| +	dev_put(dev);
| +
| +	return rc;
|  }
| 
|  /*
