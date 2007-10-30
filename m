From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH][NETNS] fix net released by rcu callback
Date: Tue, 30 Oct 2007 11:33:59 +0100
Message-ID: <47270897.4000409@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:21048 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbXJ3Kgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 06:36:32 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9UAaTwH148612
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 10:36:29 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UAaQSu2207976
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 11:36:28 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UAaPZN028387
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 11:36:26 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a network namespace reference is held by a network subsystem,
and when this reference is decremented in a rcu update callback, we
must ensure that there is no more outstanding rcu update before
trying to free the network namespace.

In the normal case, the rcu_barrier is called when the network namespace
is exiting in the cleanup_net function.

But when a network namespace creation fails, and the subsystems are
undone (like the cleanup), the rcu_barrier is missing.

This patch adds the missing rcu_barrier.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
  net/core/net_namespace.c |    2 ++
  1 file changed, 2 insertions(+)

Index: net-2.6/net/core/net_namespace.c
===================================================================
--- net-2.6.orig/net/core/net_namespace.c
+++ net-2.6/net/core/net_namespace.c
@@ -112,6 +112,8 @@ out_undo:
                 if (ops->exit)
                         ops->exit(net);
         }
+
+       rcu_barrier();
         goto out;
  }
