From: Antony Lesuisse <netdev-list@udev.org>
Subject: How to bypass the local routing table, to simulate a hub
Date: Fri, 12 Dec 2003 03:17:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031212021717.GA5695@udev.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Imagine, on a linux box, having 3 different network interfaces on the
same switch.  It is for simulating a network, using virtual tun/tap
interface:


----------------+-----+------------------------
Hub    simulator|Linux| Userspaces apps
                |     |
             ?--|-----|--- tap0 192.168.1.1
             ?  |     |
/dev/net/tun ?--|-----|--- tap1 192.168.1.2
             ?  |     |
             ?--|-----|--- tap2 192.168.1.3
                |     |
----------------+-----+-----------------------

How can you tell the linux networking stack that a packet for 192.168.1.2 has
to be sent via the network interface tap0 or tap2 (according to the sin_addr)
to the WIRE and be received by tap1?

I would like that, for packets that comes from process, the kernel
doesn't recognize the dest ip as local so that the packet will be sent
over the interface even if there is an other interface configurated with
the destination ip on the same kernel.

For example i will configure a HTTP server on tap2 binding 192.168.1.3:80
and i will launch an HTTP client binding IP 192.168.1.1 trying to make
TCP connection to 192.168.1.3:80 doing a GET. Everything on the same
computer. My hub simulator will sometimes simulate packet loss.

    ping -I tap0 192.168.1.2 should go trought my simulator and not use lo.

    ping 192.168.1.2 should go trought my simulator (ie using 192.168.1.1) as source

Acoording to my understanting of the linux network stack the problem is that
there is no way to skip the lookup in the local routing table:

You cannot change the 0: of ip rules

ip rule:
	0:	from all lookup local 
	32766:	from all lookup main 
	32767:	from all lookup default 

ip route show table local:
	local 192.168.1.1 dev eth0  proto kernel  scope host  src 192.168.1.1 
	local 192.168.1.2 dev eth0  proto kernel  scope host  src 192.168.1.2 
	local 192.168.1.3 dev eth0  proto kernel  scope host  src 192.168.1.3 
	...

Somebody on irc told me to do something like this:

	iptables -A PREROUTING -t mangle -p tcp -s MYIP1 -j MARK --set-mark 10
	iptables -A PREROUTING -t mangle -p tcp -s MYIP2 -j MARK --set-mark 20
	ip rule add fwmark 10 table first
	ip rule add from MYIP1 to 0.0.0.0/0 lookup second
	ip route add default via eth2 table second

But it doesn't change the fact that linux still lookup the local routing
table.

TIA
Antony Lesuisse

BONUS: Here is my small (but fully functionnal) network hub simulator in python:

#!/usr/bin/python2.2
# hub with a probabilty of 0.9
import fcntl,math,os,random,select,sys,time

# TUN TAP kernel interface
def net_alloc(name=""):
	s = len(name)
	if s>15:
		raise "name too long"
	fd = os.open("/dev/net/tun",os.O_RDWR)
	print fd
	if fd == -1:
		raise "could not open /dev/net/tun"
	ioctl_int = 0x400454ca
	ioctl_ifreq = name+(16-s)*'\x00'+'\x02'+15*'\x00'
	name = fcntl.ioctl(fd,ioctl_int,ioctl_ifreq)
	name = name[:name.find('\x00')]
	return (fd,name)

# Contruction of a hub
hub = []
hubname = {}
for i in range(2):
	fd,name = net_alloc()
	hub.append(fd)
	hubname[fd]={'fd':fd, 'name':name}
os.system("ifconfig -a")
os.system("ifconfig tap0 192.168.66.1; ifconfig tap1 192.168.66.2")

# hub simulation
while 1:
	(fdin,a,b) = select.select(hub,[],[],1.0)
	print "event:",fdin
	for i in fdin:
		frame = os.read(i,2048)
		print "%s:frame:%s"%(hubname[i]['name'],repr(frame))
		for j in hub:
			if j != i:
				if random.random() < 0.9:
					os.write(j,frame)
				else:
					print "lost:%s:to:%s"%(hubname[i]['name'],hubname[j]['name'])


-- 
Antony Lesuisse
GPG EA2CCD66: 4B7F 6061 3DF5 F07A ACFF  F127 6487 54F7 EA2C CD66
