From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v2 8/8] macvlan: add FDB bridge ops and macvlan
 flags
Date: Thu, 12 Apr 2012 01:09:38 -0700
Message-ID: <4F868DC2.5050301@intel.com>
References: <20120412064858.3112.65818.stgit@jf-dev1-dcblab> <20120412065754.3112.31357.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, davem@davemloft.net,
	bhutchings@solarflare.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com
To: mst@redhat.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41775 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab2DLIJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 04:09:40 -0400
In-Reply-To: <20120412065754.3112.31357.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/11/2012 11:57 PM, John Fastabend wrote:
> This adds FDB bridge ops to the macvlan device passthru mode.
> Additionally a flags field was added and a NOPROMISC bit to
> allow users to use passthru mode without the driver calling
> dev_set_promiscuity(). The flags field is a u16 placed in a
> 4 byte hole (consuming 2 bytes) of the macvlan_dev struct.
> 
> We want to do this so that the macvlan driver or stack
> above the macvlan driver does not have to process every
> packet. For the use case where we know all the MAC addresses
> of the endstations above us this works well.
> 
> This patch is a result of Roopa Prabhu's work. Follow up
> patches are needed for VEPA and VEB macvlan modes.
> 
> v2: Change from distinct nopromisc mode to a flags field to
>     configure this. This avoids the tendency to add a new
>     mode every time we need some slightly different behavior.
> 
> CC: Roopa Prabhu <roprabhu@cisco.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 

oops this introduces an error in dev_set_promiscuity and I missed
adding flags to macvlan_fill_info() and the change routine
macvlan_changelink(). As it stands the flags can only be set at
creation time and can not be queried. I'll submit a v3 with this
fixup in the morning.

I suspect the addition below should be good enough. might try
to clean up the changelink logic a bit first.

---

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index df782c0..65c6d26 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -350,7 +350,7 @@ static int macvlan_stop(struct net_device *dev)

        if (vlan->port->passthru) {
                if (!(vlan->flags & MACVLAN_FLAG_NOPROMISC))
-                       dev_set_promiscuity(lowerdev, 1);
+                       dev_set_promiscuity(lowerdev, -1);
                goto hash_del;
        }

@@ -808,6 +808,19 @@ static int macvlan_changelink(struct net_device *dev,
        struct macvlan_dev *vlan = netdev_priv(dev);
        if (data && data[IFLA_MACVLAN_MODE])
                vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+       if (data && data[IFLA_MACVLAN_FLAGS]) {
+               __u16 flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
+
+               flags &= MACVLAN_FLAG_NOPROMISC;
+
+               if ((flags ^ vlan->flags) && (flags & MACVLAN_FLAG_NOPROMISC))
+                       dev_set_promiscuity(vlan->lowerdev, -1);
+               else if ((flags ^ vlan->flags) &&
+                        !(flags & MACVLAN_FLAG_NOPROMISC))
+                       dev_set_promiscuity(vlan->lowerdev, 1);
+
+               vlan->flags = flags;
+       }
        return 0;
 }

@@ -823,6 +836,8 @@ static int macvlan_fill_info(struct sk_buff *skb,

        if (nla_put_u32(skb, IFLA_MACVLAN_MODE, vlan->mode))
                goto nla_put_failure;
+       if (nla_put_u16(skb, IFLA_MACVLAN_FLAGS, vlan->flags))
+               goto nla_put_failure;
        return 0;

 nla_put_failure:
[root@jf-dev1-dcblab net-n
