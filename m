From: Rick Jones <rick.jones2@hp.com>
Subject: Re: design for TSO performance fix
Date: Thu, 27 Jan 2005 16:51:31 -0800
Message-ID: <41F98C93.9040005@hp.com>
References: <20050127163146.33b01e95.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050127163146.33b01e95.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Ok, here is the best idea I've been able to come up with
> so far.
> 
> The basic idea is that we stop trying to build TSO frames
> in the actual transmit queue.  Instead, TSO packets are
> built impromptu when we actually output packets on the
> transmit queue.
> 
> Advantages:
> 
> 1) No knowledge of TSO frames need exist anywhere besides
>    tcp_write_xmit(), tcp_transmit_skb(), and
>    tcp_xmit_retransmit_queue()
> 
> 2) As a result of #1, all the pcount crap goes away.
>    The need for two MSS state variables (mss_cache,
>    and mss_cache_std) and assosciated complexity is
>    eliminated as well.
> 
> 3) Keeping TSO enabled after packet loss "just works".

Doubleplusgood.

> 
> 4) CWND sampled at the correct moment when deciding
>    the TSO packet arity.
> 
> The one disadvantage is that it might be a tiny bit more
> expensive to build TSO frames.  But I am sure we can find
> ways to optimize that quite well.
> 
> The main element of the TSO output logic is a function
> that is schemed as follows:
> 
> ...
> 
> If tcp_tso_build() fails, the caller just falls back to the
> normal path of sending the frames non-TSO one-by-one.
> 
> The logic is simple because if TSO is being done we know
> that all of the SKB data is paged (since SG+CSUM is a
> requirement for TSO).  The one case where that
> invariant might fail is due to a routing change (previous
> device cannot do SG+CSUM, new device has full TSO capability)
> and that is handled via the tcp_skb_data_all_paged() checks.
> 
> My thinking is that whatever added expensive this new scheme
> has, is offset by the simplifications the rest of the TCP
> stack will have since it will no longer need to know anything
> about multiple MSS values and packet counts.
> 
> Comments?

Does anything (need to) change wrt getting the size of the TSO's to increase as 
cwnd increases?

rick jones
