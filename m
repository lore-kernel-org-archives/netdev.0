From: Dmitry Sytchev <kbdfck@gmail.com>
Subject: ipset-based "htb over mq/multiq" outgoing queue selection problem
Date: Wed, 4 Mar 2015 18:12:04 +0400
Message-ID: <CA+GmxbY-DmS+maLuwEV_dK-qapkJWDw8WxLAA6Hk+padz7vk6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:41102 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758148AbbCDOMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 09:12:06 -0500
Received: by widex7 with SMTP id ex7so30872131wid.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 06:12:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all!

I'm trying to setup shaper based on htb over mq / multiq with class
matching and queue selection done by ipset. I use kernel 3.19 and
latest git iptables/ipset/iproute.

Outgoing hardware queue selection doesn't work if I use ipset with
recent skbinfo additions plus iptables SET target, which seems to be
the fastest and most convenient way to match and process packets in my
case.

If I use tc filter skbedit action on outgoing interface to select
outgoing queue, everything works fine.
If I use tc filter on incoming interface, it doesn't work too, but I
actually don't know if these skbinfo marks may be persisted between
interfaces.

I create qdiscs after mq queues and trying to make packets go to
queues depending on ipset skbqueue/skbprio map.

I do the following:
$IPT -F -t mangle
$IPT -t mangle -A FORWARD -o $IF_OUT -j SET --map-set users dst
--map-prio --map-queue
$IPT -t mangle -A FORWARD -o $IF_IN -j SET  --map-set users src
--map-prio --map-queue
$IPT -t mangle -A FORWARD -o $IF_IN -j SET --map-set users src
--map-prio --map-queue
$IPT -t mangle -A FORWARD -o $IF_OUT -j SET  --map-set users dst
-map-prio --map-queue

ipset add users 1.1.1.1 skbqueue 3 skbprio 12:1

All packets still go to first queue, despite iptables show matches on
rules and applies maps (I added some debug output to netfilter SET
extension):
qdisc multiq 1: dev eth2 root refcnt 65 bands 4/64
qdisc htb 11: dev eth2 parent 1:1 r2q 2000 default 5
direct_packets_stat 29 direct_qlen 10000
qdisc htb 12: dev eth2 parent 1:2 r2q 2000 default 5
direct_packets_stat 0 direct_qlen 10000
qdisc htb 13: dev eth2 parent 1:3 r2q 2000 default 5
direct_packets_stat 0 direct_qlen 10000
qdisc htb 14: dev eth2 parent 1:4 r2q 2000 default 5
direct_packets_stat 0 direct_qlen 10000


If I use tc filter with skbedit action, everything  works fine:
tc filter add dev eth2 parent 1: protocol ip prio 1 u32 match ip src
1.1.1.1 action skbedit queue_mapping 3

Here we can see packets started to go 4th queue:
qdisc multiq 1: dev eth2 root refcnt 65 bands 4/64
qdisc htb 11: dev eth2 parent 1:1 r2q 2000 default 5
direct_packets_stat 29 direct_qlen 10000
qdisc htb 12: dev eth2 parent 1:2 r2q 2000 default 5
direct_packets_stat 0 direct_qlen 10000
qdisc htb 13: dev eth2 parent 1:3 r2q 2000 default 5
direct_packets_stat 0 direct_qlen 10000
qdisc htb 14: dev eth2 parent 1:4 r2q 2000 default 5
direct_packets_stat 14 direct_qlen 10000

How can the same behaviour be achieved with ipset? Or it requires
queue number to be set on rules of outgoing interface only, so it is
not possible with ipset+iptables at all? Or maybe there is some bug?

queue number in skbinfo is actually set in both cases (ipset and tc
skbedit), but when I set it with ipset in mangle FORWARD/POSTROUTING,
it doesn't seem to affect outgoung queue selection at all...

How can I debug it further?

-- 
Best regards,

Dmitry Sytchev,
IT Engineer
