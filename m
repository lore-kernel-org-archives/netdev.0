From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW
 bridging
Date: Mon, 23 Feb 2015 04:14:47 +0100
Message-ID: <20150223031447.GA19267@lunn.ch>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
 <54EA8E7C.90401@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47410 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752121AbbBWDRr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 22:17:47 -0500
Content-Disposition: inline
In-Reply-To: <54EA8E7C.90401@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2015 at 06:20:44PM -0800, Guenter Roeck wrote:
> On 02/17/2015 11:26 AM, Florian Fainelli wrote:
> >In order to support bridging offloads in DSA switch drivers, select
> >NET_SWITCHDEV to get access to the port_stp_update and parent_get_id
> >NDOs that we are required to implement.
> >
> >To facilitate the integratation at the DSA driver level, we implement 3
> >types of operations:
> >
> 
> Hi Florian,
> 
> >
> >+/* Return a bitmask of all ports being currently bridged. Note that on
> >+ * leave, the mask will still return the bitmask of ports currently bridged,
> >+ * prior to port removal, and this is exactly what we want.
> >+ */
> >+static u32 dsa_slave_br_port_mask(struct dsa_switch *ds)
> >+{
> >+	unsigned int port;
> >+	u32 mask = 0;
> >+
> >+	for (port = 0; port < DSA_MAX_PORTS; port++) {
> >+		if (!((1 << port) & ds->phys_port_mask))
> >+			continue;
> >+
> >+		if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT)
> >+			mask |= 1 << port;
> 
> Problem is that the function can be called through dsa_slave_netdevice_event
> before the slave devices are fully initialized.
> 
> After adding
> 
> +               if (!ds->ports[port]) {
> +                       netdev_err(bridge,
> +                                  "No ports data for port %d, mask=0x%x\n",
> +                                  port, ds->phys_port_mask);
> +                       continue;
> +               }
> 
> and with some more debug messages added to dsa_switch_setup(), I see the following.
> 
> [   14.187290] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 1(port1)
> [   14.272605] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 2(port2)
> [   14.353118] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 3(port3)
> [   14.472002] br0: No ports data for port 3, mask=0x1e
> [   14.472053] br0: No ports data for port 4, mask=0x1e
> [   14.472753] e1000e 0000:00:19.0 em1: [0]: Creating slave device for port 4(host2esb)
> 
> This happens if I add the bridge configuration to /etc/network/interfaces instead
> of creating the bridge manually. Apparently dsa_switch_setup() is not yet complete
> when dsa_slave_netdevice_event is executed to handle a state change on one of its
> newly created slave interfaces.
> 
> The relevant information from /etc/network/interfaces is:
> 
> auto br0
> 
> iface port1 inet manual
> iface port2 inet manual
> 
> iface br0 inet dhcp
> 	bridge_ports port1 port2

Hi Guenter

Does this actually matter? The ports which don't exists yet are not
being added to the bridge. The mask will come out correct. What
happens when port4 is made a member of the bridge? I expect it
works. It is the creation of the interface which triggers hotplug to
read interfaces and add the interface to the port.

It might however be a good idea to document somewhere that each
interface should be configured without assuming anything about the
state of other interfaces.

     Andrew
