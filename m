From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Fun with if_bridge.h and br_private.h
Date: Mon, 3 May 2010 12:12:56 -0700
Message-ID: <20100503191256.GA18110@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:40262 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756356Ab0ECTM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 15:12:59 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o43J0953018377
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 15:00:09 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o43JCvuE1409270
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 15:12:57 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o43JCvuG028802
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 15:12:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Stephen,

I need some help with #include issues surrounding bridge.

Arnd has been putting together a sparse-based RCU-checking tool
that can detect pointer access that should have been protected by an
rcu_dereference() or rcu_assign_pointer().  On of the side-effects of
his approach is that rcu_dereference() can no longer handle pointers
to incomplete types, as Arnd's approach uses the address-space feature
of sparse, which in turn must tag the type pointed to rather than the
pointer itself.  And this in turn requires rcu_dereference() and friends
to see the pointed-to type as well as the pointer type.

One place affected by this is handle_bridge() in net/core/dev.c, which
invokes rcu_dereference() on skb->dev->br_port, which is of type struct
net_bridge_port, which is defined in net/bridge/br_private.h.  This is,
well, private, but is included into a couple places in netfilter and atm,
so I tried including it into net/core/dev.c.

This still left me with forward references:

In file included from net/core/dev.c:104:
include/linux/if_bridge.h:106: warning: "struct net_bridge_port" declared inside parameter list
include/linux/if_bridge.h:106: warning: its scope is only this definition or declaration, which is probably not what you want
net/core/dev.c:2331: error: conflicting types for "br_handle_frame_hook"
include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
net/core/dev.c:2333: error: conflicting types for "br_handle_frame_hook"
include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here

This happens because net/bridge/br_private.h includes if_bridge.h before
it defines net_bridge_port.

Any thoughts on how best to allow handle_bridge() see the definition
of struct net_bridge_port?

							Thanx, Paul
