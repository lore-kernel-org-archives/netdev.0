From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 07 Jan 2016 04:52:30 -0800
Message-ID: <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-07 at 10:33 +0100, Vitaly Kuznetsov wrote:
> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
>  VLAN ID to flow_keys")) introduced a performance regression in netvsc
> driver. Is problem is, however, not the above mentioned commit but the
> fact that netvsc_set_hash() function did some assumptions on the struct
> flow_keys data layout and this is wrong. We need to extract the data we
> need (src/dst addresses and ports) after the dissect.
> 
> The issue could also be solved in a completely different way: as suggested
> by Eric instead of our own homegrown netvsc_set_hash() we could use
> skb_get_hash() which does more or less the same. Unfortunately, the
> testing done by Simon showed that Hyper-V hosts are not happy with our
> Jenkins hash, selecting the output queue with the current algorithm based
> on Toeplitz hash works significantly better.

Were tests done on IPv6 traffic ?

Toeplitz hash takes at least 100 ns to hash 12 bytes (one iteration per
bit : 96 iterations)

For IPv6 it is 3 times this, since we have to hash 36 bytes.

I do not see how it can compete with skb_get_hash() that directly gives
skb->hash for local TCP flows.

See commits b73c3d0e4f0e1961e15bec18720e48aabebe2109
("net: Save TX flow hash in sock and set in skbuf on xmit")
and 877d1f6291f8e391237e324be58479a3e3a7407c
("net: Set sk_txhash from a random number")

I understand Microsoft loves Toeplitz, but this looks not well placed
here.

I suspect there is another problem.

Please share your numbers and test methodology, and the alternative
patch Simon tested so that we can double check it.

Thanks.

PS: For the time being this patch can probably be applied on -net tree,
as it fixes a real bug.
