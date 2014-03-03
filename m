From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 71351] New: "INFO: rcu_sched detected stalls on
 CPUs/tasks" on high server load
Date: Sun, 2 Mar 2014 16:42:46 -0800
Message-ID: <20140302164246.71f45693@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:43989 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbaCCAmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:42:50 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so3025101pdi.33
        for <netdev@vger.kernel.org>; Sun, 02 Mar 2014 16:42:50 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id gg3sm7263500pbc.34.2014.03.02.16.42.49
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 02 Mar 2014 16:42:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 1 Mar 2014 10:11:16 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 71351] New: "INFO: rcu_sched detected stalls on CPUs/tasks" on high server load


https://bugzilla.kernel.org/show_bug.cgi?id=71351

            Bug ID: 71351
           Summary: "INFO: rcu_sched detected stalls on CPUs/tasks" on
                    high server load
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.22, 3.11, 3.13.5
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: exa.exa@gmail.com
        Regression: No

After upgrading the kernel on several of my machines from 3.6.9 to 3.13.3, I've
seen following problem happen randomly after some amount of time:

[ 5727.864173] INFO: rcu_sched detected stalls on CPUs/tasks: { 7} (detected by
5, t=60002 jiffies, g=602758, c=602757, q=24880)
[ 5727.864179] sending NMI to all CPUs:
[ 5727.864183] NMI backtrace for cpu 5
[ 5727.864186] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 3.13.3 #4
[ 5727.864187] Hardware name: Supermicro X8SIE/X8SIE, BIOS 1.0c 05/27/2010
[ 5727.864189] task: ffff880236095210 ti: ffff8802360ba000 task.ti:
ffff8802360ba000
[ 5727.864191] RIP: 0010:[<ffffffff812bd031>]  [<ffffffff812bd031>]
__const_udelay+0x21/0x30

.....
(Full dmesg in attachment).

I don't know where to start searching. The machines do

- HFSC traffic shaping of cca 500Mbits of data (low CPU load, not many classes)
- e1000 and/or igb networking
- some (not very hard) disk&CPU load from postgresql.
- irqbalance for (well) IRQ balancing
- bIRD routing daemon with OSPF.

When this problem happens, one of following thing usually (not everytime and
randomly) starts failing:

- Network interrupts start to take away more CPU (from 2-3% on each core to
around 50% on each core)
- HFSC stops working and it doesn't do anything at all
- HFSC fails and no packets run through.

I've been unable yet to see this in lab setup (it's on production servers) so I
can't produce much useful debug output - if there's some more useful thing I
should attach here, tell me.

I'm currently trying to bisect a bit to see what change could have introduced
this problem (it doesn't happen on 3.1.1 to 3.6.9 and it certainly happens from
3.10.22 to 3.13.5) but it's quite a slow process because of waiting several
hours for the bug to occur.

Dmesg's with the error description are attached.

So far I tried to isolate following things:

- e1000 or igb driver (happens on both)
- HFSC (seems to happen even without HFSC)
- GRO, TSO, ... etc for network stuff (no effect)
- C-state idle drivers (I've been told that some NICs don't play well when
C-states go above 1, but it didn't help much).

Thanks for any help on solving this.
-mk

PS. because the machines are doing networking and this seems triggered by heavy
network usage, I posted this in "networking" component, but I'm not sure
whether it's really networking - please reassign if it looks otherwise.

-- 
You are receiving this mail because:
You are the assignee for the bug.
