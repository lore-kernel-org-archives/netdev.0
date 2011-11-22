From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/2] net: Add network priority cgroup (v4)
Date: Tue, 22 Nov 2011 10:10:50 -0500
Message-ID: <1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53154 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568Ab1KVPLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:11:01 -0500
In-Reply-To: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Data Center Bridging environments are currently somewhat limited in their
ability to provide a general mechanism for controlling traffic priority.
Specifically they are unable to administratively control the priority at which
various types of network traffic are sent.
 
Currently, the only ways to set the priority of a network buffer are:

1) Through the use of the SO_PRIORITY socket option
2) By using low level hooks, like a tc action

(1) is difficult from an administrative perspective because it requires that the
application to be coded to not just assume the default priority is sufficient,
and must expose an administrative interface to allow priority adjustment.  Such
a solution is not scalable in a DCB environment

(2) is also difficult, as it requires constant administrative oversight of
applications so as to build appropriate rules to match traffic belonging to
various classes, so that priority can be appropriately set. It is further
limiting when DCB enabled hardware is in use, due to the fact that tc rules are
only run after a root qdisc has been selected (DCB enabled hardware may reserve
hw queues for various traffic classes and needs the priority to be set prior to
selecting the root qdisc)


I've discussed various solutions with John Fastabend, and we saw a cgroup as
being a good general solution to this problem.  The network priority cgroup
allows for a per-interface priority map to be built per cgroup.  Any traffic
originating from an application in a cgroup, that does not explicitly set its
priority with SO_PRIORITY will have its priority assigned to the value
designated for that group on that interface.  This allows a user space daemon,
when conducting LLDP negotiation with a DCB enabled peer to create a cgroup
based on the APP_TLV value received and administratively assign applications to
that priority using the existing cgroup utility infrastructure.

Tested by John and myself, with good results

(v2)
Based on reviews from John F., Amerigo Wang and Neerav Parikh, I've cleaned up
the rcu locking, fixed a memory leak in an error path, and corrected some typos.

(v3)
Converted rcu_dereference to rntl_dereference where appropriate as per request
from John F.

(v4)
Cleaned up some spacing issues, and optimized the skb_update_priority path as
per request from Dave M.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
CC: Robert Love <robert.w.love@intel.com>
CC: "David S. Miller" <davem@davemloft.net>
