From: syrius.ml@no-log.org
Subject: Re: IMQ / new Dummy device post.
Date: Wed, 21 Apr 2004 22:19:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wazza.87hdvddqxq.fsf@message.id>
References: <wazza.87ad18jbdl.fsf@message.id>
	<1082427350.1034.70.camel@jzny.localdomain>
	<wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <wazza.87fzaxmr6x.fsf@message.id> (syrius ml's message of "Wed,
 21 Apr 2004 14:49:26 +0200")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=


ok, i'm able to reproduce it with a simpler setup.

Let's consider I'm using the new dummy device on machine connected to
a ethernet lan. this host is using openvpn to establish a vpn tunnel.


debian:~# ip a l dev eth0
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:0c:29:25:4a:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.5.4/24 brd 192.168.5.255 scope global eth0

debian:~# ip a l dev tun0
4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP> mtu 1447 qdisc pfifo_fast
qlen 10
    link/ppp 
    inet 172.16.0.2 peer 172.16.0.1/32 scope global tun0

I attach the script i'm using to setup a simple new dummy+htb setup.

it's very simple, I do not use iptables to mark packets, i do not use
filter with htb, everything goes to the default classes (1:20 & 2:20)

I can verify it's working as expected with a simple ping -f 192.168.5.1
(or a ping -f 192.168.5.4 from 192.168.5.1)

after the ping -f 192.168.5.1 (let's say i let it run 30sec), if a do
ping 172.16.0.1 the oops appears !

I attach the result of ksymoops.

Please tell me if you're able to reproduce it.
I'm ok to try with another vpn software, but I don't think it has
anything to do with openvpn.


--=-=-=
Content-Type: text/x-sh
Content-Disposition: inline; filename=tc.sh
Content-Description: qos script

#!/bin/sh

TC=/usr/local/iproute2/sbin/tc
IP=/usr/local/iproute2/sbin/ip

OUT=dummy0
IN=dummy1

tc qdisc ls | sed -e 's/^.*dev \([a-zA-Z0-9]\+\) .*$/\1/' | sort -u | \
        while read a; do
                tc qdisc del dev $a root &>/dev/null
                tc qdisc del dev $a ingress &>/dev/null
        done

ifconfig $IN down &> /dev/null
ifconfig $OUT down &> /dev/null

if [ "$1" = "stop" ]
then
        exit
fi

###### uplink
# ROOT
$TC qdisc add dev $OUT root handle 1: htb default 20

# CLASSES
$TC class add dev $OUT parent 1: classid 1:1 htb rate 200kbit ceil 200kbit prio 0
$TC class add dev $OUT parent 1:1 classid 1:10 htb rate 100kbit ceil 200kbit prio 1
$TC class add dev $OUT parent 1:1 classid 1:20 htb rate 100kbit ceil 100kbit prio 2

$IP link set $OUT up
$TC qdisc add dev eth0 root handle 1: prio
$TC filter add dev eth0 parent 1:0 protocol ip prio 10 u32 \
        match u32 0 0 flowid 1:1 action mirred egress redirect dev $OUT

$TC qdisc add dev tun0 root handle 1: prio
$TC filter add dev tun0 parent 1:0 protocol ip prio 10 u32 \
        match u32 0 0 flowid 1:1 action mirred egress redirect dev $OUT

modprobe dummy

###### downlink
$TC qdisc add dev $IN root handle 2: htb default 20

# CLASSES
$TC class add dev $IN parent 2: classid 2:1 htb rate 100kbit ceil 200kbit prio 0
$TC class add dev $IN parent 2:1 classid 2:10 htb rate 100kbit ceil 200kbit prio 1
$TC class add dev $IN parent 2:1 classid 2:20 htb rate 100kbit ceil 100kbit prio 3

$IP link set $IN up

$TC qdisc add dev eth0 ingress
$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
        match u32 0 0 flowid 1:1 action mirred egress redirect dev $IN

$TC qdisc add dev tun0 ingress
$TC filter add dev tun0 parent ffff: protocol ip prio 10 u32 \
        match u32 0 0 flowid 1:1 action mirred egress redirect dev $IN


--=-=-=
Content-Disposition: inline; filename=ksymsoops.txt
Content-Description: ksymoops result

ksymoops 2.4.9 on i686 2.4.25.  Options used
     -v /mnt/vmlinux (specified)
     -k /mnt/ksyms (specified)
     -l /mnt/modules (specified)
     -o /lib/modules/2.4.25 (specified)
     -m /mnt/System.map (specified)

skput:under: c88863d8:126 put:14 dev:tun0kernel BUG at skbuff.c:113!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c01e088b>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00000282
eax: 00000029   ebx: c639ff40   ecx: c6434000   edx: c6777f7c
esi: c8888780   edi: 00000001   ebp: c6435db4   esp: c6435da0
ds: 0018   es: 0018   ss: 0018
Process openvpn (pid: 415, stackpage=c6435000)
Stack: c025e0a0 c88863d8 0000007e 0000000e c6706224 c6435de4 c88863e4 c67c0480 
       0000000e c88863d8 c1167420 c61eae00 c67c0540 c67c0480 c5ce8dc0 00000000 
       c6424880 c6435df8 c01f294d c6435e00 c5ce8dc0 c67c0540 c6435e64 c888311a 
Call Trace:    [<c88863d8>] [<c88863e4>] [<c88863d8>] [<c01f294d>] [<c888311a>]
  [<c021f17d>] [<c888a462>] [<c888a12b>] [<c01e5108>] [<c01e520f>] [<c01e54a9>]
  [<c01e55aa>] [<c011a854>] [<c8843c9f>] [<c8843353>] [<c013642b>] [<c01071bb>]
Code: 0f 0b 71 00 27 d1 25 c0 c9 c3 8d 74 26 00 8d bc 27 00 00 00 


>>EIP; c01e088b <skb_under_panic+3b/50>   <=====

>>ebx; c639ff40 <_end+609c4e0/84fc620>
>>ecx; c6434000 <_end+61305a0/84fc620>
>>edx; c6777f7c <_end+647451c/84fc620>
>>esi; c8888780 <[dummy]__module_license+a8/19a8>
>>ebp; c6435db4 <_end+6132354/84fc620>
>>esp; c6435da0 <_end+6132340/84fc620>

Trace; c88863d8 <[mirred]tcf_mirred+168/1d0>
Trace; c88863e4 <[mirred]tcf_mirred+174/1d0>
Trace; c88863d8 <[mirred]tcf_mirred+168/1d0>
Trace; c01f294d <tcf_action_exec+5d/90>
Trace; c888311a <[cls_u32]u32_classify+9a/1d0>
Trace; c021f17d <inet_recvmsg+4d/70>
Trace; c888a462 <[sch_ingress]tc_classify+52/cf>
Trace; c888a12b <[sch_ingress]ingress_enqueue+2b/80>
Trace; c01e5108 <ing_filter+68/c0>
Trace; c01e520f <netif_receive_skb+af/2d0>
Trace; c01e54a9 <process_backlog+79/110>
Trace; c01e55aa <net_rx_action+6a/100>
Trace; c011a854 <do_softirq+94/a0>
Trace; c8843c9f <[tun]tun_get_user+df/165>
Trace; c8843353 <[tun]tun_chr_write+33/40>
Trace; c013642b <sys_write+9b/130>
Trace; c01071bb <system_call+33/38>

Code;  c01e088b <skb_under_panic+3b/50>
00000000 <_EIP>:
Code;  c01e088b <skb_under_panic+3b/50>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c01e088d <skb_under_panic+3d/50>
   2:   71 00                     jno    4 <_EIP+0x4>
Code;  c01e088f <skb_under_panic+3f/50>
   4:   27                        daa    
Code;  c01e0890 <skb_under_panic+40/50>
   5:   d1 25 c0 c9 c3 8d         shll   0x8dc3c9c0
Code;  c01e0896 <skb_under_panic+46/50>
   b:   74 26                     je     33 <_EIP+0x33>
Code;  c01e0898 <skb_under_panic+48/50>
   d:   00 8d bc 27 00 00         add    %cl,0x27bc(%ebp)

 <0>Kernel panic: Aiee, killing interrupt handler!

--=-=-=



-- 

--=-=-=--
