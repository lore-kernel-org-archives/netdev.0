From: jamal <hadi@cyberus.ca>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: 22 Mar 2005 22:57:34 -0500
Message-ID: <1111550254.1089.21.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <0fcf01c5077f$579e4b80$6e69690a@RIMAS>
	 <1107174142.8021.121.camel@jzny.localdomain>
	 <00c301c524b4$938cd240$6e69690a@RIMAS>
	 <1110379135.1091.143.camel@jzny.localdomain>
	 <1110416767.1111.76.camel@jzny.localdomain>
	 <025501c52552$2dbf87c0$6e69690a@RIMAS>
	 <1110453757.1108.87.camel@jzny.localdomain> <423B7BCB.10400@dsl.pipex.com>
	 <1111410890.1092.195.camel@jzny.localdomain>
	 <423F41AD.3010902@dsl.pipex.com>
	 <1111444869.1072.51.camel@jzny.localdomain>
	 <423F71C2.8040802@dsl.pipex.com> <1111462263.1109.6.camel@jzny.localdomain>
	 <42408998.5000202@dsl.pipex.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vNini9tDqgL1Ex1jILZE"
Cc: Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <42408998.5000202@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-vNini9tDqgL1Ex1jILZE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ok, Andy - I have tested this and should all work.
Can you double check on your side before i push kernel patch to Dave? I
tested on ubuntu distro on an AMD athlon.
Attached tar.gz with necessary patches. I only bothered to do 2 out of 3
tests. The second one covers the third. iptables libraries at runtime:
1.3.1

cheers,
jamal

-- start details (collected while i was testing) -----------

patch to kernel 2.6.11.5:
1)stats fix - attached as p_kernel

patch to tc:
1) stats - in patch file p_tc
2) mirred structure - in patch file p_tc
3) iptables headers copied from iptables 1.3.1 - both files in
attachment

bantu:~# uname -a
Linux bantu.foo 2.6.11.5 #1 Mon Mar 21 23:23:51 EST 2005 i686 GNU/Linux
bantu:~#

bantu:~# tc -V
tc utility, iproute2-ss050314
bantu:~#

TEST1:

Check if ipt works on its own and stats are fixed.

tc qdisc del dev eth0 ingress
tc qdisc add dev eth0 ingress

tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.2.24/32 flowid 1:16 \
action ipt -j TOS --set-tos Maximize-Reliability

** machine 10.0.2.24/32 is directly connected (via switch) to eth0

tc -s filter ls dev eth0 parent ffff:

bantu:~# tc -s filter ls dev eth0 parent ffff:
filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800: ht divisor 1
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16  (rule hit 0 success 0)
  match 0a000218/ffffffff at 12 (success 0 )
        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
        target TOS set Maximize-Reliability
        index 5 ref 1 bind 1 installed 10 sec used 10 sec
        Action statistics:
        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

ke82:~# ping -c 2 10.0.2.24
PING 10.0.2.24 (10.0.2.24) 56(84) bytes of data.
64 bytes from 10.0.2.24: icmp_seq=1 ttl=64 time=36.1 ms
64 bytes from 10.0.2.24: icmp_seq=2 ttl=64 time=3.79 ms

--- 10.0.2.24 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 3.798/19.960/36.122/16.162 ms
bantu:~#

bantu:~# tc -s filter ls dev eth0 parent ffff:
filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800: ht divisor 1
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16  (rule hit 2 success 2)
  match 0a000218/ffffffff at 12 (success 2 )
        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
        target TOS set Maximize-Reliability
        index 5 ref 1 bind 1 installed 109 sec used 36 sec
        Action statistics:
        Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

TEST2:
- check if ipt followed by another action works.
- check if mirred works

tc qdisc del dev eth0 ingress
tc qdisc add dev eth0 ingress

tc filter add dev eth0 parent ffff: protocol ip prio 6 \
u32 match ip src 10.0.2.24/32 flowid 1:16 \
action ipt -j TOS --set-tos Maximize-Reliability \
action mirred egress redirect dev lo

--> Installs fine

ping Replies should never be seen since they are redirected to 
loopback device; tcdump on dev lo should show them.Actually even
tcpdump on eth0 should see them - they just dont make it up the stack.

bantu:~# ping -c 2 10.0.2.24
PING 10.0.2.24 (10.0.2.24) 56(84) bytes of data.

--- 10.0.2.24 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1145ms

bantu:~#

bantu:~# tc -s filter ls dev eth0 parent ffff:
filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800: ht divisor 1
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16  (rule hit 2 success 2)
  match 0a000218/ffffffff at 12 (success 2 )
        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
        target TOS set Maximize-Reliability
        index 6 ref 1 bind 1 installed 128 sec used 123 sec
        Action statistics:
        Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0

        action order 2: mirred (Egress Redirect to device lo) stolen
        index 1 ref 1 bind 1 installed 128 sec used 123 sec
        Action statistics:
        Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
        rate 0bit 0pps backlog 0b 0p requeues 0



--=-vNini9tDqgL1Ex1jILZE
Content-Disposition: attachment; filename=iptmir.tgz
Content-Type: application/x-gzip; name=iptmir.tgz
Content-Transfer-Encoding: base64

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
RYoUKVKkSJGin5X+A1wqUg8AUAAA

--=-vNini9tDqgL1Ex1jILZE--
