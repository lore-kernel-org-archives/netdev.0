From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: iproute2 action/policer question
Date: Tue, 09 Jun 2009 22:10:46 +0200
Message-ID: <4A2EC1C6.10806@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:59171 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbZFIUKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 16:10:47 -0400
Received: from unknown (HELO [192.168.1.11]) (itcare_pstaszewski@[83.7.235.183])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 9 Jun 2009 20:10:47 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I ask this question here
Someone here know proper use of iproute actions/policers ?
i want to achive somethink like this

$TC qdisc del dev eth0 root

$TC qdisc add dev eth0 root handle 1: hfsc default 10


$TC class add dev eth0 parent 1:0 classid 1:2 hfsc ls m2 1kbit ul m2 
10240kbit
$TC class add dev eth0 parent 1:0 classid 1:3 hfsc ls m2 1kbit ul m2 
10240kbit
$TC class add dev eth0 parent 1:0 classid 1:10 hfsc ls m2 1kbit ul m2 
10240kbit

$TC filter add dev eth0 parent 1: protocol ip prio 2 u32 match ip src 
10.0.0.1 flowid 1:2
$TC qdisc add dev eth0 parent 1:2 handle 2: sfq perturb 120
#$TC filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip src 
0/0 flowid 1:3
$TC qdisc add dev eth0 parent 1:3 handle 3: sfq perturb 120


#$TC filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip src 
0/0 flowid 1:3 action ipt -j MARK --set-mark 0x555 drop

$TC filter add dev eth0 parent 1: protocol ip prio 10 u32 \
  match ip src 0/0 flowid 1:3 \
  action ipt -j MARK --set-mark 1 \
  action police rate 1kbit burst 1k drop

So i want to MARK packet by use of action then pass packet to next 
action and drop if exceed 1kbit

This is only a sample but is not working

tc -s -d filter show dev eth0
filter parent 1: protocol ip pref 2 u32
filter parent 1: protocol ip pref 2 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 2 u32 fh 800::800 order 2048 key ht 
800 bkt 0 flowid 1:2  (rule hit 7913 success 7803)
  match 5ef6801c/ffffffff at 12 (success 7803 )
filter parent 1: protocol ip pref 10 u32
filter parent 1: protocol ip pref 10 u32 fh 801: ht divisor 1
filter parent 1: protocol ip pref 10 u32 fh 801::800 order 2048 key ht 
801 bkt 0 flowid 1:3  (rule hit 110 success 110)
  match 00000000/00000000 at 12 (success 110 )
        action order 1: tablename: mangle  hook: NF_IP_POST_ROUTING
        target MARK xset 0x1/0xffffffff
        index 13 ref 1 bind 1 installed 407 sec used 2 sec
        Action statistics:
        Sent 42351 bytes 110 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

        action order 2:  police 0x4 rate 1000bit burst 1023b mtu 2Kb 
action drop overhead 0b
ref 1 bind 1
        Action statistics:
        Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

iptables -L -n -v -t mangle
Chain PREROUTING (policy ACCEPT 19M packets, 19G bytes)
 pkts bytes target     prot opt in     out     source               
destination
    0     0 LOG        all  --  *      *       0.0.0.0/0            
0.0.0.0/0           mark match 0x1 LOG flags 0 level 4

Chain INPUT (policy ACCEPT 19M packets, 19G bytes)
 pkts bytes target     prot opt in     out     source               
destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               
destination
    0     0 LOG        all  --  *      *       0.0.0.0/0            
0.0.0.0/0           mark match 0x1 LOG flags 0 level 4

Chain OUTPUT (policy ACCEPT 11M packets, 17G bytes)
 pkts bytes target     prot opt in     out     source               
destination

Chain POSTROUTING (policy ACCEPT 11M packets, 17G bytes)
 pkts bytes target     prot opt in     out     source               
destination
    0     0 LOG        all  --  *      *       0.0.0.0/0            
0.0.0.0/0           mark match 0x1 LOG flags 0 level 4






Also is there someone who knows which actions from iptables can be used 
in iproute2 ?
because command like this ios not working:
tc filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip src 
0/0 flowid 1:3 action ipt -j LOG
 failed to find target LOG

bad action parsing
parse_action: bad value (3:ipt)!
Illegal "action"


iptables -t mangle -A FORWARD -j LOG
is working.
lsmod
Module                  Size  Used by
ipt_LOG                 4696  3
act_ipt                 3776  1
ifb                     3444  0
act_mirred              3328  0



What is the clue of this
So i want to make filter rule on the end of some traffic management 
based on iproute2 (this filter rule will be like default class so it 
catch all unclassified traffic and LOG or MARK this traffic, and i can 
know that somewhere in my net is unclassified ip address.)
Because in normal operation if you use only iproute2 you have default 
class and you dont know what is going to this default class - this is 
hard if you use hfsc because of default class that is always active and 
matches all traffic from interface that root is attached.


