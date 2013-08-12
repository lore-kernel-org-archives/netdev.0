From: Timo Teras <timo.teras@iki.fi>
Subject: ipsec smp scalability and cpu use fairness (softirqs)
Date: Mon, 12 Aug 2013 16:01:42 +0300
Message-ID: <20130812160142.71737a95@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:34120 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034Ab3HLNBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 09:01:47 -0400
Received: by mail-ea0-f182.google.com with SMTP id o10so3437911eaj.27
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 06:01:45 -0700 (PDT)
Received: from vostro ([2001:1bc8:101:f402:21c:23ff:fefc:bf0b])
        by mx.google.com with ESMTPSA id k7sm57181186eeg.13.2013.08.12.06.01.44
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 12 Aug 2013 06:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been recently doing some ipsec benchmarking, and analysis on
system running out of cpu power. The setup is dmvpn gateway
(gre+xfrm+opennhrp) with traffic in forward path.

The system I have been using are VIA Nano (Padlock aes/sha accel) and
Intel Xeon (aes-ni and ssse3 sha1) based. In both setups the crypto
happens synchronously using special opcodes, or assembly implementation
of the algorithm.

It seems that the combination of softirq, napi and synchronous crypto
causes two problems.

1. Single core systems that are going out of cpu power, are
overwhelmed in uncontrollable manner. As softirq is doing the heavy
lifting, the user land processes are starved first. This can cause
userland IKE daemon to starve and lose tunnels when it is unable to
answer liveliness checks. The quick workaround is to setup traffic
shaping for the encrypted traffic.

2. On multicore (6-12 cores) systems, it would appear that it is not
easy to distribute the ipsec to multiple cores. as softirq is sticky to
the cpu where it was raised. The ipsec decryption/encryption is done
synchronously in the napi poll loop, and the throughput is limited by
one cpu. If the NIC supports multiple queues and balancing with ESP
SPI, we can use that to get some parallelism.

Fundamentally, both problems arise because synchronous crypto happens in
the softirq context. I'm wondering if it would make sense to execute
the synchronous crypto in low-priority per-xfrm_state workqueue or
similar.

Any suggestions or comments?
