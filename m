From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 56221] New: bonding: ARP monitoring doesn't work with
 bridges
Date: Thu, 4 Apr 2013 09:46:33 -0700
Message-ID: <20130404094633.052fa5ee@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33288 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763137Ab3DDQqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:46:37 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so1521115pdj.27
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 09:46:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 4 Apr 2013 06:58:50 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 56221] New: bonding: ARP monitoring doesn't work with bridges


https://bugzilla.kernel.org/show_bug.cgi?id=56221

           Summary: bonding: ARP monitoring doesn't work with bridges
           Product: Networking
           Version: 2.5
    Kernel Version: 3.8.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: c.ruppert@babiel.com
        Regression: No


Hi,

we tried to setup VLANs and bridges on top of the bonding device.

Creating a bond over eth0 and eth1:
eth0 \
      --> bond0
eth1 /

Adding VLANs 1, 2 and 3 on top of the bond:
       --> bond0.1
      /
bond0 ---> bond0.2
      \
       --> bond0.3

And finally adding bridges on top of the VLAN bonds:
bond0.1 -> br1
bond0.2 -> br2
bond0.3 -> br3

Those three VLANs are all tagged. br1 will also get the default route.

So the ARP monitoring doesn't work as soon as a bridge gets the default route
(or at least the route to the ARP IP target).
<snip>
[76655.096076] bonding: bond0: no path to arp_ip_target 172.16.0.1 via rt.dev
br1
</snip>

I then tried it with just the VLANs (no bridges) and it works fine.
Then I tried it with just bridges and no VLAN - it doesn't.

Here are some steps to reproduce it:
ifconfig eth0 0.0.0.0 up
ifconfig eth1 0.0.0.0 up

modprobe bonding mode="active-backup" primary="eth0" arp_interval=3000
arp_ip_target="172.16.0.1"

ifconfig bond0 0.0.0.0 up
ifenslave bond0 eth0
ifenslave bond0 eth1

brctl addbr br1 
brctl addif br1 bond0
ifconfig br1 172.16.0.2/28 up

With tcpdump you'll see that there are no ARP requests/pings at all and in
either dmesg or the kernel log you'll notice the "no path to ..." warnings.

So I took a look into the bonding driver souces (mainly bond_main.c):
The bonding driver asks for the route to the arp_ip_target which is br1 in this
case and it then compares it against the bond device(s) so bond0 and/or
bond0.1, bond0.2 and so forth. So neither bond->dev nor vlan_dev will ever be
the same as rt->dst.dev as long as you add the route to the bridge.
There is no check for bridged devices at all.
The driver should get an event/notify when the device (bond) became a member of
a bridge or has been removed and so forth, basically the same that has been
added for the VLAN stuff.

Just let me know if you need anything else. Thanks in advance.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
