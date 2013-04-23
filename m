From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 14:23:33 -0700
Message-ID: <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	<1366749094-5982-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33936 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab3DWVXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 17:23:38 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so687758pdj.20
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 14:23:38 -0700 (PDT)
In-Reply-To: <1366749094-5982-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Apr 2013 16:31:34 -0400
Willem de Bruijn <willemb@google.com> wrote:

> A cpu executing the network receive path sheds packets when its input
> queue grows to netdev_max_backlog. A single high rate flow (such as a
> spoofed source DoS) can exceed a single cpu processing rate and will
> degrade throughput of other flows hashed onto the same cpu.
> 
> This patch adds a more fine grained hashtable. If the netdev backlog
> is above a threshold, IRQ cpus track the ratio of total traffic of
> each flow (using 4096 buckets, configurable). The ratio is measured
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

What about just having a smarter ingress qdisc?
