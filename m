From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud filters
 in i40e
Date: Wed, 11 Oct 2017 14:56:35 +0200
Message-ID: <20171011125635.GD2039@nanopsycho>
References: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:45501 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbdJKM4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 08:56:37 -0400
Received: by mail-wm0-f53.google.com with SMTP id q124so4503855wmb.0
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 05:56:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150768099999.5320.1633617713417675266.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 02:24:12AM CEST, amritha.nambiar@intel.com wrote:
>This patch series enables configuring cloud filters in i40e
>using the tc-flower classifier. The classification function
>of the filter is to match a packet to a class. cls_flower is
>extended to offload classid to hardware. The offloaded classid
>is used direct matched packets to a traffic class on the device. 
>The approach here is similar to the tc 'prio' qdisc which uses
>the classid for band selection. The ingress qdisc is called ffff:0,
>so traffic classes are ffff:1 to ffff:8 (i40e has max of 8 TCs).


NACK. This clearly looks like abuse of classid to something
else. Classid is here to identify qdisc instance. However, you use it
for hw tclass identification. This is mixing of apples and oranges.

Why?

Please don't try to abuse things! This is not nice.




>TC0 is minor number 1, TC1 is minor number 2 etc.
>
>The cloud filters are added for a VSI and are cleaned up when
>the VSI is deleted. The filters that match on L4 ports needs
>enhanced admin queue functions with big buffer support for
>extended fields in cloud filter commands.
>
>Example:
># tc qdisc add dev eth0 ingress
># ethtool -K eth0 hw-tc-offload on
>
>Match Dst IPv4,Dst Port and route to TC1:
># tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>  skip_sw classid ffff:2
>
># tc filter show dev eth0 parent ffff:
>filter pref 1 flower chain 0
>filter pref 1 flower chain 0 handle 0x1 classid ffff:2
>  eth_type ipv4
>  ip_proto udp
>  dst_ip 192.168.1.1
>  dst_port 22
>  skip_sw
>  in_hw
>
>v4: classid based approach to set traffic class for matched packets.
>
>Authors:
>Amritha Nambiar <amritha.nambiar@intel.com>
>Kiran Patil <kiran.patil@intel.com>
>Anjali Singhai Jain <anjali.singhai@intel.com>
>Jingjing Wu <jingjing.wu@intel.com>
>---
>
>Amritha Nambiar (6):
>      cls_flower: Offload classid to hardware
>      i40e: Map TCs with the VSI seids
>      i40e: Cloud filter mode for set_switch_config command
>      i40e: Admin queue definitions for cloud filters
>      i40e: Clean up of cloud filters
>      i40e: Enable cloud filters via tc-flower
>
>
> drivers/net/ethernet/intel/i40e/i40e.h             |   55 +
> drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  143 +++
> drivers/net/ethernet/intel/i40e/i40e_common.c      |  193 ++++
> drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    2 
> drivers/net/ethernet/intel/i40e/i40e_main.c        |  941 +++++++++++++++++++-
> drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   18 
> drivers/net/ethernet/intel/i40e/i40e_type.h        |   10 
> .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  113 ++
> include/net/pkt_cls.h                              |    1 
> net/sched/cls_flower.c                             |    2 
> 10 files changed, 1439 insertions(+), 39 deletions(-)
>
>--
