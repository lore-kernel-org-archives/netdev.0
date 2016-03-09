From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 19:39:19 +0300
Message-ID: <20160309163919.GJ2207@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160306100932.GP4184@uranus.lan>
 <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
 <20160306170641.GA8820@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:36192 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933176AbcCIQkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 11:40:01 -0500
Received: by mail-lb0-f181.google.com with SMTP id x1so73457050lbj.3
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 08:40:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160306170641.GA8820@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 06, 2016 at 08:06:41PM +0300, Cyrill Gorcunov wrote:
> > 
> > Well, this looks like LOCKDEP kernel. Are you really running LOCKDEP on
> > production kernels ?
> 

Hi Eric, David. Sorry for the delay. Finally I've measured the
latency on the hw. It's i7-2600 cpu with 16G of memory. Here
are the collected data.

---
Unpatched vanilla
=================

commit 7f02bf6b5f5de90b7a331759b5364e41c0f39bf9
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Mar 8 09:41:20 2016 -0800

 Creating new addresses
 ----------------------
  19.26%  [kernel]                      [k] check_lifetime
  13.88%  [kernel]                      [k] __inet_insert_ifa
  13.01%  [kernel]                      [k] inet_rtm_newaddr

 Release
 -------
  20.96%  [kernel]                    [k] _raw_spin_lock
  17.79%  [kernel]                    [k] preempt_count_add
  14.79%  [kernel]                    [k] __local_bh_enable_ip
  13.08%  [kernel]                    [k] preempt_count_sub
   9.21%  [kernel]                    [k] nf_ct_iterate_cleanup
   3.15%  [kernel]                    [k] _raw_spin_unlock
   2.80%  [kernel]                    [k] nf_conntrack_lock
   2.67%  [kernel]                    [k] in_lock_functions
   2.63%  [kernel]                    [k] get_parent_ip
   2.26%  [kernel]                    [k] __inet_del_ifa
   2.17%  [kernel]                    [k] fib_del_ifaddr
   1.77%  [kernel]                    [k] _cond_resched

[root@s125 ~]# ./exploit.sh
START 4		addresses STOP 1457537580 1457537581
START 2704	addresses STOP 1457537584 1457537589
START 10404	addresses STOP 1457537602 1457537622
START 23104	addresses STOP 1457537657 1457537702
START 40804	addresses STOP 1457537784 1457537867
START 63504	addresses STOP 1457538048 1457538187

Patched (David's two patches)
=============================

 Creating new addresses
 ----------------------
  21.63%  [kernel]                    [k] check_lifetime
  14.31%  [kernel]                    [k] __inet_insert_ifa
  13.47%  [kernel]                    [k] inet_rtm_newaddr
   1.53%  [kernel]                    [k] check_preemption_disabled
   1.38%  [kernel]                    [k] page_fault
   1.27%  [kernel]                    [k] unmap_page_range

 Release
 -------
  24.26%  [kernel]                    [k] _raw_spin_lock
  17.55%  [kernel]                    [k] preempt_count_add
  14.81%  [kernel]                    [k] __local_bh_enable_ip
  14.17%  [kernel]                    [k] preempt_count_sub
  10.10%  [kernel]                    [k] nf_ct_iterate_cleanup
   3.00%  [kernel]                    [k] _raw_spin_unlock
   2.95%  [kernel]                    [k] nf_conntrack_lock
   2.86%  [kernel]                    [k] in_lock_functions
   2.73%  [kernel]                    [k] get_parent_ip
   1.91%  [kernel]                    [k] _cond_resched
   0.39%  [kernel]                    [k] task_tick_fair
   0.27%  [kernel]                    [k] native_write_msr_safe
   0.22%  [kernel]                    [k] rcu_check_callbacks
   0.20%  [kernel]                    [k] check_lifetime
   0.18%  [kernel]                    [k] check_preemption_disabled
   0.16%  [kernel]                    [k] hrtimer_active
   0.13%  [kernel]                    [k] __inet_insert_ifa
   0.13%  [kernel]                    [k] __memmove
   0.13%  [kernel]                    [k] inet_rtm_newaddr

[root@s125 ~]# ./exploit.sh
START 4		addresses STOP 1457539863 1457539864
START 2704	addresses STOP 1457539867 1457539872
START 10404	addresses STOP 1457539885 1457539905
START 23104	addresses STOP 1457539938 1457539980
START 40804	addresses STOP 1457540058 1457540132
START 63504	addresses STOP 1457540305 1457540418
---

The lockdep is turned off. And the script itself is
---
[root@s125 ~]# cat ./exploit.sh 
#!/bin/sh

if [ -z $1 ]; then
	for x in `seq 1 50 255`; do
		echo -n "START "
		(unshare -n /bin/sh exploit.sh $x)
		sleep 1
		for j in `seq 0 100`; do
			ip r > /dev/null
		done
		echo -n " "
		echo `date +%s`
	done
else
	for x in `seq 0 $1`; do
		for y in `seq 0 $1`; do
			ip a a 127.1.$x.$y dev lo
		done
	done
	num=`ip a l dev lo | grep -c "inet "`
	echo -n "$num addresses "
	echo -n "STOP "
	echo -n `date +%s`
	exit
fi
---

Note i run ip r in a cycle and added sleep before. On idle
machine this cycle takes ~1 second. But when run when kernel
cleans up the netnamespace it takea a way longer.

Also here is a graph for the data collected (blue line: unpatched
version, red -- patched. Of course with patched version it become
a way more better but still hanging).

https://docs.google.com/spreadsheets/d/1eyQDxjuZY2DHKYksGACpHDDcV1Bd92e-ZiY8ywPKshA/edit?usp=sharing

The perf output earlier shows the "perf top" when addresses
are created and when they are releasing.

The main problem still I think is that we allow to request
as many inet addresses as there is enough free memory and
of course kernel can't handle all in O(1) time, all resources
must be released so there always be some lagging moment. Thus
maybe introducing limits would be a good idea for sysadmins.

	Cyrill
