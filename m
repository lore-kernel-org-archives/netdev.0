From: syrius.ml@no-log.org
Subject: Re: IMQ / new Dummy device post.
Date: Mon, 19 Apr 2004 16:22:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wazza.87ad18jbdl.fsf@message.id>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok it's seems to be working as expected for ipv4 traffic:

Here is how i'm actually using it:

(i use netfilter (for both ipv4 & ipv6) to mark packets)

OUT=dummy0
$TC qdisc add dev $OUT root handle 1: htb default 20

# CLASSES 
$TC class add dev $OUT parent 1: classid 1:1 htb rate $UL ceil $ULC \
    prio 0
$TC class add dev $OUT parent 1:1 classid 1:10 htb rate \
    $UL1 ceil $ULC1 quantum $QU1 prio 1
$TC class add dev $OUT parent 1:1 classid 1:2 htb rate $UL01 ceil \
    $ULC01 quantum $QU01 prio 2
$TC class add dev $OUT parent 1:2 classid 1:20 htb rate $UL2 ceil \
    $ULC2 quantum $QU2 prio 3
$TC class add dev $OUT parent 1:2 classid 1:3 htb rate $UL02 ceil \
    $ULC02 quantum $QU02 prio 4
$TC class add dev $OUT parent 1:3 classid 1:30 htb rate $UL3 ceil \
    $ULC3 quantum $QU3 prio 5
$TC class add dev $OUT parent 1:3 classid 1:40 htb rate $UL4 ceil \
    $ULC4 quantum $QU4 prio 5
$TC class add dev $OUT parent 1:3 classid 1:50 htb rate $UL5 ceil \
    $ULC5 quantum $QU5 prio 7

$TC qdisc add dev $OUT parent 1:10 handle 110: pfifo limit 50
$TC qdisc add dev $OUT parent 1:20 handle 120: sfq perturb 10
$TC qdisc add dev $OUT parent 1:30 handle 130: sfq perturb 10
$TC qdisc add dev $OUT parent 1:40 handle 140: sfq perturb 10
$TC qdisc add dev $OUT parent 1:50 handle 150: sfq perturb 10

# FILTERS
$TC filter add dev $OUT parent 1: protocol ip prio 10 handle 1 fw \
    flowid 1:10
$TC filter add dev $OUT parent 1: protocol ipv6 prio 11 handle 1 fw \
    flowid 1:10
$TC filter add dev $OUT parent 1: protocol ip prio 12 handle 2 fw \
    flowid 1:20
$TC filter add dev $OUT parent 1: protocol ipv6 prio 13 handle 2 fw \
    flowid 1:20
$TC filter add dev $OUT parent 1: protocol ip prio 14 handle 3 fw \
    flowid 1:30
$TC filter add dev $OUT parent 1: protocol ipv6 prio 15 handle 3 fw \
    flowid 1:30
$TC filter add dev $OUT parent 1: protocol ip prio 16 handle 4 fw \
    flowid 1:40
$TC filter add dev $OUT parent 1: protocol ipv6 prio 17 handle 4 fw \
    flowid 1:40
$TC filter add dev $OUT parent 1: protocol ip prio 18 handle 5 fw \
    flowid 1:50
$TC filter add dev $OUT parent 1: protocol ipv6 prio 19 handle 5 fw \
    flowid 1:50

$IP link set $OUT up

$TC qdisc add dev ppp0 root handle 1: prio
$TC filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 \
    match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0

$TC qdisc add dev tun0 root handle 1: prio
$TC filter add dev tun0 parent 1:0 protocol ip prio 10 u32 \
    match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0

$TC qdisc add dev sit1 root handle 1: prio
$TC filter add dev sit1 parent 1:0 protocol ipv6 prio 10 u32 \
    match u32 0 0 flowid 1:1 action mirred egress redirect dev dummy0


but it doesn't work with ipv6 traffic.
If I try to ping6 somehost, i sometimes get "ping: sendmsg: No buffer
space available" messages
anyway, there's nothing going out on sit1.

Is it the correct way to do it ?

-- 
