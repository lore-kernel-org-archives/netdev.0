From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 15 Oct 2015 12:06:01 +1100
Message-ID: <20151015120601.7560df35@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/switchdev/switchdev.c

between commit:

  87aaf2caed84 ("switchdev: check if the vlan id is in the proper vlan range")

from the net tree and commits:

  7ea6eb3f56f4 ("switchdev: introduce transaction item queue for attr_set and obj_add")
  ab0690023018 ("net: switchdev: abstract object in add/del ops"

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/switchdev/switchdev.c
index 77f5d17e2612,b8aaf820ef65..000000000000
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@@ -16,7 -16,7 +16,8 @@@
  #include <linux/notifier.h>
  #include <linux/netdevice.h>
  #include <linux/if_bridge.h>
 +#include <linux/if_vlan.h>
+ #include <linux/list.h>
  #include <net/ip_fib.h>
  #include <net/switchdev.h>
  
@@@ -635,32 -722,33 +723,35 @@@ static int switchdev_port_br_afspec(str
  		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
  			return -EINVAL;
  		vinfo = nla_data(attr);
 +		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
 +			return -EINVAL;
- 		vlan->flags = vinfo->flags;
+ 		vlan.flags = vinfo->flags;
  		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
- 			if (vlan->vid_begin)
+ 			if (vlan.vid_begin)
+ 				return -EINVAL;
+ 			vlan.vid_begin = vinfo->vid;
+ 			/* don't allow range of pvids */
+ 			if (vlan.flags & BRIDGE_VLAN_INFO_PVID)
  				return -EINVAL;
- 			vlan->vid_begin = vinfo->vid;
  		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
- 			if (!vlan->vid_begin)
+ 			if (!vlan.vid_begin)
  				return -EINVAL;
- 			vlan->vid_end = vinfo->vid;
- 			if (vlan->vid_end <= vlan->vid_begin)
+ 			vlan.vid_end = vinfo->vid;
+ 			if (vlan.vid_end <= vlan.vid_begin)
  				return -EINVAL;
- 			err = f(dev, &obj);
+ 			err = f(dev, &vlan.obj);
  			if (err)
  				return err;
- 			memset(vlan, 0, sizeof(*vlan));
+ 			memset(&vlan, 0, sizeof(vlan));
  		} else {
- 			if (vlan->vid_begin)
+ 			if (vlan.vid_begin)
  				return -EINVAL;
- 			vlan->vid_begin = vinfo->vid;
- 			vlan->vid_end = vinfo->vid;
- 			err = f(dev, &obj);
+ 			vlan.vid_begin = vinfo->vid;
+ 			vlan.vid_end = vinfo->vid;
+ 			err = f(dev, &vlan.obj);
  			if (err)
  				return err;
- 			memset(vlan, 0, sizeof(*vlan));
+ 			memset(&vlan, 0, sizeof(vlan));
  		}
  	}
  
