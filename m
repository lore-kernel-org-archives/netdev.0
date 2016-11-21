From: jipan yang <jipan.yang@gmail.com>
Subject: Priority of HTB class on 10GbE
Date: Sun, 20 Nov 2016 23:04:39 -0800
Message-ID: <CAAiL-ps5=+BTAPcvp4Cr-qp1=E2CWoS4U5pUO-BAVrF07E-SpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35354 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbcKUHEl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 02:04:41 -0500
Received: by mail-oi0-f46.google.com with SMTP id b126so113550685oia.2
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 23:04:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Have been using htb with 1Gbe nic for traffic control of three classes
of traffic with priority 1,2 & 3,  the configuration worked perfectly.
The ceil of  higher priority traffic gets filled before that of lower
priority.

"
tc qdisc del dev enp1s0f1 root

# This line sets a HTB qdisc on the root of enp1s0f1, and it specifies
that the class 1:30 is used by default.
# It sets the name of the root as 1:, for future references.
tc qdisc add dev enp1s0f1 root handle 1: htb default 30

# This creates a class called 1:1, which is direct descendant of root
(the parent is 1:),
# this class gets assigned also an HTB qdisc, and then it sets a max
rate of 6mbits, with a burst of 15k
tc class add dev enp1s0f1 parent 1: classid 1:1  htb rate 1000mbit
ceil 1000mbit  burst 15k

# Class 1:10, which has a rate of 200mbit, ceil 800mbit
tc class add dev enp1s0f1 parent 1:1 classid 1:10 htb  rate 200mbit
ceil 800mbit  burst 15k  cburst 15k prio 1


# Class 1:20, which has a rate of 200 mbit, ceil 500mbit
tc class add dev enp1s0f1 parent 1:1  classid 1:20  htb  rate 200mbit
ceil 500mbit burst 15k cburst 15k  prio 2

# Class 1:30, which has a rate of 1mbit. This one is the default class.
tc class add dev enp1s0f1 parent 1:1 classid 1:30  htb rate 10mbit
ceil 1000mbit burst 15k cburst 15k prio 3

#sfq
tc qdisc add dev enp1s0f1 parent 1:10 handle 10: sfq perturb 10
tc qdisc add dev enp1s0f1 parent 1:20 handle 20: sfq perturb 10
tc qdisc add dev enp1s0f1 parent 1:30 handle 30: sfq perturb 10

tc filter add dev enp1s0f1 parent 1:  protocol ip prio 100 handle 100: cgroup
"


While moving to 10G nic on the same host,  I assumed same
configuration with the rate and ceil number timed 10 would also work,
but it turned out things started to fall apart.    The priority
setting doesn't seem to work, with 3 tcp connection, one on each
class, the iperf testing data doesn't make much sense, also the
throughput fluctuated a lot. I have tried to change parameters like
quantum, burst, cburst and etc. but none of them fixes the problem.

I'm wondering if this is known issue for HTB on 10G nic, if it is,
anyone already working on it?

Priority 1: class 1:10
[  4] 7362.00-7363.00 sec   518 MBytes  4.34 Gbits/sec  8825
538:339:391:3127:3891:281:223:35

[  4] 7363.00-7364.00 sec   507 MBytes  4.25 Gbits/sec  8809
540:321:486:3251:3904:174:121:12

[  4] 7364.00-7365.00 sec   496 MBytes  4.16 Gbits/sec  8793
585:264:530:3533:3694:114:67:6

[  4] 7365.00-7366.00 sec   481 MBytes  4.03 Gbits/sec  8761
552:242:747:3873:3304:27:14:2

[  4] 7366.00-7367.00 sec   484 MBytes  4.06 Gbits/sec  8783
596:239:650:3828:3462:6:2:0



Priority 2: class 1:20

[  4] 7401.00-7402.00 sec   488 MBytes  4.10 Gbits/sec  10151
1681:937:861:3046:3610:5:6:5

[  4] 7402.00-7403.00 sec   490 MBytes  4.11 Gbits/sec  10186
1688:979:857:3003:3646:6:3:4

[  4] 7403.00-7404.00 sec   454 MBytes  3.81 Gbits/sec  10499
2110:1103:1427:3639:2186:9:14:11

[  4] 7404.00-7405.00 sec   454 MBytes  3.81 Gbits/sec  10476
2118:1078:1400:3626:2210:10:22:12



Prority 3: class 1:30

  4] 7425.00-7426.00 sec   123 MBytes  1.03 Gbits/sec  5374
2926:521:622:1295:3:3:2:2

[  4] 7426.00-7427.00 sec   120 MBytes  1.01 Gbits/sec  5224
2782:580:609:1242:8:1:0:2

[  4] 7427.00-7428.00 sec   118 MBytes   989 Mbits/sec  5167
2764:577:594:1225:4:2:0:1

[  4] 7428.00-7429.00 sec   108 MBytes   906 Mbits/sec  4595
2331:594:562:1103:3:1:1:0

[  4] 7429.00-7430.00 sec   102 MBytes   856 Mbits/sec  4434
2262:601:550:1017:4:0:0:0

[  4] 7430.00-7431.00 sec   130 MBytes  1.09 Gbits/sec  5573
3006:535:626:1392:9:2:2:1

