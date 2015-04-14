From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 09/24] switchdev: add new swdev bridge setlink
Date: Tue, 14 Apr 2015 07:30:45 +0200
Message-ID: <20150414053045.GA2063@nanopsycho.orion>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
 <1428905838-14920-10-git-send-email-sfeldma@gmail.com>
 <552C92F8.8030604@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37948 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbbDNFat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:30:49 -0400
Received: by wiun10 with SMTP id n10so8277324wiu.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:30:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <552C92F8.8030604@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 14, 2015 at 06:09:28AM CEST, roopa@cumulusnetworks.com wrote:
>On 4/12/15, 11:17 PM, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Add new swdev_port_bridge_setlink that can be used by drivers implementing
>>.ndo_bridge_setlink to set swdev bridge attributes.  Basically turn the raw
>>rtnl_bridge_setlink netlink into swdev attr sets.  Proper netlink attr policy
>>checking is done on the protinfo part of the netlink msg.
>>
>>Currently, for protinfo, only bridge port attrs BR_LEARNING and
>>BR_LEARNING_SYNC are parsed and passed to port driver.
>>
>>For afspec, VLAN objs are passed so swdev driver can set VLANs assigned to
>>SELF.  To illustrate with iproute2 cmd, we have:
>>
>>	bridge vlan add vid 10 dev sw1p1 self master
>>
>>To add VLAN 10 to port sw1p1 for both the bridge (master) and the device
>>(self).
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>>  include/net/switchdev.h   |    8 +++
>>  net/switchdev/switchdev.c |  152 +++++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 160 insertions(+)
>>

...

>>+static int swdev_port_br_afspec(struct net_device *dev,
>>+				struct nlattr *afspec,
>>+				int (*f)(struct net_device *dev,
>>+					 struct swdev_obj *obj))
>>+{
>>+	struct nlattr *attr;
>>+	struct bridge_vlan_info *vinfo;
>>+	struct swdev_obj obj = {
>>+		.id = SWDEV_OBJ_PORT_VLAN,
>>+	};
>>+	int rem;
>>+	int err;
>>+
>>+	nla_for_each_nested(attr, afspec, rem) {
>>+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
>>+			continue;
>>+		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
>>+			return -EINVAL;
>>+		vinfo = nla_data(attr);
>>+		obj.vlan.flags = vinfo->flags;
>>+		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
>>+			if (obj.vlan.vid_start)
>>+				return -EINVAL;
>>+			obj.vlan.vid_start = vinfo->vid;
>>+		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
>>+			if (!obj.vlan.vid_start)
>>+				return -EINVAL;
>>+			obj.vlan.vid_end = vinfo->vid;
>>+			if (obj.vlan.vid_end <= obj.vlan.vid_start)
>>+				return -EINVAL;
>>+			err = f(dev, &obj);
>>+			if (err)
>>+				return err;
>>+			memset(&obj.vlan, 0, sizeof(obj.vlan));
>>+		} else {
>>+			if (obj.vlan.vid_start)
>>+				return -EINVAL;
>>+			obj.vlan.vid_start = vinfo->vid;
>>+			obj.vlan.vid_end = vinfo->vid;
>>+			err = f(dev, &obj);
>>+			if (err)
>>+				return err;
>>+			memset(&obj.vlan, 0, sizeof(obj.vlan));
>>+		}
>>+	}
>>+
>>+	return 0;
>>+}
>>+
>
>This seems to be duplicating code that is already there in the bridge driver.
>
 
Sure, this is used by swdev_port_bridge_setlink, default ndo.
