From: "George B." <georgeb@gmail.com>
Subject: tcp mtu probing oddity - small packets
Date: Fri, 29 Jun 2012 10:43:24 -0700
Message-ID: <CAJ2iOjR0wqkLhBMrStTG3dq14i3xQSF-a2mYSyQeTBi3meMhCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35666 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab2F2RnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 13:43:25 -0400
Received: by werb14 with SMTP id b14so1186958wer.19
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2012 10:43:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is mainly meant to put this in the archive in case anyone else
has this problem.  It was a hair-puller.

Setup is a load balancer doing source NAT to a linux server.  Server
had /proc/sys/net/ipv4/tcp_mtu_probing=2

Apparently the PMTU probing somehow gets confused and the flow gets
clamped to the tcp_base_mss value (512 byte packets).  But this PMTU
value is apparently cached for all traffic to the IP address and since
that is a source NAT, ALL flows from that IP address get clamped to
512 byte packets.  So if something goes wonky with one flow, it
impacts all flows because they all appear to come from the same IP
address.

Setting tcp_mtu_probing to 1 has cleared the issue for now but it may
come back from time to time if a flow gets into trouble and whatever
Linux is doing in the PMTU probing causes the flow to be clamped to
tcp_base_mss but assuming that PMTU will age out at some point after
the problem client goes away, things should return to normal behavior.

There's something about how the PMTU probes work  that apparently
cause them to fail when activated in this particular configuration and
clamp the packet size to tcp_base_mss for all flows to that IP
address. If you are behind a source NAT, all flows share the same IP
address and so all flows get clamped.

Linux 2.6.38-11
