From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.6 0/2] r8169: vlan hwaccel fixes
Date: Thu, 21 Oct 2004 20:57:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022005737.GA1945@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After taking a little time to implement vlan hwaccl features for the
r8169 driver, I discovered that someone had already beaten me to it! :-)

Anyway, at least the experience put me in an ideal position to review
the changes that had already been made.  I found a couple of places that
need some work.

Patch 1:

The return value of rtl8169_tx_vlan_tag() is not being
endian-swapped to little endian.  The hardware registers are little
endian, even though the vlan tag value in this register (16-bits only)
is big endian -- confusing!  Anyway, I'll be posting a follow-up patch
to correct this.

Patch 2:

The RxVlan bit in the CPlusCmd register is being turned-on in
rtl8169_vlan_rx_register() without regard to the value passed-in for
grp.  rtl8169_vlan_rx_register() is called w/ a non-NULL grp value when
the first vlan interface is created, then w/ a NULL grp value when the
last vlan interface is removed.

Similarly, the RxVlan bit in the CPlusCmd register is being turned-off
in rtl8169_vlan_rx_kill_vid() without regard to anything.  This function
is called when vlan interfaces are removed, but there may still be other
vlan interfaces still associated with the physical interface.

The net effect of the status quo is that vlan hwaccel is enabled after
the first vlan interfaces is created, UNTIL a vlan interface is removed.
After a single vlan interface is removed, no vlan hwaccel will occur (on
receive) until another vlan interface is created.  The second follow-up
patch I post will correct this by turning-on the RxVlan bit when
rtl8169_vlan_rx_register() is called w/ a non-NULL grp value and
turning-off the RxVlan bit when it is called w/ a NULL grp value.
Manipulation of the RxVlan bit will be removed from
rtl8169_vlan_rx_kill_vid().

Patches to follow...

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
