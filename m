From: Hasso Tepper <hasso@estpak.ee>
Subject: Some IPv6 related limit
Date: Sat, 15 Jan 2005 20:46:25 +0200
Message-ID: <200501152046.25747.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_BUW6Bfl4rdnbvJv"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_BUW6Bfl4rdnbvJv
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Some time ago IPv6 tunnelbroker I manage started to behave strangely. 
Loosing neighbors, packet loss, attempt to load ip6_tables module failed 
with message "Cannot allocate memory". I discovered that number of tunnels 
is problem. When problems apeared, there was 513 tunnels. I reduced number 
of tunnels and problems disappeared. Of course it was temporary only.

At first I thought that it's related to size of IPv6 routing table, but 
changing /proc/sys/net/ipv6/route/max_size didn't make any difference.

I can reproduce problem on my desktop and laptop as well (tested with 
2.4.29-rc1 and 2.6.10 kernels) with attached script. When I run this, about 
500 tunnels work fine, but for the rest there will be address added on 
tunnel, but not route to the interface for this address (adding route to the 
neighbor fails therefore too). About same time neighbors in LAN stop 
answering (ping6 -I eth0 ff02::1, only ::1 will answer). Removing tunnels 
makes all work again. I tried with vlans as well and can reproduce same 
problem, although for some reason number of vlans have to be bigger.

I'm hitting some IPv6 related limit in kernel probably. Is it known limit? 
Is there way to change this limit or is there workaround?


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator

--Boundary-00=_BUW6Bfl4rdnbvJv
Content-Type: application/x-shellscript;
  name="tunnels.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="tunnels.sh"

for i in `seq 1 254`
do
  ip tunnel add test1$i mode sit remote 10.10.1.$i local 10.10.10.154 ttl 64
  ip link set test1$i up
  ip -6 addr add 2001:db8:1:$i::1/64 dev test1$i
  ip -6 route add 2001:db8:11:$i::/64 via 2001:db8:1:$i::2
done

for i in `seq 1 254`
do
  ip tunnel add test2$i mode sit remote 10.10.2.$i local 10.10.10.154 ttl 64
  ip link set test2$i up
  ip -6 addr add 2001:db8:2:$i::1/64 dev test2$i
  ip -6 route add 2001:db8:21:$i::/64 via 2001:db8:2:$i::2
done

for i in `seq 1 254`
do
  ip tunnel add test3$i mode sit remote 10.10.3.$i local 10.10.10.154 ttl 64
  ip link set test3$i up
  ip -6 addr add 2001:db8:3:$i::1/64 dev test3$i
  ip -6 route add 2001:db8:31:$i::/64 via 2001:db8:3:$i::2
done

for i in `seq 1 254`
do
  ip tunnel add test4$i mode sit remote 10.10.4.$i local 10.10.10.154 ttl 64
  ip link set test4$i up
  ip -6 addr add 2001:db8:4:$i::1/64 dev test4$i
  ip -6 route add 2001:db8:41:$i::/64 via 2001:db8:4:$i::2
done


--Boundary-00=_BUW6Bfl4rdnbvJv--
