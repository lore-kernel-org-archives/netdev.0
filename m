From: Pidoux <f6bvp@free.fr>
Subject: Re: [ROSE] unregister_netdevice: waiting for rose0 to become free
Date: Mon, 30 Jun 2008 15:37:02 +0200
Message-ID: <4868E17E.3070007@free.fr>
References: <20080617.024224.160706790.davem@davemloft.net> <4867E1A1.2000702@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4867E1A1.2000702@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more precisions :

The same message in endless loop appears even if there are no more routes
using rose0 device as confirmed by route command
and after device rose0 is set down with ifconfig.

The only remaining things related to rose are in /proc/net/rose_nodes and
/proc/net/rose_neigh :

#cat /proc/net/rose_node
address       mask    n    neigh   neigh   neigh
2080175524    0010    1    00001

#cat /proc/net/rose_neigh
addr    callsign   dev   count   use   mode   restart   t0   tf  digipeater
00001   RSLOOP-0   ???     1      0    DCE     yes       0    0

I can reboot the system if I do it before trying to remove rose module.
Not after, because of the waiting loop.

RSLOOP-0 rose_neigh is created as soon as rose module is loaded via modprobe.
If I issue rmmod rose command immediately after loading it, removal is successfull.

Thus it appears that rose_node with neigh 00001 is not destroyed during one previous step.
Which one ?

Bernard Pidoux, f6bvp


Pidoux wrote :
> A bug in ROSE protocol is preventing removal of rose module.
> 
> After killing all ROSE and AX25 applications, there are no more sockets and
> rose usage count is correctly decreased to null as seen in /proc/modules :
> 
> rose 40120 0 - Live 0xe1071000
> 
> However, issuing command rmmod rose displays the following message in 
> loop forever :
> 
> kernel: unregister_netdevice: waiting for rose0 to become free. Usage 
> count = 2
> 
> Usage count can be different and seems random (not correlated with 
> module usage count reached when ROSE
> applications are loaded).
> 
> Tracing the problem shows that above message is sent by core/dev.c
> 
> Here is the loop :
> 
> while (atomic_read(&dev->refcnt) !=0) {
> ....
> }
> 
> Obviously, displayed usage count (dev->refcnt) is not the same as in 
> /proc/modules or given by command
> lsmod and also it is not decremented, i.e. it stays at the same, and 
> probably not relevant, value.
> 
> A comment in core/dev.c says that buggy protocol don't correctly call 
> dev_put().
> 
> I tried to review rose module source but I have not been able to find a 
> correct place where dev_put(dev) could be missing either in af_rose.c or 
> rose_route.c.
> 
> Maybe the problem is elsewhere ?
> 
> Bernard Pidoux, f6bvp
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 


73 de Bernard, f6bvp
http://f6bvp.org
