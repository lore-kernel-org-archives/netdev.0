From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Add support for netconsole driver used on bridge device with VIF
 attached
Date: Thu, 20 Jun 2013 11:25:51 +0300
Message-ID: <20130620082550.GA19444@yuval-pc.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yuval.shaia@oracle.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	ian.campbell@citrix.com, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37801 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab3FTI0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 04:26:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When starting a VM which has virtual interface attached to the same
bridge which is used for netconsole the system freeze for 60 then the
following message pops out to system console:
"Error: Device 0 (vif) could not be connected. Hotplug scripts not
working."

When trying to do the opposite, i.e. first create VM and then run
netconsole i got the following error:
"#524 - vif2.0 doesn't support polling, aborting."

Following is my setup:

----------                              ----------
| VM A1  |------vif1.0----->|           | Host B |
|--------|                  |--xenbr0   |        |
| Host A |--bond0 (eth0)--->|           |        |
----------          |                   ----------
                    |                        |
                    V                        V
--------------------------------------------------
|                      LAN                       |
--------------------------------------------------

I'm using netconsole to capture logs from Host-A and send them to
Host-B. Host-A and Host-B are separate hosts (running XEN) which are
connected to the same LAN.
netconsole parameters:
netconsole=1111@hostA-ip/xenbr0,2002@hostB-ip/hostB-mac

As i see it, netconsole driver requires ndo_poll_controller from the
device's controlling driver (function __netpoll_setup in
net/core/netpoll.c), a thing that is not supported currently in
xen_netback driver which is the driver that runs on dom0 and serve VM's
virtual interface.
call flow: init_netconsole() in netconsole.c -> alloc_param_target() ->
netpoll_setup() in netpoll.c -> __netpoll_setup() which check if
ndo_poll_controller().

Looks like the underlying issue is that br_netpoll_setup() requires that
all members of the bridge support netpoll before allowing netpoll to be
enabled on the bridge itself.

This seems like an odd restriction in the bridge driver since in
principal only the port over which the netpoll traffic will be going
will need netpoll, but perhaps the bridge can't tell which port that is
or is going to be.
It is obvious why the bridge device might need an ndo_poll_controller
hook but it is unclear why the netback device would need one.

Hopefully the bridge isn't flooding/broadcasting netpoll to all ports,
at least in the case where DST IP and MAC have been specified. That
would be rather inefficient, especially when most ports go to virtual
machines.

Yuval
