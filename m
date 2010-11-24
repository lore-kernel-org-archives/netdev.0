From: Mike Caoco <caoco2002@yahoo.com>
Subject: Unplug ethernet cable, the route persists.  Why?
Date: Wed, 24 Nov 2010 11:48:03 -0800 (PST)
Message-ID: <242082.99180.qm@web63407.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: caoco2002@yahoo.com
To: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This may have been discussed, but all search engines couldn't give me a good answer...

I notice that when an interface is up/running, a local route is in the routing table:

$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:13:20:0e:2f:ed  
          inet addr:192.168.1.125  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::213:20ff:fe0e:2fed/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:35984995 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7409151 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3252413825 (3.2 GB)  TX bytes:1340077250 (1.3 GB)

$ ip route
192.168.20.0/24 dev eth0  proto kernel  scope link  src 192.168.20.120
192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.125 
default via 192.168.20.254 dev eth1  metric 100 

After I unplug the cable from eth1, the RUNNING flag disappears, but the route is still there:

$ ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:13:20:0e:2f:ed  
          inet addr:192.168.1.125  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::213:20ff:fe0e:2fed/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:35985023 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7409151 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3252415633 (3.2 GB)  TX bytes:1340077250 (1.3 GB)

$ ip route
192.168.20.0/24 dev eth0  proto kernel  scope link  src 192.168.20.120 
192.168.1.0/24 dev eth1  proto kernel  scope link  src 192.168.1.125 
default via 192.168.20.254 dev eth1  metric 100 

And that *prevents* from using the default route to reach 192.168.1/24 subnet after eth1 is out.

I looked at the code, it seems the IFF_RUNNING flag change is ignored in dev_change_flags():

void __dev_notify_flags(struct net_device *dev, unsigned int old_flags)
{
        .....
        if (dev->flags & IFF_UP &&
            (changes & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI | IFF_VOLATILE)))
                call_netdevice_notifiers(NETDEV_CHANGE, dev);
}

I searched in the Internet, and saw some people suggest using an application listener (eg, netplug) to remove the route. 

My question is why cannot the kernel remove the route automatically when the link becomes down?  Why should this complexity be pushed to the user to find a program to do that?

Thanks,
Joe


      
