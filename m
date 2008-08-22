From: Ranjit Manomohan <ranjitm@google.com>
Subject: [PATCH 0/2] Traffic control cgroups subsystem
Date: Thu, 21 Aug 2008 17:53:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808211739380.23590@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lizf@cn.fujitsu.com, kaber@trash.net, menage@google.com,
	akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51579 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbYHVAxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 20:53:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[Resend based of net-next-2.6, for 2.6.28]

This patch provides a simple resource controller (cgroup_tc) based on the
cgroups infrastructure to manage network traffic. The cgroup_tc resource
controller can be used to schedule and shape traffic belonging to the task(s)
in a particular cgroup.

The implementation consists of two parts:

1) A resource controller (cgroup_tc) that is used to associate packets from
   a particular task belonging to a cgroup with a traffic control class id (
   tc_classid). This tc_classid is propagated to all sockets created by tasks
   in the cgroup and will be used for classifying packets at the link layer.

2) A new traffic control classifier (cls_cgroup) that can classify packets
   based on the tc_classid field in the socket to specific destination classes.

An example of the use of this resource controller would be to limit
the traffic from all tasks from a file_server cgroup to 100Mbps. We could
achieve this by doing:

# make a cgroup of file transfer processes and assign it a arbitrary unique
# classid of 0x1234 - this will be used later to direct packets.
mkdir -p /dev/cgroup
mount -t cgroup tc -otc /dev/cgroup
mkdir /dev/cgroup/file_transfer
echo 0x1234 > /dev/cgroup/file_transfer/tc.classid
echo $PID_OF_FILE_XFER_PROCESS > /dev/cgroup/file_transfer/tasks

# Now create a HTB class that rate limits traffic to 100mbits and attach
# a filter to direct all traffic from cgroup file_transfer to this new class.
tc qdisc add dev eth0 root handle 1: htb
tc class add dev eth0 parent 1: classid 1:10 htb rate 100mbit ceil 100mbit
tc filter add dev eth0 parent 1: handle 800 protocol ip prio 1 cgroup value 0x1234 classid 1:10

Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

---
