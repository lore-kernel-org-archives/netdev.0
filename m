From: Ben Greear <greearb@candelatech.com>
Subject: unregister_netdevice, usage count = 0
Date: Sun, 15 Sep 2002 10:33:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D84C462.7020104@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


For one reason or another, when trying to unload the e1000 NAPI'fied
drive from 2.4.20-pre7, I see this error repeatedly:

unregister_netdevice: waiting for eth2 to become free. Usage count = 0

So, I'm wondering if the code in dev.c, line 2688:


	now = warning_time = jiffies;
	while (atomic_read(&dev->refcnt) != 1) {
		if ((jiffies - now) > 1*HZ) {
			/* Rebroadcast unregister notification */
			notifier_call_chain(&netdev_chain, NETDEV_UNREGISTER, dev);
		}
		current->state = TASK_INTERRUPTIBLE;
		schedule_timeout(HZ/4);
		current->state = TASK_RUNNING;
		if ((jiffies - warning_time) > 10*HZ) {
			printk(KERN_EMERG "unregister_netdevice: waiting for %s to "
					"become free. Usage count = %d\n",
					dev->name, atomic_read(&dev->refcnt));
			warning_time = jiffies;
		}
	}
	dev_put(dev);

Should be like this instead:

	while (atomic_read(&dev->refcnt) > 1) {


Now, off to see if I can track down the real problem...

Ben



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
