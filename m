From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Fri, 7 Dec 2012 14:51:29 +0000
Message-ID: <1354891889.2707.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<edumazet@google.com>, <therbert@google.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54713 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964965Ab2LGOvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:51:52 -0500
In-Reply-To: <1354826194-9289-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 15:36 -0500, Willem de Bruijn wrote:
> RPS and RFS balance load across cpus with flow affinity. This can
> cause local bottlenecks, where a small number or single large flow
> (DoS) can saturate one CPU while others are idle.
> 
> This patch maintains flow affinity in normal conditions, but
> trades it for throughput when a cpu becomes saturated. Then, packets
> destined to that cpu (only) are redirected to the lightest loaded cpu
> in the rxqueue's rps_map. This breaks flow affinity under high load
> for some flows, in favor of processing packets up to the capacity
> of the complete rps_map cpuset in all circumstances.
[...]
> --- a/Documentation/networking/scaling.txt
> +++ b/Documentation/networking/scaling.txt
> @@ -135,6 +135,18 @@ packets have been queued to their backlog queue. The IPI wakes backlog
>  processing on the remote CPU, and any queued packets are then processed
>  up the networking stack.
>  
> +==== RPS Overflow Protection
> +
> +By selecting the same cpu from the cpuset for each packet in the same
> +flow, RPS will cause load imbalance when input flows are not uniformly
> +random. In the extreme case, a single flow, all packets are handled on a
> +single CPU, which limits the throughput of the machine to the throughput
> +of that CPU. RPS has optional overflow protection, which disables flow
> +affinity when an RPS CPU becomes saturated: during overload, its packets
> +will be sent to the least loaded other CPU in the RPS cpuset. To enable
> +this option, set sysctl net.core.netdev_max_rps_backlog to be smaller than
> +net.core.netdev_max_backlog. Setting it to half is a reasonable heuristic.
[...]

This only seems to be suitable for specialised applications where a high
degree of reordering is tolerable.  This documentation should make that
very clear.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
