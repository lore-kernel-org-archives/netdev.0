From: Andrew Morton <akpm@osdl.org>
Subject: Re: kernel BUG at kernel/timer.c:380!
Date: Tue, 29 Jul 2003 01:32:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030729013234.59c9f78b.akpm@osdl.org>
References: <20030719022525.GA18446@mautner.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian Mautner <linux@mautner.ca>
In-Reply-To: <20030719022525.GA18446@mautner.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Mautner <linux@mautner.ca> wrote:
>
> I have a very reproducible problem with 2.6.0-test1. 

Been looking into this bug in the bridge driver a little more.

The problem is that we keep on calling br_stp_port_timer_init() against the
bridge.  But this does init_timer() against the bridge's timers, even
though they are already running from the previous call.

The init_timer() on a pending timer sets timer->base to NULL and we oops
when the timer code tries to cascade the timers.

Here's the script:

	#!/bin/sh

	doit()
	{
	        echo $*
	        $*
	}
		
	doit brctl addbr br0
	doit brctl stp br0 off
	doit brctl addif br0 eth1
	doit brctl addif br0 eth2
		
	doit ifconfig eth1 up
	doit ifconfig eth2 up
	doit ifconfig br0 up

And here's the result with a breakpoint on entry to br_stp_port_timer_init():


addif br0 eth1:

