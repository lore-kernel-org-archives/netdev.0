From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V1 0/9] net: fragmentation performance
 scalability on NUMA/SMP systems
Date: Sat, 24 Nov 2012 18:31:05 -0800
Message-ID: <1353810665.2590.4774.camel@edumazet-glaptop>
References: <20121123130749.18764.25962.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:52678 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab2KYCbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 21:31:09 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so4868450iea.19
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 18:31:08 -0800 (PST)
In-Reply-To: <20121123130749.18764.25962.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-23 at 14:08 +0100, Jesper Dangaard Brouer wrote:
> This patchset implements significant performance improvements for
> fragmentation handling in the kernel, with a focus on NUMA and SMP
> based systems.
> 
> Review:
> 
>  Please review these patches.  I have on purpose added comments in the
>  code with the "//" comments style.  These comments are to be removed
>  before applying.  They serve as a questions to, you, the reviewer.
> 
> The fragmentation code today:
> 
>  The fragmentation code "protects" kernel resources, by implementing
>  some memory resource limitation code.  This is centered around a
>  global readers-writer lock, and (per network namespace) an atomic mem
>  counter and a LRU (Least-Recently-Used) list.  (Although separate
>  global variables and namespace resources, are kept for IPv4, IPv6
>  and Netfilter reassembly.)
> 
>  The code tries to keep the memory usage between a high and low
>  threshold (see: /proc/sys/net/ipv4/ipfrag_{high,low}_thresh).  The
>  "evictor" code cleans up fragments, when the high threshold is
>  exceeded, and stops only, when the low threshold is reached.
> 
> The scalability problem:
> 
>  Having a global/central variable for a resource limit is obviously a
>  scalability issue on SMP systems, and even amplified on a NUMA based
>  system.
> 


But ... , what practical workload even use fragments ?

Sure, netperf -t UDP_STREAM uses frags, but its a benchmark.

The only heavy user was NFS in the days it was using UDP, a very long
time ago.

A single lost fragment means the whole packet is lost.

Another problem with fragments is the lack of 4-tuple hashing, as only
the first frag contains the dst/src ports.

Also there is the sysctl_ipfrag_max_dist issue...

Hint : many NIC provide TSO (TCP offload), but none provide UFO,
probably because there is no demand for it.
