From: Kris Murphy <kriskend@linux.vnet.ibm.com>
Subject: [PATCH 0/1] openvswitch: Add missing case OVS_TUNNEL_KEY_ATTR_PAD
Date: Thu, 16 Mar 2017 10:26:02 -0500
Message-ID: <cover.1489677257.git.kriskend@linux.vnet.ibm.com>
Cc: seroyer@linux.vnet.ibm.com, adreznec@linux.vnet.ibm.com,
        Kris Murphy <kriskend@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55005 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751841AbdCPP0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 11:26:23 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2GFDwU5135694
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:26:15 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0b-001b2d01.pphosted.com with ESMTP id 297nkn8khq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 11:26:15 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <kriskend@linux.vnet.ibm.com>;
        Thu, 16 Mar 2017 11:26:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recreate and error info:

Hit a new issue with OVS after updating to the Ubuntu 4.8 kernel from the
Ubuntu 4.4 kernel.

Iperf was used to send traffic between client VMs over VXLAN. The traffic did 
still flow, but every packet had to go to user space due to the flow creation 
failures, which drastically impacted performance and cpu utilization.

When using VXLAN, the following error is showing up in dmesg

openvswitch: netlink: Unknown IP tunnel attribute 14

Also there are tons of these errors in the openvswitch log

2017-03-01T15:50:47.860Z|00018|dpif(handler164)|WARN|system@ovs-system: failed 
to put[create] (Invalid argument) ufid:2d1a9aeb-7b24-4235-a208-a01f98237e60 
recirc_id(0),dp_hash(0/0),skb_pri

Debug showed that this attribute, OVS_TUNNEL_KEY_ATTR_PAD, was being seen in the 
switch statement in method, static int ip_tun_from_nlattr, in flow_netlink.c .  
Because there is no case for this attribute, the default is hit and returns an 
error.

The issue was first seen using the packages in the Ubuntu 4.8 kernel, which is 
OVS 2.5.  OVS 2.6 and 2.6.1 were also tried with the kernel packages and the 
same issue was seen.  Tried building OVS 2.7 and loading the 
openvswitch-datapath-dkms_2.7.0-1_all.deb that got built but the issue persisted.  
The proposed patch seems to eliminate the error messages and also fixed the 
segmentation and performance issues that were seen. 

Kris Murphy (1):
  openvswitch: Add missing case OVS_TUNNEL_KEY_ATTR_PAD

 net/openvswitch/flow_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

-- 
2.7.4
