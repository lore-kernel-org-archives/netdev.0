From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [RFC][bonding] Improve VLAN support on top of bonding
Date: Tue, 15 Jul 2003 16:55:18 +0300 (IDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.33.0307151503450.13870-100000@jrslxjul1.npdj.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amir Noam <amir.noam@intel.com>, Noam Marom <noam.marom@intel.com>,
	Shmulik Hen <shmulik.hen@intel.com>,
	Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: bond-devel <bonding-devel@lists.sourceforge.net>,
	linux-net <linux-net@vger.kernel.org>,
	linux-netdev <netdev@oss.sgi.com>,
	"David S. Miller" <davem@redhat.com>,
	Ben Greear <greearb@candelatech.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jay Vosburgh <fubar@us.ibm.com>
List-Id: netdev.vger.kernel.org

Hi All,

	Currently, when using 8021q VLAN module to work on top of bonding,
everything seems to work OK, but there are some issues that will not work
according to our analysis. For example, any self-generated packets sent by
bonding itself (e.g. arp-mon, TLB learning packets, ALB arp replies, etc.)
do not have the VLAN id tag in them, and thus will not go through the
switch. Also, in order to configure a VLAN interface, the underlying
interface must be configured first to IP address 0.0.0.0. Since arp-mon
uses bond's IP address, this might cause further problems. Other issue
we've still not investigated, like what happens if bonding needs to parse
a tagged packet for layer2/layer3 data, might still create more problems.

	We have come up with some possible solution we would like to get
comments on. First of all, our main guide line was not to duplicate code
segments that are in the VLAN module and put them in bonding. Further, we
figured bonding should not need to know about how the VLAN module handles
hardware acceleration. On the other hand, bonding does need to know what
VLAN tags are being used so it may send packets successfully through all
the switch ports, so some kind of policy needs to be defined.

So here is what we've come up with until now.

1. Configuration
   Need to decide between:
   a. Block VLAN add/del operations when bond has no slaves.
   b. Block enslave/release of slaves when bond has no VLAN tags (needs a
      module parameter).
   c. Remove limitation of IP 0.0.0.0.

2. Indication
   Need to decide between:
   a. Add notification mechanism in VLAN module that bonding may register
      to listen to, and thus keep track of VLAN tags added/removed.
   b. Register to listen to net device register/unregister notifications
      to monitor creation/destruction of VLAN devices. Requires support
      for figuring out if a net device is a VLAN device, and also two vlan
      calls like get_realdev() and get_vlan_id() exported.
   c. Parse every packet going through bonding to collect VLAN tags.

3. Monitoring
   In order for bonding to be able to generate tagged packets on its own,
   two major changes need to be done. One is split the vlan_start_xmit
   function into insert_tag() and vlan_xmit(), so bonding may choose the
   required tag on its own, and let 8021q to the transmit. A second change
   is to split arp_send() into arp_create() and arp_send(), so bonding may
   pass all the usual parameters for arp creation, get a complete arp
   packet and then pass it to 8021q for tag insertion on transmission.


Hardware acceleration
=====================
	When coming to analyze what is required for adding support for
VLAN hardware acceleration on top of bonding, other issues come to mind.
Since add/del operations are defined and handshakes are performed between
the VLAN module and the device driver, tracking VLAN tags is simpler and
commands should just be propagated to the slaves. Enslaving/releasing
slaves should also be simple and just require adding/removing existing
VLAN tags from them. The problem is how to handle configuration issues.

  1. Since adding the first VLAN tag requires some additional handshake,
     can bonding support that operation on a bond that already has slaves
     and is running?
  2. What about removing the last tag from a bond?
  3. Should the bond device declare itself as "VLAN challenged" before
     registering and remove that limitation only once it has slaves?
  4. Should the bond declare itself as fully hardware acceleration capable
     to benefit from "strong" slaves while performing regular VLAN
     inserting/stripping for "weak" slaves?
  5. How can bonding generate untagged packets and send them via
     hardware acceleration capable slaves (e.g. 802.3ad LACPDU) ?


-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |


