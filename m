From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Bug? ARP with wrong src IP address
Date: Wed, 23 Jul 2003 17:12:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307231712000985.1CE20A63@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Problem Description:

1 ethernet interface IP (eth0): 192.168.128.16 netmask 255.255.255.0
1 loopback address IP (lo:2): 1.1.1.1 netmask 255.255.255.255
1 route to 2.2.2.2 through 192.168.128.60

A packet is sent from machine with IP 2.2.2.2 to the linux machine to dst IP 
1.1.1.1 (lo:2) through ethernet interface (eth0).

When linux machine tries to find out the mac address of 192.168.128.60 with 
ARP, it uses the loopback IP address (lo:2) as source insted of the IP address 
of the ethernet interface (eth0).

tcpdump output:
> tcpdump -nei eth0 arp or host 2.2.2.2
tcpdump: listening on eth0

00:29:38.385849 0:c:85:1f:a3:d6 0:48:54:6a:3a:dd 0800 64: 2.2.2.2.55302 > 
1.1.1.1.23: S 4186612861:4186612861(0) win 4128 <mss 1460> (DF) [tos 0xc0] 
00:29:38.386200 0:48:54:6a:3a:dd ff:ff:ff:ff:ff:ff 0806 42: arp who-has 
192.168.128.60 tell 1.1.1.1
00:29:39.385310 0:48:54:6a:3a:dd ff:ff:ff:ff:ff:ff 0806 42: arp who-has 
192.168.128.60 tell 1.1.1.1


ifconfig output:
> ifconfig -a
eth0      Link encap:Ethernet  HWaddr 00:48:54:6A:3A:DD  
          inet addr:192.168.128.16  Bcast:192.168.128.255  Mask:255.255.255.0
          inet6 addr: fe80::248:54ff:fe6a:3add/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2695 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2829 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100 
          RX bytes:308510 (301.2 Kb)  TX bytes:353754 (345.4 Kb)
          Interrupt:15 Base address:0xe000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:379 errors:0 dropped:0 overruns:0 frame:0
          TX packets:379 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:136862 (133.6 Kb)  TX bytes:136862 (133.6 Kb)

lo:2      Link encap:Local Loopback  
          inet addr:1.1.1.1  Mask:255.255.255.255
          UP LOOPBACK RUNNING  MTU:16436  Metric:1


route print:
> ip route list
2.2.2.2 via 192.168.128.60 dev eth0 
192.168.128.0/24 dev eth0  proto kernel  scope link  src 192.168.128.16 
default via 192.168.128.200 dev eth0  mtu 300

arp table:
> arp -a
? (192.168.128.202) at 00:30:B6:01:17:80 [ether] on eth0
router.newipnet.com (192.168.128.200) at 00:0C:85:1F:A3:D6 [ether] on eth0
? (192.168.128.60) at <incomplete> on eth0
madre.newipnet.com (192.168.128.4) at 00:E0:7D:7B:D3:8E [ether] on eth0


Steps to reproduce:

1. Setup Loopback interface
2. clear arp table
3. setup a route in another PC to reach the loopback address through IP in 
ethernet interface in linux box.
4. use ping from another PC to the loopback ip address.
5. You can see the ARP requests with wrong ip source address in linux box with 
tcpdump or ethereal.



Possible Patch (I have tried it and works, but not know if it's 100% accurate):

--- linux-2.6.0-test1/net/ipv4/arp.c      Mon Jul 14 05:37:28 2003
+++ linux-2.6.0-test1-patch/net/ipv4/arp.c    Wed Jul 23 15:31:29 2003
@@ -326,10 +326,14 @@
        u32 target = *(u32*)neigh->primary_key;
        int probes = atomic_read(&neigh->probes);
 
+        /* This don't work if the src addr is a loopback or similar.
+          See http://bugzilla.kernel.org/show_bug.cgi?id=978 
+
        if (skb && inet_addr_type(skb->nh.iph->saddr) == RTN_LOCAL)
                saddr = skb->nh.iph->saddr;
-       else
-               saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
+       else */
+
+       saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 
        if ((probes -= neigh->parms->ucast_probes) < 0) {
                if (!(neigh->nud_state&NUD_VALID))



Bug is reported in bugzilla:
http://bugzilla.kernel.org/show_bug.cgi?id=978


Regards,
Carlos Velasco
