From: Chase Douglas <chasedouglas.lists@gmail.com>
Subject: neigh_params_release() usage in net/ipv6/addrconf.c
Date: Fri, 15 May 2009 12:33:39 -0400
Message-ID: <8A0B031A-1483-49FD-A4AD-CA4EA87E9359@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:47454 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763462AbZEOQdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 12:33:41 -0400
Received: by gxk10 with SMTP id 10so3849865gxk.13
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 09:33:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm debugging an issue I'm seeing when I use vlan with IPv6 support.  
After bringing up the device, I'm unable to bring it down and  
unregister it. I put some debug statements around dev_hold() and  
dev_put() to see what was going on:

dev_hold() called on lo.2, new refcnt: 1 (net/core/dev.c:4162)
dev_hold() called on lo.2, new refcnt: 2 (net/core/neighbour.c:1357)
dev_hold() called on lo.2, new refcnt: 3 (net/ipv4/devinet.c:178)
dev_hold() called on lo.2, new refcnt: 4 (net/core/neighbour.c:1357)
dev_hold() called on lo.2, new refcnt: 5 (net/8021q/vlan.c:266)
dev_hold() called on lo.2, new refcnt: 6 (net/core/link_watch.c:219)
dev_put()  called on lo.2, new refcnt: 5 (net/core/link_watch.c:191)
dev_hold() called on lo.2, new refcnt: 6 (net/core/dev.c:684)
dev_put()  called on lo.2, new refcnt: 5 (net/ipv4/fib_semantics.c:149)
dev_hold() called on lo.2, new refcnt: 6 (net/core/dev.c:684)
dev_hold() called on lo.2, new refcnt: 7 (net/ipv4/fib_frontend.c:173)
dev_put()  called on lo.2, new refcnt: 6 (net/ipv4/route.c:2453)
dev_put()  called on lo.2, new refcnt: 5 (net/ipv4/fib_semantics.c:149)
dev_put()  called on lo.2, new refcnt: 4 (net/core/neighbour.c:1393)
dev_put()  called on lo.2, new refcnt: 3 (net/ipv4/devinet.c:151)
dev_put()  called on lo.2, new refcnt: 2 (net/core/dev.c:4010)
dev_put()  called on lo.2, new refcnt: 1 (net/8021q/vlan.c:182)
unregister_netdevice: waiting for lo.2 to become free. Usage count = 2

The fourth dev_hold() is in neigh_parms_alloc(), called by  
ipv6_add_dev(). The only place I see neigh_parms_release() called in  
addrconf.c is if ipv6_add_dev() fails later on, or when taking the  
device down in addrconf_ifdown(). Unfortunately, when I bring the vlan  
dev down I never see addrconf_ifdown() called with the how parameter  
set to 1, which is the only instance where neigh_parms_release() would  
be called.

Why is neigh_parms_release() called in addrconf_ifdown() instead of  
in6_dev_finish_destroy(), which looks to me to be the complement of  
ipv6_add_dev()? If neigh_parms_release() really should be called in  
addrconf_ifdown(), does anyone know why it's not being called properly  
in this instance?

PS: I am running my tests using a slightly modified SLES 11 kernel. I  
haven't been able to find anything in the git trees that would  
indicate to me that the problem has been fixed upstream.
