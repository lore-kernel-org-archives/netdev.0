From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Linux TCP's Robustness to Multipath Packet Reordering
Date: Mon, 25 Apr 2011 12:37:52 +0200
Message-ID: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39868 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758249Ab1DYKhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 06:37:53 -0400
Received: by iwn34 with SMTP id 34so1740791iwn.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 03:37:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Knowing how critical packet reordering is for standard TCP, I am
currently testing how robust Linux TCP is when packets are forwarded
over multiple paths (with different bandwidth and RTT). Since Linux
TCP adapts its "dupAck threshold" to an estimated level of packet
reordering, I expect it to be much more robust than a standard TCP
that strictly follows the RFCs. Indeed, as you can see in the
following plot, my experiments show a step-wise adaptation of Linux
TCP to heavy reordering. After many minutes, Linux TCP finally reaches
a data throughput close to the perfect aggregated data rate of two
paths (emulated with characteristics similar to IEEE 802.11b (WLAN)
and a 3G link (HSPA)):

http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-00.png

Does anyone have clues what's going on here? Why does the aggregated
throughput increase in steps? And what could be the reason it takes
minutes to adapt to the full capacity, when in other cases, Linux TCP
adapts much faster (for example if the bandwidth of both paths are
equal). I would highly appreciate some advice from the netdev
community.

Implementation details:
This multipath TCP experiment ran between a sending machine with a
single Ethernet interface (eth0) and a client with two Ethernet
interfaces (eth1, eth2). The machines are connected through a switch
and tc/netem is used to emulate the bandwidth and RTT of both paths.
TCP connections are established using iperf between eth0 and eth1 (the
primary path). At the sender, an iptables' NFQUEUE is used to "spoof"
the destination IP address of outgoing packets and force some to
travel to eth2 instead of eth1 (the secondary path). This multipath
scheduling happens in proportion to the emulated bandwidths, so if the
paths are set to 500 and 1000 KB/s, then packets are distributed in a
1:2 ratio. At the client, iptables' RAWDNAT is used to translate the
spoofed IP addresses back to their original, so that all packets end
up at eth1, although a portion actually travelled to eth2. ACKs are
not scheduled over multiple paths, but always travel back on the
primary path. TCP does not notice anything of the multipath
forwarding, except the side-effect of packet reordering, which can be
huge if the path RTTs are set very differently.

Best regards,
Dominik
