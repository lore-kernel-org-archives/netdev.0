From: Axel Reinhold <axel@freakout.de>
Subject: Re: sis900 and vlan support
Date: Sat, 14 May 2005 14:59:01 +0200 (CEST)
Message-ID: <200505141259.j4ECx1Gj007395@bongo.freakout.de>
References: <a36d6b20f493b0e80b82f68e5f157606@brownhat.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <a36d6b20f493b0e80b82f68e5f157606@brownhat.org>
To: Daniele Venzano <venza@brownhat.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

According to romieu@fr.zoreil.com:
Please keep netdev@oss.sgi.com in the Cc: : my mailboxes are not indexed
by Google nor accessible to the usual contributors.

According to Daniele Venzano:
> Thanks for the pointers, I'll see if there is something I can do, but 
> bear in mind that I'm not the 2.4 maintainer.
> 

If you could provde a patch - i'm happy.

> On 12/mag/05, at 20:00, Axel Reinhold wrote:
> > i tried the actual driver in a 2.4.30 tree:
> >
> > /lib/modules/2.4.30-ARXc3/kernel/drivers/net/sis900.o: unresolved
> > symbol pci_get_device
> > /lib/modules/2.4.30-ARXc3/kernel/drivers/net/sis900.o: unresolved
> > symbol pci_dev_put
> You should try a whole 2.6 kernel, not only the driver, there have been 
> big core changes and, as you have seen, things are no more compatible. 
> If I'm sure the problem exists also on 2.6 I can try to do something 
> about it.
> 

Can not use full 2.6 on my server at the moment. There are still
things not working in 2.6 (i need lvm-snapshots, umsdos, iBCS
emulation, ...) - so stuck into 2.4 for the next year at least.

> If I understand right to reproduce I have to load the vlan module, 
> create a vlan device (how??) and send packets with a size near to the 
> MTU. Right ?
> 

my setup:
modprobe sis900
modprobe 8021q
ifconfig eth0 192.168.207.68
vconfig add eth0 7
vconfig add eth0 8
ifconfig eth0.7 192.168.7.68
ifconfig eth0.8 192.168.8.68

the switchport must be configured as a trunc and allow tagged
vlan membership for at least VLAN 7 and 8.
You need another device in one of the VLANs to ping to.

Here's the output of a little test-script - it pings with sizes
from 1466 to 1474 - from 1470 on the ping failes: 

from dmesg:
sis900.c: v1.08.07 11/02/2003
PCI: Found IRQ 12 for device 00:01.1
eth0: SiS 900 Internal MII PHY transceiver found at address 1.
eth0: Using transceiver found at address 1 as default
eth0: SiS 900 PCI Fast Ethernet at 0xd400, IRQ 12, 00:e0:18:3a:db:1a.

802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
eth0.7: add 01:00:5e:00:00:01 mcast address to master interface
eth0.8: add 01:00:5e:00:00:01 mcast address to master interface

+ cat /proc/net/vlan/config
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth0.7         | 7  | eth0
eth0.8         | 8  | eth0
+ cat /proc/net/vlan/eth0.7
eth0.7  VID: 7   REORDER_HDR: 1  dev->priv_flags: 1
         total frames received:          192
          total bytes received:        13276
      Broadcast/Multicast Rcvd:            0

      total frames transmitted:          231
       total bytes transmitted:        41025
            total headroom inc:            0
           total encap on xmit:          231
Device: eth0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:
+ cat /proc/net/vlan/eth0.8
eth0.8  VID: 8   REORDER_HDR: 1  dev->priv_flags: 1
         total frames received:           99
          total bytes received:        16978
      Broadcast/Multicast Rcvd:            0

      total frames transmitted:          137
       total bytes transmitted:        14456
            total headroom inc:            0
           total encap on xmit:          137
Device: eth0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:
+ /sbin/ifconfig -s -a
Iface   MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0       1500   0     293      0      0      0     374      0      0      0 BMRU
eth0.7     1500   0     194      0      0      0     234      0      0      0 BMRU
eth0.8     1500   0      99      0      0      0     137      0      0      0 BMRU
ippp2      1500   0       0      0      0      0       0      0      0      0 OPRU
ippp6      1500   0       0      0      0      0       0      0      0      0 OPRU
lo        16436   0     689      0      0      0     689      0      0      0 LRU

+ ping -c4 -s1466 joes
PING joes.freakout.de (192.168.8.66) from 192.168.8.68 : 1466(1494) bytes of data.
1474 bytes from joes.freakout.de (192.168.8.66): icmp_seq=1 ttl=64 time=2.32 ms
1474 bytes from joes.freakout.de (192.168.8.66): icmp_seq=2 ttl=64 time=2.06 ms
1474 bytes from joes.freakout.de (192.168.8.66): icmp_seq=3 ttl=64 time=2.06 ms
1474 bytes from joes.freakout.de (192.168.8.66): icmp_seq=4 ttl=64 time=0.934 ms

--- joes.freakout.de ping statistics ---
4 packets transmitted, 4 received, 0% loss, time 3024ms
rtt min/avg/max/mdev = 0.934/1.848/2.326/0.540 ms

+ ping -c4 -s1468 joes
PING joes.freakout.de (192.168.8.66) from 192.168.8.68 : 1468(1496) bytes of data.
1476 bytes from joes.freakout.de (192.168.8.66): icmp_seq=1 ttl=64 time=2.10 ms
1476 bytes from joes.freakout.de (192.168.8.66): icmp_seq=2 ttl=64 time=0.921 ms
1476 bytes from joes.freakout.de (192.168.8.66): icmp_seq=3 ttl=64 time=2.06 ms
1476 bytes from joes.freakout.de (192.168.8.66): icmp_seq=4 ttl=64 time=0.905 ms

--- joes.freakout.de ping statistics ---
4 packets transmitted, 4 received, 0% loss, time 3029ms
rtt min/avg/max/mdev = 0.905/1.498/2.103/0.587 ms

+ ping -c4 -s1470 joes
PING joes.freakout.de (192.168.8.66) from 192.168.8.68 : 1470(1498) bytes of data.

--- joes.freakout.de ping statistics ---
4 packets transmitted, 0 received, 100% loss, time 2999ms

+ ping -c4 -s1472 joes
PING joes.freakout.de (192.168.8.66) from 192.168.8.68 : 1472(1500) bytes of data.

--- joes.freakout.de ping statistics ---
2 packets transmitted, 0 received, 100% loss, time 1018ms

+ ping -c4 -s1474 joes
PING joes.freakout.de (192.168.8.66) from 192.168.8.68 : 1474(1502) bytes of data.

--- joes.freakout.de ping statistics ---
1 packets transmitted, 0 received, 100% loss, time 0ms

-- 
|------------------------+--------------------------------------|
| Axel Reinhold          | Fax:   +49-9287-8244                 |
| Franz-Heinrich-Str. 20 | eMail: axel@freakout.de              |
| 95100 Selb             | http://www.freakout.de               |
| Germany          | Please do not send more than 100 kilobytes |
|------------------+--------------------------------------------|
| Fingerprint: 8D EF 9F 22 DF 9A 9B 68  E5 8C 12 C7 8D 6A 97 4E |
|---------------------------------------------------------------|
| Legal Warning: Do NOT send unsolicited commercial email to me |
