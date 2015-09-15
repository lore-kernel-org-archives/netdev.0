From: roopa <roopa@cumulusnetworks.com>
Subject: Re: kernel 4.2 : "bridge vlan" command return empty result (works
 with kernel 4.1.3)
Date: Tue, 15 Sep 2015 12:02:34 -0700
Message-ID: <55F86B4A.7090001@cumulusnetworks.com>
References: <1167950469.57377315.1442338762965.JavaMail.zimbra@oxygem.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Alexandre DERUMIER <aderumier@odiso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34355 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbIOTCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 15:02:37 -0400
Received: by padhy16 with SMTP id hy16so184239385pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 12:02:36 -0700 (PDT)
In-Reply-To: <1167950469.57377315.1442338762965.JavaMail.zimbra@oxygem.tv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/15, 10:39 AM, Alexandre DERUMIER wrote:
> Hi,
>
> since kernel 4.2, "bridge vlan" command return empty result.
>
>
> kernel 4.1.3
> ------------
> # bridge vlan
> port	vlan ids
> eth0	 1 PVID Egress Untagged
> 	 90
> 	 91
> 	 92
> 	 93
> 	 94
> 	 95
> 	 96
> 	 97
> 	 98
> 	 99
> 	 100
>
> vmbr0	 1 PVID Egress Untagged
> 	 94
>
>
>
> kernel 4.2
> ----------------
> # bridge vlan
> port	vlan ids
>
>
>
> Note that vlans are correctly working,it seem that is just the display.
>
> tcpdump -e -i vmbr0
>
> 19:38:08.005055 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ethertype IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 339613, win 5523, length 0
> 19:38:08.007730 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ethertype IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 342145, win 5568, length 0
> 19:38:08.010977 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ethertype IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 344677, win 5614, length 0
> 19:3
I was able to reproduce this when there is a bond in the system.

Looks like this was due to 85fdb956726ff2a ("switchdev: cut over to new 
switchdev_port_bridge_getlink").
When CONFIG_SWITCHDEV is off, nodes that use switchdev api for 
ndo_bridge_getlink (example, bonds, teams, rocker) can return
-EOPNOTSUPP. The problem went away on my box with the following patch. I 
will submit an official patch in a bit.
Do you have a bond in your system ?.

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 01ced4a..bdb3842 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3013,6 +3013,7 @@ static int rtnl_bridge_getlink(struct sk_buff 
*skb, struct
         u32 portid = NETLINK_CB(cb->skb).portid;
         u32 seq = cb->nlh->nlmsg_seq;
         u32 filter_mask = 0;
+       int err;

         if (nlmsg_len(cb->nlh) > sizeof(struct ifinfomsg)) {
                 struct nlattr *extfilt;
@@ -3033,20 +3034,25 @@ static int rtnl_bridge_getlink(struct sk_buff 
*skb, stru
                 struct net_device *br_dev = 
netdev_master_upper_dev_get(dev);

                 if (br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
-                       if (idx >= cb->args[0] &&
- br_dev->netdev_ops->ndo_bridge_getlink(
-                                   skb, portid, seq, dev, filter_mask,
-                                   NLM_F_MULTI) < 0)
-                               break;
+                       if (idx >= cb->args[0]) {
+                               err = 
br_dev->netdev_ops->ndo_bridge_getlink(
+                                               skb, portid, seq, dev,
+                                               filter_mask, NLM_F_MULTI);
+                               if ( err < 0 && err != -EOPNOTSUPP)
+                                       break;
+                       }
                         idx++;
                 }

                 if (ops->ndo_bridge_getlink) {
-                       if (idx >= cb->args[0] &&
-                           ops->ndo_bridge_getlink(skb, portid, seq, dev,
-                                                   filter_mask,
-                                                   NLM_F_MULTI) < 0)
-                               break;
+                       if (idx >= cb->args[0]) {
+                               err = ops->ndo_bridge_getlink(skb, portid,
+                                                             seq, dev,
+ filter_mask,
+ NLM_F_MULTI);
+                               if ( err < 0 && err != -EOPNOTSUPP)
+                                       break;
+                       }
                         idx++;
                 }
         }
