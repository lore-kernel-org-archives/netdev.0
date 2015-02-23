From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Sun, 22 Feb 2015 18:20:44 -0800
Message-ID: <54EA8E7C.90401@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57131 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbbBWCVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 21:21:30 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPieH-0028rc-NT
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 02:21:29 +0000
In-Reply-To: <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2015 11:26 AM, Florian Fainelli wrote:
> In order to support bridging offloads in DSA switch drivers, select
> NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
> NDOs that we are required to implement.
>
> To facilitate the integratation at the DSA driver level, we implement 3
> types of operations:
>

Hi Florian,

>
> +/* Return a bitmask of all ports being currently bridged. Note that on
> + * leave, the mask will still return the bitmask of ports currently bridged,
> + * prior to port removal, and this is exactly what we want.
> + */
> +static u32 dsa_slave_br_port_mask(struct dsa_switch *ds)
> +{
> +	unsigned int port;
> +	u32 mask = 0;
> +
> +	for (port = 0; port < DSA_MAX_PORTS; port++) {
> +		if (!((1 << port) & ds->phys_port_mask))
> +			continue;
> +
> +		if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT)
> +			mask |= 1 << port;

Problem is that the function can be called through dsa_slave_netdevice_event
before the slave devices are fully initialized.

After adding

+               if (!ds->ports[port]) {
+                       netdev_err(bridge,
+                                  "No ports data for port %d, mask=0x%x\n",
+                                  port, ds->phys_port_mask);
+                       continue;
+               }

and with some more debug messages added to dsa_switch_setup(), I see the following.

[   14.187290] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 1(port1)
[   14.272605] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 2(port2)
[   14.353118] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 3(port3)
[   14.472002] br0: No ports data for port 3, mask=0x1e
[   14.472053] br0: No ports data for port 4, mask=0x1e
[   14.472753] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 4(host2esb)

This happens if I add the bridge configuration to /etc/network/interfaces instead
of creating the bridge manually. Apparently dsa_switch_setup() is not yet complete
when dsa_slave_netdevice_event is executed to handle a state change on one of its
newly created slave interfaces.

The relevant information from /etc/network/interfaces is:

auto br0

iface port1 inet manual
iface port2 inet manual

iface br0 inet dhcp
	bridge_ports port1 port2
	up ifconfig br0 mtu 1492

Any idea how to best address this ?

Thanks,
Guenter
