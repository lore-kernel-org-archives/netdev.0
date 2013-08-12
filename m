From: Andrew Collins <bsderandrew@gmail.com>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Mon, 12 Aug 2013 15:58:41 -0600
Message-ID: <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
References: <20130812160142.71737a95@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f44.google.com ([209.85.212.44]:33442 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332Ab3HLV6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 17:58:42 -0400
Received: by mail-vb0-f44.google.com with SMTP id e13so6146829vbg.31
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 14:58:41 -0700 (PDT)
In-Reply-To: <20130812160142.71737a95@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 7:01 AM, Timo Teras <timo.teras@iki.fi> wrote:
> 1. Single core systems that are going out of cpu power, are
> overwhelmed in uncontrollable manner. As softirq is doing the heavy
> lifting, the user land processes are starved first. This can cause
> userland IKE daemon to starve and lose tunnels when it is unable to
> answer liveliness checks. The quick workaround is to setup traffic
> shaping for the encrypted traffic.

Which kernel version are you on?  I've found I've had better behavior since:

commit c10d73671ad30f54692f7f69f0e09e75d3a8926a
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Jan 10 15:26:34 2013 -0800

    softirq: reduce latencies

as it bails from lengthy softirq processing much earlier, along with
tuning "netdev_budget" to avoid cycling for too long in the NAPI poll.

> 2. On multicore (6-12 cores) systems, it would appear that it is not
> easy to distribute the ipsec to multiple cores. as softirq is sticky to
> the cpu where it was raised. The ipsec decryption/encryption is done
> synchronously in the napi poll loop, and the throughput is limited by
> one cpu. If the NIC supports multiple queues and balancing with ESP
> SPI, we can use that to get some parallelism.

Although it's highly usecase dependent, I've had good luck using
RPS.  I'm testing as an ipsec router however, not with an endpoint
on the host itself, so it processes nearly all ipsec traffic in receive
context.

Andrew Collins
