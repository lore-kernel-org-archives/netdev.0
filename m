From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] rps: selective flow shedding during softnet overflow
Date: Fri, 19 Apr 2013 12:03:03 -0700
Message-ID: <20130419120303.222927c9@nehalam.linuxnetplumber.net>
References: <1366393612-16885-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:50660 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab3DSTDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 15:03:36 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so2387974pdj.12
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 12:03:35 -0700 (PDT)
In-Reply-To: <1366393612-16885-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Apr 2013 13:46:52 -0400
Willem de Bruijn <willemb@google.com> wrote:

> A cpu executing the network receive path sheds packets when its input
> queue grows to netdev_max_backlog. A single high rate flow (such as a
> spoofed source DoS) can exceed a single cpu processing rate and will
> degrade throughput of other flows hashed onto the same cpu.
> 
> This patch adds a more fine grained hashtable. If the netdev backlog
> is above a threshold, IRQ cpus track the ratio of total traffic of
> each flow (using 1024 buckets, configurable). The ratio is measured
> by counting the number of packets per flow over the last 256 packets
> from the source cpu. Any flow that occupies a large fraction of this
> (set at 50%) will see packet drop while above the threshold.
> 
> Tested:
> Setup is a muli-threaded UDP echo server with network rx IRQ on cpu0,
> kernel receive (RPS) on cpu0 and application threads on cpus 2--7
> each handling 20k req/s. Throughput halves when hit with a 400 kpps
> antagonist storm. With this patch applied, antagonist overload is
> dropped and the server processes its complete load.
> 
> The patch is effective when kernel receive processing is the
> bottleneck. The above RPS scenario is a extreme, but the same is
> reached with RFS and sufficient kernel processing (iptables, packet
> socket tap, ..).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

The netdev_backlog only applies for RPS and non-NAPI devices.
So this won't help if receive packet steering is not enabled.
Seems like a deficiency in the receive steering design rather
than the netdev_backlog.

Can't you do this with existing ingress stuff?
The trend seems to be put in more fixed infrastructure to deal with
performance and server problems rather than building general purpose
solutions.
