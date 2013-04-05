From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Fw: [Bug 56221] New: bonding: ARP monitoring doesn't work with bridges
Date: Thu, 04 Apr 2013 19:11:25 -0700
Message-ID: <25308.1365127885@death.nxdomain>
References: <20130404094633.052fa5ee@samsung-9>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	c.ruppert@babiel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:47835 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab3DECLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 22:11:32 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 4 Apr 2013 22:11:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D011AC90050
	for <netdev@vger.kernel.org>; Thu,  4 Apr 2013 22:11:27 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r352BRS7332364
	for <netdev@vger.kernel.org>; Thu, 4 Apr 2013 22:11:27 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r352BQRa019993
	for <netdev@vger.kernel.org>; Thu, 4 Apr 2013 23:11:27 -0300
In-reply-to: <20130404094633.052fa5ee@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger <stephen@networkplumber.org> wrote:
>Begin forwarded message:
>
>Date: Thu, 4 Apr 2013 06:58:50 -0700
>From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
>To: "stephen@networkplumber.org" <stephen@networkplumber.org>
>Subject: [Bug 56221] New: bonding: ARP monitoring doesn't work with bridges
>
>
>https://bugzilla.kernel.org/show_bug.cgi?id=56221
>
>           Summary: bonding: ARP monitoring doesn't work with bridges
>           Product: Networking
>           Version: 2.5
>    Kernel Version: 3.8.5
>          Platform: All
>        OS/Version: Linux
>              Tree: Mainline
>            Status: NEW
>          Severity: normal
>          Priority: P1
>         Component: Other
>        AssignedTo: shemminger@linux-foundation.org
>        ReportedBy: c.ruppert@babiel.com
>        Regression: No
>
>
>Hi,
>
>we tried to setup VLANs and bridges on top of the bonding device.
>
>Creating a bond over eth0 and eth1:
>eth0 \
>      --> bond0
>eth1 /
>
>Adding VLANs 1, 2 and 3 on top of the bond:
>       --> bond0.1
>      /
>bond0 ---> bond0.2
>      \
>       --> bond0.3
>
>And finally adding bridges on top of the VLAN bonds:
>bond0.1 -> br1
>bond0.2 -> br2
>bond0.3 -> br3
>
>Those three VLANs are all tagged. br1 will also get the default route.
>
>So the ARP monitoring doesn't work as soon as a bridge gets the default route
>(or at least the route to the ARP IP target).
><snip>
>[76655.096076] bonding: bond0: no path to arp_ip_target 172.16.0.1 via rt.dev
>br1
></snip>
>
>I then tried it with just the VLANs (no bridges) and it works fine.
>Then I tried it with just bridges and no VLAN - it doesn't.
>
>Here are some steps to reproduce it:
>ifconfig eth0 0.0.0.0 up
>ifconfig eth1 0.0.0.0 up
>
>modprobe bonding mode="active-backup" primary="eth0" arp_interval=3000
>arp_ip_target="172.16.0.1"
>
>ifconfig bond0 0.0.0.0 up
>ifenslave bond0 eth0
>ifenslave bond0 eth1
>
>brctl addbr br1 
>brctl addif br1 bond0
>ifconfig br1 172.16.0.2/28 up
>
>With tcpdump you'll see that there are no ARP requests/pings at all and in
>either dmesg or the kernel log you'll notice the "no path to ..." warnings.
>
>So I took a look into the bonding driver souces (mainly bond_main.c):
>The bonding driver asks for the route to the arp_ip_target which is br1 in this
>case and it then compares it against the bond device(s) so bond0 and/or
>bond0.1, bond0.2 and so forth. So neither bond->dev nor vlan_dev will ever be
>the same as rt->dst.dev as long as you add the route to the bridge.
>There is no check for bridged devices at all.
>The driver should get an event/notify when the device (bond) became a member of
>a bridge or has been removed and so forth, basically the same that has been
>added for the VLAN stuff.

	The bonding driver is (in bond_arp_send_all) using the routing
table to try and figure out what VLAN tag (if any) needs to be added to
the ARP it wants to send.  This is to handle the case of, e.g.,

	for an arp_ip_target of 10.0.0.1,

[ eth0, eth1 ] -> bond0 -> vlan123 { IP=10.0.0.2 }

	The case you describe is, however,

[ eth0, eth1 ] -> bond0 -> vlan123 -> bridge { IP=10.0.0.2 }

	in this case, with just the arp_ip_target of 10.0.0.1, it can't
find the VLAN because the arp_ip_target would be routed out a different
interface.

	It might be feasible to have the bonding code check the upper
dev(s) of the VLAN interface it looks up, but there's no guarantee that
the desired interface is only one layer above the VLAN (or there could
be netsted VLANs, which aren't handled by this bonding code).  E.g., in
here:

		vlan_id = 0;
		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
			rcu_read_lock();
			vlan_dev = __vlan_find_dev_deep(bond->dev,
							vlan->vlan_id);
			rcu_read_unlock();
			if (vlan_dev == rt->dst.dev) {
				vlan_id = vlan->vlan_id;
				pr_debug("basa: vlan match on %s %d\n",
				       vlan_dev->name, vlan_id);
				break;
			}
		}


	add an else for the if, that's something like

			} else {
				ndev = netdev_master_upper_dev_get_rcu(vlan_dev);
				if (ndev == rt->dst.dev) {
					vlan_id = vlan->vlan_id;
					vlan_dev = ndev; /* for confirm */
					break;
				}
			}

	and probably move the rcu_read_unlock() protection to the end of
the loop (or add another rcu_read block to the new code).  This isn't a
proper patch, I'm just kind of typing it out as I think about it before
I have to leave for the evening, so it's not tested or anything but in
principle could work.

	I was afraid initially that adding another check would be really
complicated, but this doesn't seem at first glance to be as awful as I
had feared.  I could be wrong, though.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
