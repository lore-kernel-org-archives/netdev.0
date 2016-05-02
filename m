From: Ben Greear <greearb@candelatech.com>
Subject: Performance suggestions for bridging module?
Date: Mon, 2 May 2016 15:50:36 -0700
Message-ID: <5727D9BC.8040401@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:52647 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755173AbcEBWuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 18:50:37 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 703CA40A339
	for <netdev@vger.kernel.org>; Mon,  2 May 2016 15:50:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I have a network emulator module that acts a lot like an ethernet bridge.

It is implemented roughly like this:

Hook into the rx logic and steal packets in the rx-all logic, similar to how sniffers
work.

Then, it puts the packet onto a queue for transmit.

A kernel thread services this queue transmitting frames on a different NIC.

I am using spin-locks to protect this queue.

I am disabling LRO/GRO etc on the ixgbe NICs so that I don't have
to deal with linearization when trying to do corruptions and such.  Re-enabling
LRO/GRO makes the transmit logic use less CPU, but the RX logic is the bottleneck
anyway it seems.

The code, which is GPL, is here, in case someone wants to take a look:

http://www.candelatech.com/downloads/wanlink/

What I see is that this is very sensitive to which CPU core does what.
If I run the transmitter thread on cpu-0, performance is awful.  If I run
it on 1, then it is good.  Sometimes, though hard to reproduce, I can run
right at 10Gbps bi-directional throughput.  More often, it is stuck at
around 7Gbps bi-directional throughput.

I tried adding some prefetch logic, and that helped when emulating very long
latency (like, 10 seconds worth), but not sure I am really doing that optimally
either.

My basic question is:  Any suggestion for an optimal CPU core configuration
(most likely including binding a NIC's irqs to a particular core)??

Any other suggestions for things to look for?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
