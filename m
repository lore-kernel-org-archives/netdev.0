From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: invalid socket structure with ip_early_demux
Date: Fri, 01 Feb 2013 18:16:10 -0800
Message-ID: <1359771370.30177.50.camel@edumazet-glaptop>
References: <510C752F.5010102@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: Steve Muckle <smuckle@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <510C752F.5010102@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-01 at 18:08 -0800, Steve Muckle wrote:
> Recently I've struggled with crashes in the xt_qtaguid netfilter module.
> This module is written by Google and used with Android. The match
> function in xt_qtaguid eventually tries to access
> 
>   skb->sk->sk_socket->file
> 
> What I find is that the sk->sk_socket pointer is sometimes 0xAAAAAAAA,
> or PAGE_POISON. In fact everything after the first 16 bytes of the
> struct sock sk is PAGE_POISON. I've confirmed that if I change
> PAGE_POISON, the values I see in the sk structure change as well.
> 
> I was curious how this structure was being allocated/initialized and
> instrumented the sk_alloc, sk_free, and sk_clone_lock functions. When
> xt_qtaguid encounters a bad struct sock, that sock does not show up as
> ever having been allocated (or freed).
> 
> The struct sock is being assigned to the skb in tcb_v4_early_demux(). I
> modified that function immediately after the sk is assigned from
> __inet_lookup_established() to panic if the sk has a sk_socket pointer
> of PAGE_POISON. I can reproduce that condition on my target by simply
> attempting to mount an NFS volume. Initiating *and* aborting wget
> operations also reproduces the issue - simply initiating a bunch of
> wgets is not enough to trigger it.
> 
> I have not yet been able to reproduce the bad condition when disabling
> ip_early_demux via the sysctl. Any possibility this is an actual issue
> with that feature? My target is an MSM using the ks8851 ethernet module.


skb->sk might be a TIMEWAIT socket.

Therefore, you cant blindly use skb->sk->sk_socket
