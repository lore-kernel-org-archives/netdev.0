From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 20:44:16 +0000
Message-ID: <20160123204416.GC10826@n2100.arm.linux.org.uk>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
 <20160123190622.GA10826@n2100.arm.linux.org.uk>
 <20160123193705.GE3880@lunn.ch>
 <20160123194856.GB10826@n2100.arm.linux.org.uk>
 <20160123201647.GH3880@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:59084 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbcAWUoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 15:44:24 -0500
Content-Disposition: inline
In-Reply-To: <20160123201647.GH3880@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 09:16:47PM +0100, Andrew Lunn wrote:
> On Sat, Jan 23, 2016 at 07:48:57PM +0000, Russell King - ARM Linux wrote:
> > On Sat, Jan 23, 2016 at 08:37:05PM +0100, Andrew Lunn wrote:
> > > I'm testing on a 6172. But 6172 and 6176 are both in the same family
> > > 6352, and share the same driver.
> > 
> > Hmm, can't be that then.
> > 
> > > So you initially have lan1 in an bridge. I don't.
> 
> Running tcpdump on the device i'm trying to ping, there are ARP
> requests and replies. But the replies are never received by the
> target, arp -a shows <incomplete>.
> 
> Looking at the stats counters in debugfs, the packets are counted in
> in_unicast, but also sw_in_filtered.
> 
> Port 0 is lan0 and port 5 is the cpu port.
> 
> root@370-rd:/sys/kernel/debug/dsa0# cat regs
>     GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6  
>  0:  c874       0    1940  1d0f 1d0f 1d0f 1d0f 100f  e07    6 
>  1:   fa0       0     149     3    3    3    3    3 c03e    3 
>  2:   fa0    ffff     141     0    0    0    0    0    0    0 
>  3:     0    ffff     ea1  1721 1721 1721 1721 1721 1721 1721 
>  4:  6000     258     1e0   433  433  433  433  433 373f  433 
>  5:  3000      ff       0     0    0    0    0    0    0    0 
>  6:   fa0    1f0f       4    7f   7e   7d   7c   7b   7a   79 
>  7:  3331    707f    2001     0  fa1  fa2  fa3  fa4    0  fa6 

This shows port 0 is on vlan 0, but it should default to vlan 1 when
no vlans are configured.  The patch below should at least allow some
diagnosis of what's being requested, and when.

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index a43354ed0607..8a9cf67eb16d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1511,6 +1511,9 @@ int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	u16 vid;
 	int err = 0;
 
+	printk("%s: port %d vid %u-%u flags %x\n",
+		__func__, port, vlan->vid_begin, vlan->vid_end, vlan->flags);
+
 	mutex_lock(&ps->smi_mutex);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {


-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
