From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on
 inactive slaves
Date: Sat, 23 Jan 2016 07:23:09 -0800
Message-ID: <1453562589.1223.445.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-22 at 14:11 -0500, Jarod Wilson wrote:

> ---
>  net/core/dev.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8cba3d8..1354c7b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4153,8 +4153,11 @@ ncls:
>  		else
>  			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  	} else {
> +		if (deliver_exact)
> +			goto inactive; /* bond or team inactive slave */
>  drop:
>  		atomic_long_inc(&skb->dev->rx_dropped);
> +inactive:
>  		kfree_skb(skb);
>  		/* Jamal, now you will not able to escape explaining
>  		 * me how you were going to use this. :-)

Note that if you still have a kfree_skb() instead of consume_skb(),
some tools will still give you a wrong signal (packet dropped ...).

But then maybe the signal is telling some truth.

We receive a packet, and decide to drop it because no one was willing to
handle it.

Maybe someone wants to know a particular slave receives 10,000 such
frames per second and hurts performance with useless work.

We should at least increment some counter and maybe dump it with
"ethtool -S" or something.
