From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Wed, 11 Jun 2008 08:47:59 +0200
Message-ID: <484F751F.7030407@trash.net>
References: <20080610205633.11186.45499.stgit@dale> <20080610210918.11186.64253.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62965 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbYFKGsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 02:48:02 -0400
In-Reply-To: <20080610210918.11186.64253.stgit@dale>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since I didn't receive anything but a "its too complex" in
response to my previous question, let me ask again: why are
you inventing a new sysfs interface (combined with ~15 module
parameters) instead of using the existing standard interfaces
for this?

Ramachandra K wrote:
> +sysfs interface:
> +----------------
> +
> +The QLogic Virtual NIC module when loaded on host creates following set of
> +files into the sysfs:
> +
> +/sys/class/infiniband_qlgc_vnic/interfaces
> +
> +	create_vnic	(0200)	To create a new VNIC interface, write the name
> +				of the interface to this file.
> +
> +	delete_vnic	(0200)	To delete an existing VNIC interface, write
> +				name of that VNIC interface to this file.

This is exactly what rtnl_link is for.

> +/sys/class/infiniband_qlgc_vnic/interfaces/<VNIC-interface-name>/
> +
> +	vnic_state	(0444)	State of the VNIC interface.

This I don't understand - you seem to be registering and
unregistering the net_device based some state machine,
in some cases even triggered by timers.

Whats the idea behind this?

> +
> +	current_path	(0444)	In case of failover configuration, which
> +				connection among the primary and secondary is
> +				currently being used.
> +
> +	multicast	(0644)	Get/Set IB multicast value for the VNIC
> +				interface.  Only root can Enable/Disable IB
> +				multicast for that VNIC interface.
> +
> +	rx_csum		(0644)	Get/Set receive checksum boolean value for VNIC
> +				interface.  Only root can Enable/Disable the
> +				receive checksum operation for that VNIC
> +				interface.
> +
> +	tx_csum		(0644)	Get/Set transmit checksum boolean value for VNIC
> +				interface.  Only root can Enable/Disable the
> +				transmit checksum operation for that VNIC
> +				interface.

Why is this not done using ethtool?

> +Example:
> +--------
> +
> +QLogic VNIC sysfs interface can be used directly to create a VNIC interface.
> +
> +# echo the name of new VNIC interface to create_vnic
> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/create_vnic
> +
> +# echo parameters to configure the VNIC interface. Some of these are 
> +# interface level parameters which needs to be passed only once per VNIC
> +# interface.
> +
> +echo -n true  > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/rx_csum
> +echo -n false > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/tx_csum
> +echo -n false > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/multicast
> +
> +echo -n 00066a01de000037 		 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_guid
> +echo -n fe8000000000000100066a11de000037 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/dgid
> +echo -n ffff 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/pkey
> +echo -n 0 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/instance
> +echo -n 100 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/heartbeat
> +string="EVIC in Chassis 0x00066a00db000010, Slot 4, Ioc 1"
> +echo -n $string 			 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_string
> +
> +# Trigger the connection establishment process for the path by choosing required
> +# HCA and IB port combination.
> +
> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/vnic-mlx4_0-1/create_primary
> +
> +# In case of failover configuration, pass the parameters of the failover
> +# connection to the driver and trigger its connection establishment
> +# process.
> +
> +echo -n 00066a01de000037 		 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/ioc_guid
> +echo -n fe8000000000000100066a11de000037 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/dgid
> +echo -n ffff 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/pkey
> +echo -n 1 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/instance
> +echo -n 100 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/heartbeat
> +string="EVIC in Chassis 0x00066a00db000010, Slot 4, Ioc 1"
> +echo -n $string 			 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/ioc_string
> +
> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/vnic-mlx4_0-2/create_secondary
> +
> +# An interface can be deleted by echoing the name of the interface to be deleted
> +# to delete_vnic file
> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/delete_vnic


This clearly shows the advantage of being able to use echo
for configuration.
