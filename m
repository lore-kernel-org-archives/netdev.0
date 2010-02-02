From: Bernhard Schmidt <berni@birkenwald.de>
Subject: virtio GSO makes IPv6 unbearably slow - might be e100 problem?
Date: Tue, 2 Feb 2010 10:40:24 +0100
Message-ID: <20100202094024.GA23600@obelix.birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.69]:33853 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab0BBJsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 04:48:22 -0500
Received: from localhost (mail.svr02.mucip.net [127.0.0.1])
	by mailout.mucip.net (Postfix) with ESMTP id 9871E682
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2010 10:40:24 +0100 (CET)
Received: from mailout.mucip.net ([127.0.0.1])
	by localhost (mail.svr02.mucip.net [127.0.0.1]) (amavisd-new, port 10125)
	with ESMTP id KyWUq32BcVgb for <netdev@vger.kernel.org>;
	Tue,  2 Feb 2010 10:40:24 +0100 (CET)
Received: from obelix.birkenwald.de (obelix.oms16.birkenwald.de [IPv6:2001:a60:f001:1::69])
	by mailout.mucip.net (Postfix) with ESMTP id 76C811B7
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2010 10:40:24 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Forwarding from the KVM mailinglist, since an answer suggests it might
  actually be related to broken IPv6 GSO in e100 of the host ]

Hi,

I have a really weird issue all of the sudden on _one_ of my two KVM
hosts. The other one, while running on a different hardware in a
different network, is configured in a very similar way and does not show
these issues (so far).

Host:
- AMD Athlon64 3500+
- Debian testing amd64
- Kernel 2.6.32-trunk from Debian
- Debian qemu-kvm 0.11.1+dfsg-1

The system has a routed uplink (Intel e100) and an internal bridge, that
connects all the VMs (only virtual ports). Networking in the VMs is
usually configured like this:

-net nic,model=virtio,macaddr=00:16:3E:7C:30:AA -net
tap,ifname=vm.compile,script=no

The guests are Debian amd64, either testing or stable, running a custom
stripped 2.6.31.6 or 2.6.32.7. I've also tested older kernels (2.6.28.2
and 2.6.30.4) and have seen the same problem.

Problem:
IPv6 tx throughput from a Guest to a host in the internet is extremely
low (around 16kB/s). IPv6 rx is fine, as well as throughput in IPv4
(both ways). Also fine is throughput from the guest to the host and from
the host to the internet (also both ways). 

Running tcpdump on the tap-device on the host while doing an scp to
another system shows this:

20:43:27.130438 IP6 GUEST.59864 > DEST.22: Flags [.], seq 70785:73641, ack 2128, win 327, options [nop,nop,TS val 4294920148 ecr 63373335], length 2856
20:43:27.130506 IP6 HOST > GUEST: ICMP6, packet too big, mtu 1500, length 1240
20:43:27.131965 IP6 DEST.22 > GUEST.59864: Flags [.], ack 69357, win 501, options [nop,nop,TS val 63373335 ecr 4294920144], length 0
20:43:27.131996 IP6 DEST.22 > GUEST.59864: Flags [.], ack 70785, win 501, options [nop,nop,TS val 63373335 ecr 4294920144], length 0
20:43:27.132651 IP6 GUEST.59864 > DEST.22: Flags [.], seq 73641:76497, ack 2128, win 327, options [nop,nop,TS val 4294920148 ecr 63373335], length 2856
20:43:27.132704 IP6 HOST > GUEST: ICMP6, packet too big, mtu 1500, length 1240
20:43:27.346347 IP6 GUEST.59864 > DEST.22: Flags [.], seq 70785:72213, ack 2128, win 327, options [nop,nop,TS val 4294920202 ecr 63373335], length 1428
20:43:27.360411 IP6 DEST.22 > GUEST.59864: Flags [.], ack 72213, win 501, options [nop,nop,TS val 63373358 ecr 4294920202], length 0
20:43:27.361045 IP6 GUEST.59864 > DEST.22: Flags [.], seq 76497:79353, ack 2128, win 327, options [nop,nop,TS val 4294920205 ecr 63373358], length 2856

So, the guest sends packets of 2856 bytes, which are too large to pass
through the eth0 of the host (1500 bytes). Thus, the host rejects the
packet and sends back an ICMPv6 packet too big, which sometimes makes
the guest send at least one packet with the small MTU, but sometimes it
doesn't. This is repeated all over and slows down the process.

According to ethtool GSO is enabled on the guest, but disabling it using
ethtool does not have any effect. But giving the kernel
"virtio_net.gso=0" in append fixes the issue completely. 

Anyone having any ideas?

Best Regards,
Bernhard

