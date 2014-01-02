From: Vincent Li <vincent.mc.li@gmail.com>
Subject: How to test netfilter SYNPROXY target properly?
Date: Thu, 2 Jan 2014 15:30:21 -0800
Message-ID: <CAK3+h2wX3PvcMyNhYWYTnxyQyr9YN_2Mzr21gD4OrpF2P6+TcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick

I should have put this question in user list instead of dev list, but
I couldn't find any user based documentation on how to test the
SYNPROXY target other than the message in the SYNPROXY patch series.
so here is my setup:

---packet flow

client 10.1.72.99 (vlan 1101)  <->Linux with SYNPROXY rule - 10.1.72.9
(vlan 1101) 10.2.72.139 (vlan 1102) <->server 10.2.72.99

---configuration

Linux with SYNPROXY iptables rules:


# Define network interfaces
EXTIF="eth1.1101"
INTIF="eth1.1102"
#
# Flushing out existing iptables entries
iptables -P INPUT ACCEPT
iptables -F INPUT
iptables -P OUTPUT ACCEPT
iptables -F OUTPUT
iptables -P FORWARD ACCEPT
iptables -F FORWARD
iptables -t nat -F
#
# Allow all outbound traffic and only allow established and related
connections back in
iptables -A FORWARD -i $EXTIF -o $INTIF -m state --state
ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $INTIF -o $EXTIF -j ACCEPT
iptables -A FORWARD -j LOG
#
# Masquerade NAT functionality on $EXTIF
iptables -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
#
# Allows ssh inbound connections
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#
# Allows lo interface to work
iptables -A INPUT -i lo -j ACCEPT
#
# Default DROP
iptables -A INPUT -i $EXTIF -j DROP

########simple firewall router/nat

#####netfilter SYNPROXY iptable rule
/usr/local/sbin/iptables -t raw -A PREROUTING -i $EXTIF -p tcp --dport
80 --syn -j NOTRACK
/usr/local/sbin/iptables -A INPUT -i $EXTIF -p tcp --dport 80 -m state
--state UNTRACKED,INVALID -j SYNPROXY --sack-perm --timestamp --mss
1460 --wscale 5
echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose

Linux with SYNPROXY interfaces:

eth1.1101 Link encap:Ethernet  HWaddr 00:15:60:0e:3d:09
          inet addr:10.1.72.9  Bcast:10.1.255.255  Mask:255.255.0.0
          inet6 addr: fe80::215:60ff:fe0e:3d09/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:15835 errors:0 dropped:0 overruns:0 frame:0
          TX packets:32 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:723297 (723.2 KB)  TX bytes:5542 (5.5 KB)

eth1.1102 Link encap:Ethernet  HWaddr 00:15:60:0e:3d:09
          inet addr:10.2.72.139  Bcast:10.2.255.255  Mask:255.255.0.0
          inet6 addr: fe80::215:60ff:fe0e:3d09/64 Scope:Link
          inet6 addr: fd5a:7195:e993:0:10:2:72:139/112 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:10077 errors:0 dropped:0 overruns:0 frame:0
          TX packets:60 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:480391 (480.3 KB)  TX bytes:7849 (7.8 KB)

tcp_syncookies are turned on

root@vincent-hp:/home/vincent/linux# cat /proc/sys/net/ipv4/tcp_syncookies
1


---test steps

1 from client, run curl to send HTTP request to server

#curl http://10.2.72.99

2, run tcpdump on Linux with SYNPROXY target setup

root@vincent-hp:~# tcpdump -nn -i eth1 port 80

15:03:21.737643 vlan 1101, p 0, IP 10.1.72.99.43015 > 10.2.72.99.80:
Flags [S], seq 1709811771, win 5840, options [mss 1460,sackOK,TS val
1529239892 ecr 0,nop,wscale 5], length 0
15:03:21.737702 vlan 1102, p 0, IP 10.1.72.99.43015 > 10.2.72.99.80:
Flags [S], seq 1709811771, win 5840, options [mss 1460,sackOK,TS val
1529239892 ecr 0,nop,wscale 5], length 0
15:03:21.738161 vlan 1102, p 0, IP 10.2.72.99.80 > 10.1.72.99.43015:
Flags [S.], seq 3989558297, ack 1709811772, win 5792, options [mss
1460,sackOK,TS val 17487273 ecr 1529239892,nop,wscale 5], length 0
15:03:21.738180 vlan 1101, p 0, IP 10.2.72.99.80 > 10.1.72.99.43015:
Flags [S.], seq 3989558297, ack 1709811772, win 5792, options [mss
1460,sackOK,TS val 17487273 ecr 1529239892,nop,wscale 5], length 0
15:03:21.741240 vlan 1101, p 0, IP 10.1.72.99.43015 > 10.2.72.99.80:
Flags [.], ack 1, win 183, options [nop,nop,TS val 1529239892 ecr
17487273], length 0
15:03:21.741271 vlan 1102, p 0, IP 10.1.72.99.43015 > 10.2.72.99.80:
Flags [.], ack 1, win 183, options [nop,nop,TS val 1529239892 ecr
17487273], length 0

my understanding is that from tcpdump, I should see SYN, SYN+ACK, ACK
between client and SYNPROXY unit on vlan 1101, if the syn cookie from
client is valid, then SYNPROXY unit will send SYN to server on vlan
1102, but the tcpdump capture does not show what I understand.

I also checked the /proc/net/stat/synproxy states, it is all 0

root@vincent-hp:/home/vincent/linux# cat /proc/net/stat/synproxy
entries         syn_received    cookie_invalid  cookie_valid
cookie_retrans  conn_reopened
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000
00000000        00000000        00000000        00000000
00000000        00000000

I think I might miss something and not testing the SYNPROXY properly, any clue?

Regards,

Vincent
