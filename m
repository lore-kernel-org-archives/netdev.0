From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 13 Aug 2013 09:23:12 +0300
Message-ID: <20130813092312.2493354e@vostro>
References: <20130812160142.71737a95@vostro>
	<CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:65145 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088Ab3HMGXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 02:23:17 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so3933230eek.22
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 23:23:16 -0700 (PDT)
In-Reply-To: <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Aug 2013 15:58:41 -0600
Andrew Collins <bsderandrew@gmail.com> wrote:

> On Mon, Aug 12, 2013 at 7:01 AM, Timo Teras <timo.teras@iki.fi> wrote:
> > 1. Single core systems that are going out of cpu power, are
> > overwhelmed in uncontrollable manner. As softirq is doing the heavy
> > lifting, the user land processes are starved first. This can cause
> > userland IKE daemon to starve and lose tunnels when it is unable to
> > answer liveliness checks. The quick workaround is to setup traffic
> > shaping for the encrypted traffic.
> 
> Which kernel version are you on?  I've found I've had better behavior
> since:
>
> commit c10d73671ad30f54692f7f69f0e09e75d3a8926a
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Jan 10 15:26:34 2013 -0800
> 
>     softirq: reduce latencies
> 
> as it bails from lengthy softirq processing much earlier, along with

The user process starvation observations are originally from 3.3/3.4
kernels, and I have not retested properly yet with newer ones.
Currently starting upgrades to 3.10. That commit looks like it will
directly fix mostly single core starvation issues.

I think netdev_budget mostly affects latencies for other softirqs,
since the rx softirq will be practically always on during the stress.

And it can still cause problems that encrypted and non-encrypted
packets still go through same queues. This means that when we are out
cpu, we can start dropping even non-encrypted packets early.

> tuning "netdev_budget" to avoid cycling for too long in the NAPI poll.
> 
> > 2. On multicore (6-12 cores) systems, it would appear that it is not
> > easy to distribute the ipsec to multiple cores. as softirq is
> > sticky to the cpu where it was raised. The ipsec
> > decryption/encryption is done synchronously in the napi poll loop,
> > and the throughput is limited by one cpu. If the NIC supports
> > multiple queues and balancing with ESP SPI, we can use that to get
> > some parallelism.
> 
> Although it's highly usecase dependent, I've had good luck using
> RPS.  I'm testing as an ipsec router however, not with an endpoint
> on the host itself, so it processes nearly all ipsec traffic in
> receive context.

Yes, RPS will help on many scenarios but not all. The flow dissector
knows only IP/TCP/UDP/GRE, but not ESP. So as long as traffic is
distributed between different IP-addresses, it is distributed. But if I
have lot of traffic between two nodes either with different ESP SPI
(different gatewayed subnets), or even with same SPI, then it won't.

For my scenario it will be usually even same SPI. So even if flow
dissector learns ESP and uses SPI in hash, I'd need a way to balance
traffic to multiple SAs.

I guess the place where I'd want to see the distribution to cores is
crypto_aead_*() calls. In fact, it seems there's code infracture
already for it: crypto/cryptd.c. Seems it needs to be manually
configured and only few places e.g. aesni gcm parts use it.

I'm wondering if it'd make sense to patch net/xfrm/xfrm_algo.c to use
cryptd? Or at least have a Kconfig or sysctl option make it do so.

- Timo
