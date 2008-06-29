From: Pidoux <f6bvp@free.fr>
Subject: [ROSE] unregister_netdevice: waiting for rose0 to become free
Date: Sun, 29 Jun 2008 21:25:21 +0200
Message-ID: <4867E1A1.2000702@free.fr>
References: <20080617.024224.160706790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080617.024224.160706790.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A bug in ROSE protocol is preventing removal of rose module.

After killing all ROSE and AX25 applications, there are no more sockets and
rose usage count is correctly decreased to null as seen in /proc/modules :

rose 40120 0 - Live 0xe1071000

However, issuing command rmmod rose displays the following message in loop forever :

kernel: unregister_netdevice: waiting for rose0 to become free. Usage count = 2

Usage count can be different and seems random (not correlated with module usage count reached when ROSE
applications are loaded).

Tracing the problem shows that above message is sent by core/dev.c

Here is the loop :

while (atomic_read(&dev->refcnt) !=0) {
....
}

Obviously, displayed usage count (dev->refcnt) is not the same as in /proc/modules or given by command
lsmod and also it is not decremented, i.e. it stays at the same, and probably not relevant, value.

A comment in core/dev.c says that buggy protocol don't correctly call dev_put().

I tried to review rose module source but I have not been able to find a correct place where dev_put(dev) could be 
missing either in af_rose.c or rose_route.c.

Maybe the problem is elsewhere ?

Bernard Pidoux, f6bvp