Breakpoint 1, br_stp_port_timer_init (p=0xf4c1f004) at net/bridge/br_stp_timer.c:175
175             br_timer_init(&p->message_age_timer, br_message_age_timer_expired,
(gdb) bt
#0  br_stp_port_timer_init (p=0xf4c1f004) at net/bridge/br_stp_timer.c:175
#1  0xc03961dd in br_init_port (p=0xf4c1f004) at net/bridge/br_stp_if.c:37
#2  0xc0393d5b in new_nbp (br=0xf370c240, dev=0xf56e2004) at net/bridge/br_if.c:157
#3  0xc0393eae in br_add_if (br=0xf370c240, dev=0xf56e2004) at net/bridge/br_if.c:221
#4  0xc039450d in br_ioctl_device (br=0xf370c240, cmd=4, arg0=4, arg1=0, arg2=4106350596)
    at net/bridge/br_ioctl.c:64
#5  0xc0394fac in br_ioctl (br=0xf4c1f004, cmd=4, arg0=4, arg1=0, arg2=4106350596) at net/bridge/br_ioctl.c:306
#6  0xc03929e0 in br_dev_do_ioctl (dev=0xf4c1f004, rq=0xf4c1f004, cmd=35312) at net/bridge/br_device.c:35
#7  0xc0338e05 in dev_ifsioc (ifr=0xf3663f48, cmd=35312) at net/core/dev.c:2375
#8  0xc033910e in dev_ioctl (cmd=35312, arg=0xbffff970) at net/core/dev.c:2538
#9  0xc032fff8 in sock_ioctl (inode=0xf4f6f030, file=0xf5b3b004, cmd=35312, arg=3221223792) at net/socket.c:771
#10 0xc017376f in sys_ioctl (fd=3, cmd=35312, arg=4109824004) at fs/ioctl.c:127
(gdb) c
Continuing.

addif br0 eth2:

Breakpoint 1, br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:175
175             br_timer_init(&p->message_age_timer, br_message_age_timer_expired,
(gdb) bt
#0  br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:175
#1  0xc03961dd in br_init_port (p=0xf3645004) at net/bridge/br_stp_if.c:37
#2  0xc0393d5b in new_nbp (br=0xf370c240, dev=0xf5d76004) at net/bridge/br_if.c:157
#3  0xc0393eae in br_add_if (br=0xf370c240, dev=0xf5d76004) at net/bridge/br_if.c:221
#4  0xc039450d in br_ioctl_device (br=0xf370c240, cmd=4, arg0=5, arg1=0, arg2=4083437572)
    at net/bridge/br_ioctl.c:64
#5  0xc0394fac in br_ioctl (br=0xf3645004, cmd=4, arg0=5, arg1=0, arg2=4083437572) at net/bridge/br_ioctl.c:306
#6  0xc03929e0 in br_dev_do_ioctl (dev=0xf3645004, rq=0xf3645004, cmd=35312) at net/bridge/br_device.c:35
#7  0xc0338e05 in dev_ifsioc (ifr=0xf3663f48, cmd=35312) at net/core/dev.c:2375
#8  0xc033910e in dev_ioctl (cmd=35312, arg=0xbffff970) at net/core/dev.c:2538
#9  0xc032fff8 in sock_ioctl (inode=0xf35e9030, file=0xf4ca0004, cmd=35312, arg=3221223792) at net/socket.c:771
#10 0xc017376f in sys_ioctl (fd=3, cmd=35312, arg=4083060740) at fs/ioctl.c:127
(gdb) c
Continuing.

ifup eth1:

Breakpoint 1, br_stp_port_timer_init (p=0xf4c1f004) at net/bridge/br_stp_timer.c:175
175             br_timer_init(&p->message_age_timer, br_message_age_timer_expired,
(gdb) bt
#0  br_stp_port_timer_init (p=0xf4c1f004) at net/bridge/br_stp_timer.c:175
#1  0xc03961dd in br_init_port (p=0xf4c1f004) at net/bridge/br_stp_if.c:37
#2  0xc03963e5 in br_stp_enable_port (p=0xf4c1f004) at net/bridge/br_stp_if.c:81
#3  0xc0395068 in br_device_event (unused=0xc04ad94c, event=1, ptr=0xf56e2004) at net/bridge/br_notify.c:54
#4  0xc01322be in notifier_call_chain (n=0xf4c1f004, val=1, v=0xf56e2004) at kernel/sys.c:159
#5  0xc0337217 in dev_open (dev=0xf56e2004) at net/core/dev.c:780
#6  0xc0338965 in dev_change_flags (dev=0xf56e2004, flags=4163) at net/core/dev.c:2169
#7  0xc037366e in devinet_ioctl (cmd=35092, arg=0xbffff890) at net/ipv4/devinet.c:624
#8  0xc03763b7 in inet_ioctl (sock=0xf4c1f004, cmd=35092, arg=3221223568) at net/ipv4/af_inet.c:872
#9  0xc0330232 in sock_ioctl (inode=0xf52c5030, file=0xf35d0004, cmd=35092, arg=3221223568) at net/socket.c:830
#10 0xc017376f in sys_ioctl (fd=4, cmd=35092, arg=4113321988) at fs/ioctl.c:127
(gdb) c
Continuing.

ifup eth2:

Breakpoint 1, br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:175
175             br_timer_init(&p->message_age_timer, br_message_age_timer_expired,
(gdb) bt
#0  br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:175
#1  0xc03961dd in br_init_port (p=0xf3645004) at net/bridge/br_stp_if.c:37
#2  0xc03963e5 in br_stp_enable_port (p=0xf3645004) at net/bridge/br_stp_if.c:81
#3  0xc0395068 in br_device_event (unused=0xc04ad94c, event=1, ptr=0xf5d76004) at net/bridge/br_notify.c:54
#4  0xc01322be in notifier_call_chain (n=0xf3645004, val=1, v=0xf5d76004) at kernel/sys.c:159
#5  0xc0337217 in dev_open (dev=0xf5d76004) at net/core/dev.c:780
#6  0xc0338965 in dev_change_flags (dev=0xf5d76004, flags=4163) at net/core/dev.c:2169
#7  0xc037366e in devinet_ioctl (cmd=35092, arg=0xbffff890) at net/ipv4/devinet.c:624
#8  0xc03763b7 in inet_ioctl (sock=0xf3645004, cmd=35092, arg=3221223568) at net/ipv4/af_inet.c:872
#9  0xc0330232 in sock_ioctl (inode=0xf4f6f030, file=0xf5b3b004, cmd=35092, arg=3221223568) at net/socket.c:830
#10 0xc017376f in sys_ioctl (fd=4, cmd=35092, arg=4109824004) at fs/ioctl.c:127
(gdb) c
Continuing.

ifup br0:

Breakpoint 1, br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:175
175             br_timer_init(&p->message_age_timer, br_message_age_timer_expired,
(gdb) bt
#0  br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:175
#1  0xc03961dd in br_init_port (p=0xf3645004) at net/bridge/br_stp_if.c:37
#2  0xc03963e5 in br_stp_enable_port (p=0xf3645004) at net/bridge/br_stp_if.c:81
#3  0xc039627f in br_stp_enable_bridge (br=0xf370c240) at net/bridge/br_stp_if.c:51
#4  0xc0392af2 in br_dev_open (dev=0xf3645004) at net/bridge/br_device.c:90
#5  0xc03371e7 in dev_open (dev=0xf370c004) at net/core/dev.c:752
#6  0xc0338965 in dev_change_flags (dev=0xf370c004, flags=4163) at net/core/dev.c:2169
#7  0xc037366e in devinet_ioctl (cmd=35092, arg=0xbffff890) at net/ipv4/devinet.c:624
#8  0xc03763b7 in inet_ioctl (sock=0xf3645004, cmd=35092, arg=3221223568) at net/ipv4/af_inet.c:872
#9  0xc0330232 in sock_ioctl (inode=0xf35d6030, file=0xf35e4004, cmd=35092, arg=3221223568) at net/socket.c:830
#10 0xc017376f in sys_ioctl (fd=4, cmd=35092, arg=4082982916) at fs/ioctl.c:127
(gdb) c
Continuing.

Here the `ifup br0' hits my BUG() in br_timer_init():

Program received signal SIGTRAP, Trace/breakpoint trap.
br_timer_init (timer=0xf3645040, _function=0xf3645040, _data=4083437632) at net/bridge/br_stp_timer.c:152
152                     BUG();
(gdb) bt
#0  br_timer_init (timer=0xf3645040, _function=0xf3645040, _data=4083437632) at net/bridge/br_stp_timer.c:152
#1  0xc0396ef0 in br_stp_port_timer_init (p=0xf3645004) at net/bridge/br_stp_timer.c:178
#2  0xc03961dd in br_init_port (p=0xf3645004) at net/bridge/br_stp_if.c:37
#3  0xc03963e5 in br_stp_enable_port (p=0xf3645004) at net/bridge/br_stp_if.c:81
#4  0xc039627f in br_stp_enable_bridge (br=0xf370c240) at net/bridge/br_stp_if.c:51
#5  0xc0392af2 in br_dev_open (dev=0xf3645040) at net/bridge/br_device.c:90
#6  0xc03371e7 in dev_open (dev=0xf370c004) at net/core/dev.c:752
#7  0xc0338965 in dev_change_flags (dev=0xf370c004, flags=4163) at net/core/dev.c:2169
#8  0xc037366e in devinet_ioctl (cmd=35092, arg=0xbffff890) at net/ipv4/devinet.c:624
#9  0xc03763b7 in inet_ioctl (sock=0xf3645040, cmd=35092, arg=3221223568) at net/ipv4/af_inet.c:872
#10 0xc0330232 in sock_ioctl (inode=0xf35d6030, file=0xf35e4004, cmd=35092, arg=3221223568) at net/socket.c:830
#11 0xc017376f in sys_ioctl (fd=4, cmd=35092, arg=4082982916) at fs/ioctl.c:127


See, we keep on reinitialising already-running timers over and over again. 
It is seriously broken.


Here's the debug patch:

 kernel/timer.c            |    4 ++++
 net/bridge/br_stp_timer.c |    4 +++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff -puN kernel/timer.c~a kernel/timer.c
--- 25/kernel/timer.c~a	2003-07-29 00:29:10.000000000 -0700
+++ 25-akpm/kernel/timer.c	2003-07-29 00:29:52.000000000 -0700
@@ -377,6 +377,10 @@ static int cascade(tvec_base_t *base, tv
 		struct timer_list *tmp;
 
 		tmp = list_entry(curr, struct timer_list, entry);
+		if (tmp->base != base) {
+			printk("%s: tmp->base=%p, base=%p\n",
+				__FUNCTION__, tmp->base, base);
+		}
 		BUG_ON(tmp->base != base);
 		curr = curr->next;
 		internal_add_timer(base, tmp);
diff -puN net/bridge/br_stp_timer.c~a net/bridge/br_stp_timer.c
--- 25/net/bridge/br_stp_timer.c~a	2003-07-29 00:40:27.000000000 -0700
+++ 25-akpm/net/bridge/br_stp_timer.c	2003-07-29 00:41:11.000000000 -0700
@@ -144,10 +144,12 @@ static void br_hold_timer_expired(unsign
 	spin_unlock_bh(&p->br->lock);
 }
 
-static inline void br_timer_init(struct timer_list *timer,
+static void br_timer_init(struct timer_list *timer,
 			  void (*_function)(unsigned long),
 			  unsigned long _data)
 {
+	if (timer->magic == TIMER_MAGIC && timer_pending(timer))
+		BUG();
 	init_timer(timer);
 	timer->function = _function;
 	timer->data = _data;

_


This patch partially reverts a change which Stephen made and randomly adds
new stuff:


 net/bridge/br_if.c     |    3 ++-
 net/bridge/br_notify.c |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff -puN net/bridge/br_notify.c~bridge-fix net/bridge/br_notify.c
--- 25/net/bridge/br_notify.c~bridge-fix	2003-07-29 01:23:29.000000000 -0700
+++ 25-akpm/net/bridge/br_notify.c	2003-07-29 01:23:35.000000000 -0700
@@ -47,11 +47,13 @@ static int br_device_event(struct notifi
 		break;
 
 	case NETDEV_DOWN:
-		br_stp_disable_port(p);
+		if (br->dev->flags & IFF_UP)
+			br_stp_disable_port(p);
 		break;
 
 	case NETDEV_UP:
-		br_stp_enable_port(p);
+		if (!(br->dev->flags & IFF_UP))
+			br_stp_enable_port(p);
 		break;
 
 	case NETDEV_UNREGISTER:
diff -puN net/bridge/br_if.c~bridge-fix net/bridge/br_if.c
--- 25/net/bridge/br_if.c~bridge-fix	2003-07-29 01:28:07.000000000 -0700
+++ 25-akpm/net/bridge/br_if.c	2003-07-29 01:28:13.000000000 -0700
@@ -154,7 +154,8 @@ static struct net_bridge_port *new_nbp(s
 	dev->br_port = p;
 
 	p->port_no = i;
-	br_init_port(p);
+	if (!(br->dev->flags & IFF_UP))
+		br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 
 	list_add_rcu(&p->list, &br->port_list);

_


but it is hopelessly inadequate.
