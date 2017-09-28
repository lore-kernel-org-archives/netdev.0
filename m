From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] skbuff: Add the offload_mr_fwd_mark field
Date: Thu, 28 Sep 2017 19:34:09 +0200
Message-ID: <20170928173415.15551-2-jiri@resnulli.us>
References: <20170928173415.15551-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:46153 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdI1ReT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:34:19 -0400
Received: by mail-wm0-f65.google.com with SMTP id m72so3791255wmc.1
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 10:34:18 -0700 (PDT)
In-Reply-To: <20170928173415.15551-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Similarly to the offload_fwd_mark field, the offload_mr_fwd_mark field is
used to allow partial offloading of MFC multicast routes.

Switchdev drivers can offload MFC multicast routes to the hardware by
registering to the FIB notification chain. When one of the route output
interfaces is not offload-able, i.e. has different parent ID, the route
cannot be fully offloaded by the hardware. Examples to non-offload-able
devices are a management NIC, dummy device, pimreg device, etc.

Similar problem exists in the bridge module, as one bridge can hold
interfaces with different parent IDs. At the bridge, the problem is solved
by the offload_fwd_mark skb field.

Currently, when a route cannot go through full offload, the only solution
for a switchdev driver is not to offload it at all and let the packet go
through slow path.

Using the offload_mr_fwd_mark field, a driver can indicate that a packet
was already forwarded by hardware to all the devices with the same parent
ID as the input device. Further patches in this patch-set are going to
enhance ipmr to skip multicast forwarding to devices with the same parent
ID if a packets is marked with that field.

The reason why the already existing "offload_fwd_mark" bit cannot be used
is that a switchdev driver would want to make the distinction between a
packet that has already gone through L2 forwarding but did not go through
multicast forwarding, and a packet that has already gone through both L2
and multicast forwarding.

For example: when a packet is ingressing from a switchport enslaved to a
bridge, which is configured with multicast forwarding, the following
scenarios are possible:
 - The packet can be trapped to the CPU due to exception while multicast
   forwarding (for example, MTU error). In that case, it had already gone
   through L2 forwarding in the hardware, thus A switchdev driver would
   want to set the skb->offload_fwd_mark and not the
   skb->offload_mr_fwd_mark.
 - The packet can also be trapped due to a pimreg/dummy device used as one
   of the output interfaces. In that case, it can go through both L2 and
   (partial) multicast forwarding inside the hardware, thus a switchdev
   driver would want to set both the skb->offload_fwd_mark and
   skb->offload_mr_fwd_mark.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellaox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/skbuff.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19e64bf..ada8214 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -772,6 +772,7 @@ struct sk_buff {
 	__u8			remcsum_offload:1;
 #ifdef CONFIG_NET_SWITCHDEV
 	__u8			offload_fwd_mark:1;
+	__u8			offload_mr_fwd_mark:1;
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 	__u8			tc_skip_classify:1;
-- 
2.9.5
