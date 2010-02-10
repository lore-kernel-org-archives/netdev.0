From: "Michael B. Trausch" <mike@trausch.us>
Subject: LXC bridged networking issues
Date: Wed, 10 Feb 2010 16:45:53 -0500
Message-ID: <4B732911.7070209@trausch.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:49166 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab0BJVp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 16:45:57 -0500
Received: by gxk24 with SMTP id 24so519739gxk.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 13:45:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I am having some rather extreme difficulty getting networking reliably 
working with containers running under LXC.  First some basic system 
information, and my problem description follows.

The host machine has two Ethernet cards, one of which is disabled and 
not presently in use, and the other which is connected to a 100Mbps 
Ethernet network.  The system has a bridge (br0) configured, and br0 has 
a static IP address on the LAN.  The LAN's network is 172.16.0.0/24.  I 
also have 173.15.213.184/29 from my ISP.  The kernel running on the host 
system is a vanilla 2.6.32.7 kernel and lxc is vanilla 0.6.5.

The output of lxc-checkconfig is:

=====================================================================
Kernel config /proc/config.gz not found, looking in other places...
Found kernel config file /boot/config-2.6.32.7
--- Namespaces ---
Namespaces: enabled
Utsname namespace: enabled
Ipc namespace: enabled
Pid namespace: enabled
User namespace: enabled
Network namespace: enabled
Multiple /dev/pts instances: enabled

--- Control groups ---
Cgroup: enabled
Cgroup namespace: enabled
Cgroup device: enabled
Cgroup sched: enabled
Cgroup cpu account: enabled
Cgroup memory controller: enabled
Cgroup cpuset: enabled

--- Misc ---
Veth pair device: enabled
Macvlan: enabled
Vlan: enabled
File capabilities: enabled
=====================================================================

Now, I have three containers, "mysql-db", "spicerack", and "secondary". 
  mysql-db and spicerack have IP addresses in the LAN's private address 
space, and the latter two containers also have IP addresses from my pool 
of global IP addresses.  It seems that the IP addresses on the LAN work 
perfectly---that is, I can "ping -f" against the mysql-db machine or the 
LAN IP addresses of the spicerack container and I get (statistically) no 
packet loss; for example, a floodping to the database server gave 5,151 
packets transmitted, 5,148 received.  However, flood pinging the 
spicerack container yielded 5,493 transmitted, 4,624 received, and this 
was a better than normal run of late:

--- mysql-db.local ping statistics ---
5151 packets transmitted, 5148 received, 0% packet loss, time 132902ms
rtt min/avg/max/mdev = 0.865/2.572/241.465/12.386 ms, pipe 11, ipg/ewma 
25.806/1.406 ms

--- spicerack.trausch.us ping statistics ---
5493 packets transmitted, 4624 received, +1 errors, 15% packet loss, 
time 135421ms
rtt min/avg/max/mdev = 0.784/1.697/171.491/5.200 ms, pipe 11, ipg/ewma 
24.657/1.472 ms

The containers were created using lxc-create with configuration files 
handed to the lxc-create command.  The mysql-db machine gets its LAN IP 
via DHCP, and the interfaces on the spicerack and secondary machines are 
configured using the contained distribution's normal network 
configuration mechanism with static IP address information.  Here is the 
configuration file for the spicerack container (the config files for the 
mysql-db and secondary containers are the same file but with one less 
network interface, and a different hostname):

=====================================================================
#
# spicerack container configuration
#

# The hostname.
lxc.utsname = spicerack.trausch.us

# The container's network configuration.
lxc.network.type = veth
lxc.network.link = br0
lxc.network.name = eth0
lxc.network.flags = up
lxc.network.ipv4 = 0.0.0.0
lxc.network.hwaddr = 00:50:56:00:00:00

lxc.network.type = veth
lxc.network.link = br0
lxc.network.name = eth1
lxc.network.flags = up
lxc.network.ipv4 = 0.0.0.0
lxc.network.hwaddr = 00:50:56:00:00:01

# Filesystem configuration.
lxc.rootfs = /srv/systems/trausch.us/spicerack.trausch.us/fs
lxc.mount = /srv/systems/trausch.us/spicerack.trausch.us/fstab

# Permit it to only use one CPU (the first core).
lxc.cgroup.cpuset.cpus = 0

# /dev/ttyX for the container.
lxc.tty = 6
=====================================================================

At first, I had an issue with containers predictably not responding to 
their global IP addresses.  I appear to have "fixed" this (FSVO "fixed") 
by doing "echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp", however since 
all the containers are on the same bridge interface which is attached to 
the network, I find myself confused at why this would appear to have any 
effect at all.  AIUI, it should not matter since the containers are 
attached to the br0 interface, and eth1 (the connected Ethernet card) is 
also on the br0 interface.  I know that when I used OpenVZ and even now 
when I use KVM, no special changes are necessary to use 
contained/virtualized systems---they Just Work when attached to the bridge.

