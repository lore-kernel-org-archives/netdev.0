From: Hans Schillstrom <hans@schillstrom.com>
Subject: Race condition when creating multiple namespaces?
Date: Mon, 11 Apr 2011 23:01:46 +0200
Message-ID: <201104112301.46776.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@free.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:48221 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754239Ab1DKVCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 17:02:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I'v been strugling with this for some time now

When creating multiple namespaces using lxc-start,  un-initialized network namespace parts will be called by the new process in the namespace.
ex. when using conntrack or ipvsadm to quickly,  (a sleep 2 "solves" the problem).
(From what I can see syscall clone() is used in lx-start  i.e. do_fork will be called later on.)
Actually I was debugging ip_vs when closing multiple ns  when I fell into this one.

I have a loop that create 33 containers whith lxc-start ... -- test.sh
the first thing the new conatiner does in test.sh is
#!/bin/bash
iptables -t mangle -A PREROUTING -m conntrack --ctstate RELATED,ESTABLISHED -j CONNMARK --restore-mark
nc -l -p1234

This results in NULL ptr in ip_conntrack_net_init(struct *net)

and in anoither test test.sh looks like this
#!/bin/bash
ipvsadm --start-daemon=master --mcast-interface=lo
nc -l -p1234

And this results in an uniitialized spinlock in ip_vs_sync

I put a printk in nsproxy: copy_namespaces() and could see a dozens of them
before anything appears from ipvs or conntrack.

My feeling is that when you start up user processes in a new name space, 
all kernel related init should have been done (you should not need to add a sleep to get it working)

All test  made by using todays net-next-2.6 (2.6.39-rc1)

Note:
That neither conntrack or ip_vs modules where loaded,
if modules where loaded before creating new namespaces it all works...

Finally the question,
Should it really work to load modules within a namespace , 
that is a part of netns ?

-- 
Mvh
Hasse Schillstrom
070-699 7150
