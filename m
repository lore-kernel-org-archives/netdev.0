From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH] ks8851_ml ethernet network driver
Date: Thu, 17 Sep 2009 12:20:32 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0DE8A0@MELANITE.micrel.com>
References: <20090916210702.617b5069@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<Choi@kroah.com>, "Jeff Garzik" <jgarzik@redhat.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Greg KH" <greg@kroah.com>, "Li, Charles" <Charles.Li@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o144.mxlogic.net ([208.65.145.67]:45739 "EHLO
	p01c12o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbZIQTUd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 15:20:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090916210702.617b5069@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen Hemminger,

Here is my fix ups.
	-mutex_lock is intended to gurantee to access the hardware
registers 
	 exclusively. But as you mentioned, this mutex is redundancy in
ks_net_open() because this function does not access the hardware. So I
remove it.

================
@@ -858,7 +856,6 @@ static int ks_net_open(struct net_device
 	/* lock the card, even if we may not actually do anything
 	 * else at the moment.
 	 */
-	mutex_lock(&ks->lock);
 
 	if (netif_msg_ifup(ks))
 		ks_dbg(ks, "%s - entry\n", __func__);
@@ -875,8 +872,6 @@ static int ks_net_open(struct net_device
 	if (netif_msg_ifup(ks))
 		ks_dbg(ks, "network device %s up\n", netdev->name);
 
-	mutex_unlock(&ks->lock);
-
 	return 0;
 }


Regards,
David J. Choi


-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Wednesday, September 16, 2009 9:07 PM
To: Greg KH; Li, Charles
Cc: netdev@vger.kernel.org; David S. Miller; Choi@kroah.com; Choi,
David; Jeff Garzik
Subject: Re: [PATCH] ks8851_ml ethernet network driver

On Wed, 16 Sep 2009 19:38:36 -0700
Greg KH <greg@kroah.com> wrote:

> +
> +/**
> + * ks_net_open - open network device
> + * @netdev: The network device being opened.
> + *
> + * Called when the network device is marked active, such as a user
executing
> + * 'ifconfig up' on the device.
> + */
> +static int ks_net_open(struct net_device *netdev)
> +{
> +	struct ks_net *ks = netdev_priv(netdev);
> +	int err;
> +
> +#define	KS_INT_FLAGS	(IRQF_DISABLED|IRQF_TRIGGER_LOW)
> +	/* lock the card, even if we may not actually do anything
> +	 * else at the moment.
> +	 */
> +	mutex_lock(&ks->lock);
> +

I don't understand the purpose of ks->lock mutex. What is it
really protecting? open/close are already protected by rtnl_mutex,
is it really only for the PHY?
