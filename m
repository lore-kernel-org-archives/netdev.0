From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 2.6.21-rc1] ehea: dynamic add / remove port
Date: Fri, 16 Feb 2007 16:06:52 +0100
Message-ID: <200702161606.52789.ossthema@de.ibm.com>
References: <200702141536.28665.ossthema@de.ibm.com> <1171491906.30473.3.camel@sinatra.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, stefan.roscher@de.ibm.com,
	netdev <netdev@vger.kernel.org>,
	Nathan Fontenot <nfont@austin.ibm.com>
To: John Rose <johnrose@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:51918 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964965AbXBPPLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 10:11:17 -0500
In-Reply-To: <1171491906.30473.3.camel@sinatra.austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I agree with most points. Here the new design proposal:

On Wednesday 14 February 2007 23:25, John Rose wrote:
> Hi-
> 
> A few high level comments, then some really insignificant ones.
> 
> First, is there a reason why we shouldn't have a sysfs entry/kobject for
> each logical port?  How is it possible to determine, from the adapter
> sysfs directory, the current number of ports for that adapter?  A port
> sysfs directory could include attributes like the OF path to the port,
> the state of the port, etc etc.

I think it is not necessary to have a special entry/kobject for each logical
port. I suggest we use SET_NETDEV_DEV to create links to all ethernet devices
that represent each a logical port. This should be in sync with all other 
ethernet drivers. Port attributes like the "logical port id" that might be 
need by the userspace application can be added to the net:ethX entry
(link created with SET_NETDEV_DEV) as additional attributes. 
Thus we have a simple and consistent way to determine 
all currently available network interfaces (logical ports) and its
corresponding IDs.

> 
> Second, the probe and remove functions do not communicate whether an add
> or remove was successful.  Combine this with the lack of port
> information in the adapter sysfs directory, and the userspace tool has
> no way of verifying a dynamic add/remove.

True. I suggest we return error codes (-EIO / -EINVAL) in case the adding
or removing of ports fails. This is possible as we know instantly if the
operation failed or not. It is a synchronus operation.


> 
> +		ehea_info("%s -> logial port id #%d",
> 
> Spelling :)
true, fixed

> 
>  	if (port_setup_ok)
> -		ret = 0;	/* At least some ports are setup correctly */
> +		return 0;	/* At least some ports are setup correctly */
>  	else
> -		ret = -EINVAL;
> +		return -EINVAL;
> 
> The else is unnecessary.

agreed, fixed

> 
>  static int __devexit ehea_remove(struct ibmebus_dev *dev)
>  {
>  	struct ehea_adapter *adapter = dev->ofdev.dev.driver_data;
>  	u64 hret;
>  	int i;
> 
> -	for (i = 0; i < adapter->num_ports; i++)
> +	for (i = 0; i < EHEA_MAX_PORTS; i++)
>  		if (adapter->port[i]) {
>  			ehea_shutdown_single_port(adapter->port[i]);
>  			adapter->port[i] = NULL;
>  		}
> 
> Else break?
no break wanted here as "remove_port" might cause situations where
not all currently available ports are in a row

Regards,
Jan-Bernd
