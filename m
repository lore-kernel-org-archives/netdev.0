From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip : take care of last fragment in ip_append_data
Date: Tue, 21 Sep 2010 16:38:56 -0700 (PDT)
Message-ID: <20100921.163856.71124744.davem@davemloft.net>
References: <1285013853.2323.148.camel@edumazet-laptop>
	<1285018272.2323.243.camel@edumazet-laptop>
	<1285049787.2323.797.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbowler@elliptictech.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285049787.2323.797.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Sep 2010 08:16:27 +0200

> [PATCH] ip : take care of last fragment in ip_append_data
> 
> While investigating a bit, I found ip_fragment() slow path was taken
> because ip_append_data() provides following layout for a send(MTU +
> N*(MTU - 20)) syscall :
> 
> - one skb with 1500 (mtu) bytes
> - N fragments of 1480 (mtu-20) bytes (before adding IP header)
> last fragment gets 17 bytes of trail data because of following bit:
> 
> 	if (datalen == length + fraggap)
> 		alloclen += rt->dst.trailer_len;
> 
> Then esp4 adds 16 bytes of data (while trailer_len is 17... hmm...
> another bug ?)
> 
> In ip_fragment(), we notice last fragment is too big (1496 + 20) > mtu,
> so we take slow path, building another skb chain.
> 
> In order to avoid taking slow path, we should correct ip_append_data()
> to make sure last fragment has real trail space, under mtu...
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This patch largely looks fine, but:

1) I want to find out where that "17" tailer_len comes from before
   applying this, that doesn't make any sense.

2) Even with #1 addressed, this function is tricky so I want to review
   this patch some more.