However, now, I have the issues with packet loss shown above when 
communicating with the global IP addresses on my network (note: only 
when they are assigned to an LXC container's interface; I have no 
problems with KVM or machines on my network that *actually* have global 
IP addresses assigned on their Ethernet interfaces).  These containers 
also seem to lose many packets when communicating with the outside world.

Since the situation is the same for spicerack and secondary, I'll focus 
on spicerack here.

The ifconfig output on the container:
=====================================================================
mbt@spicerack:~$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:50:56:00:00:00
           inet addr:173.15.213.185  Bcast:173.15.213.191 
Mask:255.255.255.248
           inet6 addr: fe80::250:56ff:fe00:0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:140443 errors:0 dropped:0 overruns:0 frame:0
           TX packets:46681 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:23952964 (23.9 MB)  TX bytes:21261328 (21.2 MB)

eth1      Link encap:Ethernet  HWaddr 00:50:56:00:00:01
           inet addr:172.16.0.3  Bcast:172.16.0.255  Mask:255.255.255.0
           inet6 addr: fe80::250:56ff:fe00:1/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:323961 errors:0 dropped:0 overruns:0 frame:0
           TX packets:77990 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:283807282 (283.8 MB)  TX bytes:10091642 (10.0 MB)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:943 errors:0 dropped:0 overruns:0 frame:0
           TX packets:943 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:96145 (96.1 KB)  TX bytes:96145 (96.1 KB)
=====================================================================

And the routing table:
=====================================================================
mbt@spicerack:~$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use 
Iface
173.15.213.184  0.0.0.0         255.255.255.248 U     0      0        0 eth0
172.16.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth1
0.0.0.0         173.15.213.190  0.0.0.0         UG    100    0        0 eth0
=====================================================================

The ifconfig output for the host system:
=====================================================================
br0       Link encap:Ethernet  HWaddr 00:e0:4d:c6:99:c3
           inet addr:172.16.0.2  Bcast:172.16.0.255  Mask:255.255.255.0
           inet6 addr: fe80::2e0:4dff:fec6:99c3/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:146811 errors:0 dropped:0 overruns:0 frame:0
           TX packets:24606 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:37120879 (37.1 MB)  TX bytes:3021581 (3.0 MB)

eth1      Link encap:Ethernet  HWaddr 00:e0:4d:c6:99:c3
           inet6 addr: fe80::2e0:4dff:fec6:99c3/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:230600 errors:0 dropped:0 overruns:0 frame:0
           TX packets:183194 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:53931942 (53.9 MB)  TX bytes:38845042 (38.8 MB)
           Interrupt:27 Base address:0x4000

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:29 errors:0 dropped:0 overruns:0 frame:0
           TX packets:29 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2690 (2.6 KB)  TX bytes:2690 (2.6 KB)

vethN4QBGs Link encap:Ethernet  HWaddr b6:60:19:4e:61:88
           inet6 addr: fe80::b460:19ff:fe4e:6188/64 Scope:Link
           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:78455 errors:0 dropped:0 overruns:0 frame:0
           TX packets:326555 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:10164679 (10.1 MB)  TX bytes:285821608 (285.8 MB)

vethOc6Aba Link encap:Ethernet  HWaddr ba:9f:51:d2:85:89
           inet6 addr: fe80::b89f:51ff:fed2:8589/64 Scope:Link
           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:208508 errors:0 dropped:0 overruns:0 frame:0
           TX packets:175209 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:274136769 (274.1 MB)  TX bytes:16783809 (16.7 MB)

vetha8K8GK Link encap:Ethernet  HWaddr 26:ca:52:e3:4c:11
           UP BROADCAST PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

vethbQHpmM Link encap:Ethernet  HWaddr ee:9b:06:4b:40:98
           inet6 addr: fe80::ec9b:6ff:fe4b:4098/64 Scope:Link
           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:47112 errors:0 dropped:0 overruns:0 frame:0
           TX packets:141789 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:21474951 (21.4 MB)  TX bytes:24055084 (24.0 MB)

vethfuRBD8 Link encap:Ethernet  HWaddr c2:49:5d:35:e4:a8
           inet6 addr: fe80::c049:5dff:fe35:e4a8/64 Scope:Link
           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:64830 errors:0 dropped:0 overruns:0 frame:0
           TX packets:140564 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6155988 (6.1 MB)  TX bytes:22442987 (22.4 MB)
=====================================================================

And its routing table:
=====================================================================
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use 
Iface
173.15.213.184  0.0.0.0         255.255.255.248 U     0      0        0 br0
172.16.0.0      0.0.0.0         255.255.255.0   U     0      0        0 br0
0.0.0.0         172.16.0.1      0.0.0.0         UG    100    0        0 br0
=====================================================================

Insofar as other data, I don't know what else to provide.  I am 
completely confused and I haven't the slightest clue how to debug this 
setup.  Am I doing something wrong with LXC that OpenVZ or full 
virtualization handles for me?  Have I stumbled upon some bug in the 
stack somewhere?

	Thanks a bunch!

	Mike

-- 
Michael B. Trausch                    Blog: http://mike.trausch.us/blog/
Tel: (404) 592-5746 x1                            Email: mike@trausch.us
