From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v6 0/4] export device physical port id to userspace
Date: Mon, 29 Jul 2013 18:16:48 +0200
Message-ID: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:45592 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab3G2QQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 12:16:57 -0400
Received: by mail-wg0-f51.google.com with SMTP id a12so1290250wgh.18
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 09:16:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is based on patch by Narendra_K@Dell.com
Once device which can change phys port id during its lifetime adopts this,
NETDEV_CHANGEPHYSPORTID event will be added and driver will call
call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
the change to userspace.

v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped up ndo call)
v2->v3: adjusted patch 1 commit message
v3->v4: used "%phN" for sysfs printf as suggested by DaveM
        added igb/igbvf implementation as requested by Or Gerlitz
v4->v5: used prandom_u32 to generate id in igb_probe
        removed duplicate code in ibgvf_probe
        pushed dev_err string into one line in igbvf_refresh_ppid
v5->v6: use uuid_le_gen for generating 16-byte phys port id for igb/igbvf
	as suggested by BenH

1) Why do we need this, and why do existing facilities fail to provide
   a way to accomplish this?

Currenty there's very hard to tell if two netdevs are using the same physical
port. For sr-iov this can be get by sysfs. For other mechanisms, like NPAR
there's very hard to do it (one must learn it from NIC BIOS). But even for
sr-iov there's no way to say if two netdevs are using the same phys port when
these are passed through to virtual guests.

This patchset provides the generic way of letting this information know to
userspace. This info can be used by apps like NetworkManager, teamd, Wicked,
ovs daemon, etc, to do smarter bonding decisions.

2) Why is the physical port ID defined as a 32 byte opaque cookie?
   What formats and layouts need to be accomodated, and which
   influenced the design of the ID?

For user to distinguish if two netdevs are using the same port, he only needs
to compare their phys port ids. Nothing else is needed. This id has no
structure for security reasons. VF should not know anything about PF.

3) Are IDs globally unique?  Why or why not?  If IDs should be
   globally unique, but only in certain cases, what exactly are those
   cases.

Most of the time only uniqueness needed is in scope of single machine.
There might be case when the id should be unique between couple of machines
in virtualization environment. Given that for example for igb/igbvf 16B uuid
is used, there is no problem for this case as well. But each driver can
implement this differently focusing the hw capabilities and needs.

Jiri Pirko (4):
  net: add ndo to get id of physical port of the device
  rtnl: export physical port id via RT netlink
  net: export physical port id via sysfs
  igb/igbvf: implement ndo_get_phys_port_id

 drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
 drivers/net/ethernet/intel/igb/igb.h       |  3 +++
 drivers/net/ethernet/intel/igb/igb_main.c  | 37 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igbvf/igbvf.h   |  4 ++++
 drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
 drivers/net/ethernet/intel/igbvf/netdev.c  | 38 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.c      | 34 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
 include/linux/netdevice.h                  | 20 ++++++++++++++++
 include/uapi/linux/if_link.h               |  1 +
 net/core/dev.c                             | 18 ++++++++++++++
 net/core/net-sysfs.c                       | 22 +++++++++++++++++
 net/core/rtnetlink.c                       | 25 +++++++++++++++++++-
 13 files changed, 203 insertions(+), 2 deletions(-)

-- 
1.8.1.4
