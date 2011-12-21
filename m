From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/4] net: Improve socket sharing between multiple cgroups
Date: Wed, 21 Dec 2011 09:39:46 -0500
Message-ID: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34852 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab1LUOkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 09:40:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the network centric cgroups for priority and classification don't 
share resources properly.  Since socket priority and classification are
assigned based on the socket through which the data was sent, an anomaly arises
when multiple processes share a given socket.  As the priority index and class-id
are updated when a skb is sent at the top of the stack, but interrogated and
used at the bottom of the stack, multiple process living in separate cgroups but
sharing a socket can result in skbs being sent at multiple separate priorities
and classifications.  Aside from the user confusion this may cause, additional
problems can arise if the socket is tcp, and the fluctuation in class or
priority causes network re-ordering that results in serious performance
degradation.

The problem is further compounded by processes that use network resources
unknowingly.  For instance,the CIFS file system creates a network socket to a
cifs server in the context of whatever process is writing to that mount point,
and the same socket will subsequently be used by any other processes writing to
that mount.  This socket sharing will almost certainly lead to classification
and priority changes on a single data stream that will degrade file system
throughput.

This patch series is meant to solve the first of these two problems.  It changes
the way in which the priority and net_cls cgroup implementations migrate the
priority and class-id of the sockets each task owns.  specifically this series:

1) adds an cgroup owner pid field to the sock structure
2) assigns the pid of the creating process at the time of sock allocation
3) zeros the owning pid at the time of sk_common_release (to prevent future pid
aliasing
4) adds a cgroup_attach method to each cgroup subsystem which identifies sockets
owned by that task (based on matching the task pid and the pid provided in (2)
to update the priority and class-id appropriately.

This does not solve the anonymous socket use problem (I plan to address that in
a future patch series), but it does allow for a sockets priority and
classification to be controlled by a single pid for the purposes of cgroup
assignment.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Thomas Graf <tgraf@infradead.org>
CC: "David S. Miller" <davem@davemloft.net>
