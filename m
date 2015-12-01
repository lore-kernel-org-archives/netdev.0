From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Tue, 1 Dec 2015 13:45:04 -0500
Message-ID: <20151201184504.GF21252@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <565DE446.2070609@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <565DE446.2070609@hpe.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/01/15 10:17), Rick Jones wrote:
> 
> What do the perf profiles show?  Presumably, loss of TSO/GSO means
> an increase in the per-packet costs, but if the ipsec path
> significantly increases the per-byte costs...

For ESP-null, there's actually very little work to do - we just
need to add the 8 byte ESP header with an spi and a seq#.. no
crypto work to do.. so the overhead *should* be minimal, else
we've painted ourself into a corner where we can't touch anything
including TCP options like md5.

perf profiles: I used perf tracepoints to instrument latency.
Yes, there is function call overhead for the xfrm path. So, for example,
the stack ends up being like this:
                          :
                  e5d2f2 ip_finish_output ([kerne.kallsyms])
                  75d6d0 ip_output ([kernel.kallsyms])
              7c08ad xfrm_output_resume ([kernel.kallsyms])
              7c0aae xfrm_output ([kernel.kallsyms])
              7b1bdd xfrm4_output_finish ([kernel.kallsyms])
              7b1c7e __xfrm4_output ([kernel.kallsyms])
              7b1dbe xfrm4_output ([kernel.kallsyms])
                  75bac4 ip_local_out ([kernel.kallsyms])
                  75c012 ip_queue_xmit ([kernel.kallsyms])
                  7736a3 tcp_transmit_skb ([kernel.kallsyms])
	                  :
where the detour into xfrm has been indented out, and esp_output
gets called out of xfrm_output_resume(). And as I said, there's
some nickels-and-dimes of perf to be squeezed out from 
better memory management in xfrm, but the fact that it doesnt move
beyond 3 Gbps strikes me as some other bottleneck/serialization.

> Short of a perf profile, I suppose one way to probe for per-packet
> versus per-byte would be to up the MTU.  That should reduce the
> per-packet costs while keeping the per-byte roughly the same.

actually the hack/rfc I sent out does help (in that it almost
doubles the existing 1.8 Gbps). Problem is that this cliff is much
steeper than that, and there's more hidden somewhere.

--Sowmini
