From: Hasso Tepper <hasso@estpak.ee>
Subject: Link detection
Date: Mon, 14 Mar 2005 14:35:38 +0200
Message-ID: <200503141435.38227.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8bit
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We (the Quagga project) are planning to rework link detection in Quagga to 
support more platforms (only Linux and Solaris are supported at the moment) 
and to have proper abstraction of link detection in zebra daemon. During 
discussions several questions were raised.

1) What's the proper way to detect carrier in Linux for user space 
application like Quagga?

Till now I thought that IFF_RUNNING flag should be used for that. But some 
time ago I tried to bug Stephen Hemminger about missing IFF_RUNNING flag in 
ip output and got answer that IFF_RUNNING is BSD'ism and shouldn't be used 
any more and /sys/class/net/eth0/carrier should be looked at.

True, IFF_RUNNING is from BSD, but as long as the code in 
net/core/dev.c:dev_get_flags() is there, it gives nice clean way to get 
carrier status from user space (AFAIK it's used in same way in Solaris). 
Especially for applications using rtnetlink - ie. without it there is no 
all info in the netlink message any more. If these applications will 
receive RTM_NEWLINK, they have to poll kernel "look, maybe carrier status 
is changed" every time?

2) There is no difference between "we know that carrier is really on" and 
"interface doesn't support carrier detection" in Linux.

>From users' point of view it might make huge difference - can I rely on info 
I get from OS, or have to run to the equipment to see whether links are 
really up or not? It's not critical, but would be still nice to have.

3) Connected routes in carrier down situations. If address are added to the 
interface, "connected" route is added to the interface as well. Problem is 
that this route is still there if carrier is down, but there is no 
difference for user if just carrier is down or interface is 
administratively down - network behind this interface is still actually 
unreachable.  

It's not only the issue related with routing protocols, but the general one. 
I'm using laptop with two interfaces - ethernet and wireless. If I plug off 
ethernet cable and walk away from my desk, the network on this ethernet 
segment should be still reachable for me via wireless (default route), but 
no ... I have to shut down ethernet interface manually.

There are several scenarios which are affected - building redundant 
firewalls/gateways, computers/equipment with backup links etc. And of 
course routers. We take care of this in Quagga not to take nexthops in down 
network into account, but it doesn't matter if destination of actual 
traffic is this particular network on interface which is actually down.

Before someone proposes that - yes, managing these routes can be done from 
user space in theory (like zebra daemon), but there are several problems 
regarding this.

* Managing connected routes from user space might leave network in 
inconsistent state. You can't create routes with protocol kernel with ip 
utility, so kernel will not remove these routes if address is really 
deleted from interface.
* There are several applications which would be interested in this, but it 
would be dangerous imho if several applications at once will manage 
connected routes in kernel.

And I don't see any actual reason not to manage removal/adding connected 
routes in kernel level if link goes down/up. Or is there any? Why would 
anyone need route to the interface if it's actually known to be unusable?


with my best wishes,

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
