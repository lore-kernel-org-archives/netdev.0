From: Alexei Starovoitov <ast@plumgrid.com>
Subject: spurious ip forwarding inside namespaces
Date: Tue, 5 Nov 2013 22:32:16 -0800
Message-ID: <CAMEtUuwKD76xEhysPbLum5wDYyJaX5p0JpdBQUcdHged40eHdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Isaku Yamahata <yamahata@valinux.co.jp>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:43401 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab3KFGcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:32:18 -0500
Received: by mail-wi0-f179.google.com with SMTP id hm4so3182372wib.6
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 22:32:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

commit 06a23fe31c
"core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()"
and refactoring 64261f230a
"dev: move skb_scrub_packet() after eth_type_trans()"

are forcing pkt_type to be PACKET_HOST when skb traverses veth.

which means that ip forwarding will kick in inside netns
even if skb->eth->h_dest != dev->dev_addr

The way we hit the problem is the following:
create 4 or more of netns with veth and attach them to a bridge.
disable learning on a bridge (via setageing 0), so it will flood
packets to all namespaces.
Since ip forwarding and icmp redirect by default is on,
single icmp request packet from one netns creates a storm of packets,
since every netns receives it and incorrectly does ip forward on it
and also incorrectly sends icmp redirect which are multiplied once
again by flooding in the bridge.
ping -c1 generates 1 outgoing packet and ~13K incoming packets with
just 4 netns.
Running any tcp traffic between such namespaces becomes impossible
and ksoftirqd cpu usage goes to 100% on all cpus.

Please suggest how to fix this cleanly.

Thanks
Alexei