[  4] 7431.00-7432.00 sec   148 MBytes  1.25 Gbits/sec  6466
3500:633:762:1550:11:5:4:1



"
[root@dockerhost3 ~]# tc -s qdisc ls dev enp7s0f1

qdisc htb 1: root refcnt 65 r2q 10 default 30 direct_packets_stat 1425

 Sent 387791599974 bytes 256137127 pkt (dropped 32, overlimits
16471645 requeues 40)

 backlog 0b 5p requeues 40

qdisc sfq 10: parent 1:10 limit 127p quantum 1514b depth 127 divisor
1024 perturb 10sec

 Sent 170422902810 bytes 112564665 pkt (dropped 0, overlimits 0 requeues 0)

 backlog 68130b 1p requeues 0

qdisc sfq 20: parent 1:20 limit 127p quantum 1514b depth 127 divisor
1024 perturb 10sec

 Sent 164903555250 bytes 108919125 pkt (dropped 0, overlimits 0 requeues 0)

 backlog 68130b 1p requeues 0

qdisc sfq 30: parent 1:30 limit 127p quantum 1514b depth 127 divisor
1024 perturb 10sec

 Sent 52344279294 bytes 34573507 pkt (dropped 26, overlimits 0 requeues 0)

 backlog 204390b 3p requeues 0

[root@dockerhost3 ~]# tc -s filter  ls dev enp7s0f1

filter parent 1: protocol ip pref 100 cgroup handle 0x64

filter parent 1: protocol ip pref 100 cgroup handle 0x64

[root@dockerhost3 ~]# tc -s -d class show dev  enp7s0f1

class htb 1:1 root rate 10000Mbit ceil 10000Mbit burst 13750b/1 mpu 0b
overhead 0b cburst 0b/1 mpu 0b overhead 0b level 7

 Sent 387743091414 bytes 256105087 pkt (dropped 0, overlimits 0 requeues 0)

 rate 9862Mbit 828299pps backlog 0b 0p requeues 0

 lended: 828299 borrowed: 0 giants: 0

 tokens: -923 ctokens: -1095



class htb 1:10 parent 1:1 leaf 10: prio 1 quantum 200000 rate 2000Mbit
ceil 8000Mbit burst 15000b/1 mpu 0b overhead 0b cburst 14000b/1 mpu 0b
overhead 0b level 0

 Sent 170458534800 bytes 112588200 pkt (dropped 0, overlimits 0 requeues 0)

 rate 4222Mbit 353211pps backlog 0b 0p requeues 0

 lended: 353211 borrowed: 5040 giants: 0

 tokens: -4245 ctokens: -831



class htb 1:20 parent 1:1 leaf 20: prio 2 quantum 200000 rate 2000Mbit
ceil 5000Mbit burst 15000b/1 mpu 0b overhead 0b cburst 15000b/1 mpu 0b
overhead 0b level 0

 Sent 164938029030 bytes 108941895 pkt (dropped 0, overlimits 0 requeues 0)

 rate 4173Mbit 349256pps backlog 0b 1p requeues 0

 lended: 349256 borrowed: 4985 giants: 0

 tokens: -4073 ctokens: -1688



class htb 1:30 parent 1:1 leaf 30: prio 3 quantum 200000 rate
100000Kbit ceil 10000Mbit burst 15337b/1 mpu 0b overhead 0b cburst
13750b/1 mpu 0b overhead 0b level 0

 Sent 52346527584 bytes 34574992 pkt (dropped 26, overlimits 0 requeues 0)

 rate 1468Mbit 121414pps backlog 0b 3p requeues 0

 lended: 121414 borrowed: 4013 giants: 0

 tokens: -40758 ctokens: -665



class sfq 20:385 parent 20:

 (dropped 0, overlimits 0 requeues 0)

 backlog 68130b 1p requeues 0

 allot -67608



class sfq 30:2db parent 30:

 (dropped 0, overlimits 0 requeues 0)

 backlog 204390b 3p requeues 0

 allot -66792

"



Intel NIC:
07:00.1 Ethernet controller: Intel Corporation 82599ES 10-Gigabit
SFI/SFP+ Network Connection (rev 01)


root@dockerhost3 ~]# uname -a
Linux dockerhost3 3.10.0-327.28.3.el7.x86_64 #1 SMP Thu Aug 18
19:05:49 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

root@dockerhost3 ~]# modinfo sch_htb

filename:
/lib/modules/3.10.0-327.36.1.el7.x86_64/kernel/net/sched/sch_htb.ko

license:        GPL

rhelversion:    7.2

srcversion:     67A59870E047ACE13610650

depends:

intree:         Y

vermagic:       3.10.0-327.36.1.el7.x86_64 SMP mod_unload modversions

signer:         CentOS Linux kernel signing key

sig_key:        7F:74:0F:3F:87:67:80:2E:E9:3B:A2:3F:10:EA:75:8D:2F:6C:AB:E3

sig_hashalgo:   sha256

parm:           htb_hysteresis:Hysteresis mode, less CPU load, less
accurate (int)


parm:           htb_rate_est:setup a default rate estimator (4sec
16sec) for htb classes (int)



Thanks,

Jipan
