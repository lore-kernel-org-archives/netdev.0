From: Cong Wang <cwang@twopensource.com>
Subject: Re: ipset-based "htb over mq/multiq" outgoing queue selection problem
Date: Wed, 4 Mar 2015 20:54:53 -0800
Message-ID: <CAHA+R7OPBW4z=qA81g+f43pU3NDRynOqa7o=pc1hzK+TA1WEyw@mail.gmail.com>
References: <CA+GmxbY-DmS+maLuwEV_dK-qapkJWDw8WxLAA6Hk+padz7vk6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Dmitry Sytchev <kbdfck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33258 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbCEEyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:54:54 -0500
Received: by igbhl2 with SMTP id hl2so39294789igb.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 20:54:53 -0800 (PST)
In-Reply-To: <CA+GmxbY-DmS+maLuwEV_dK-qapkJWDw8WxLAA6Hk+padz7vk6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 4, 2015 at 6:12 AM, Dmitry Sytchev <kbdfck@gmail.com> wrote:
> Hi all!
>
> I'm trying to setup shaper based on htb over mq / multiq with class
> matching and queue selection done by ipset. I use kernel 3.19 and
> latest git iptables/ipset/iproute.
>
> Outgoing hardware queue selection doesn't work if I use ipset with
> recent skbinfo additions plus iptables SET target, which seems to be
> the fastest and most convenient way to match and process packets in my
> case.
>
> If I use tc filter skbedit action on outgoing interface to select
> outgoing queue, everything works fine.
> If I use tc filter on incoming interface, it doesn't work too, but I
> actually don't know if these skbinfo marks may be persisted between
> interfaces.

It is not, it is recalculated after forwarding if the TX interface has less
queues than the skbqueue set either by the RX driver or you, since TX
interface may not be same with TX interface and may not have the
same number of hardware queues.

So how many queues do you have on your RX interface and TX
interface? (`ls /sys/class/net/$NIC/queues` can show you)

>
> I create qdiscs after mq queues and trying to make packets go to
> queues depending on ipset skbqueue/skbprio map.
>
> I do the following:
> $IPT -F -t mangle
> $IPT -t mangle -A FORWARD -o $IF_OUT -j SET --map-set users dst
> --map-prio --map-queue
> $IPT -t mangle -A FORWARD -o $IF_IN -j SET  --map-set users src
> --map-prio --map-queue
> $IPT -t mangle -A FORWARD -o $IF_IN -j SET --map-set users src
> --map-prio --map-queue
> $IPT -t mangle -A FORWARD -o $IF_OUT -j SET  --map-set users dst
> -map-prio --map-queue
>
> ipset add users 1.1.1.1 skbqueue 3 skbprio 12:1
>
> All packets still go to first queue, despite iptables show matches on
> rules and applies maps (I added some debug output to netfilter SET
> extension):
> qdisc multiq 1: dev eth2 root refcnt 65 bands 4/64
> qdisc htb 11: dev eth2 parent 1:1 r2q 2000 default 5
> direct_packets_stat 29 direct_qlen 10000
> qdisc htb 12: dev eth2 parent 1:2 r2q 2000 default 5
> direct_packets_stat 0 direct_qlen 10000
> qdisc htb 13: dev eth2 parent 1:3 r2q 2000 default 5
> direct_packets_stat 0 direct_qlen 10000
> qdisc htb 14: dev eth2 parent 1:4 r2q 2000 default 5
> direct_packets_stat 0 direct_qlen 10000
>
>
> If I use tc filter with skbedit action, everything  works fine:
> tc filter add dev eth2 parent 1: protocol ip prio 1 u32 match ip src
> 1.1.1.1 action skbedit queue_mapping 3
>
> Here we can see packets started to go 4th queue:
> qdisc multiq 1: dev eth2 root refcnt 65 bands 4/64
> qdisc htb 11: dev eth2 parent 1:1 r2q 2000 default 5
> direct_packets_stat 29 direct_qlen 10000
> qdisc htb 12: dev eth2 parent 1:2 r2q 2000 default 5
> direct_packets_stat 0 direct_qlen 10000
> qdisc htb 13: dev eth2 parent 1:3 r2q 2000 default 5
> direct_packets_stat 0 direct_qlen 10000
> qdisc htb 14: dev eth2 parent 1:4 r2q 2000 default 5
> direct_packets_stat 14 direct_qlen 10000
>
> How can the same behaviour be achieved with ipset? Or it requires
> queue number to be set on rules of outgoing interface only, so it is
> not possible with ipset+iptables at all? Or maybe there is some bug?

I guess skb->queue_mapping is cleared or recalculated somewhere
inbetween ipt FORWARD/POST_ROUTING and dev_queue_xmit().
