From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 3/3] tun: rx batching
Date: Sat, 31 Dec 2016 12:31:47 -0500 (EST)
Message-ID: <20161231.123147.1116351209865273335.davem@davemloft.net>
References: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
	<1483075251-6889-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	wexu@redhat.com, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1483075251-6889-4-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 30 Dec 2016 13:20:51 +0800

> @@ -1283,10 +1314,15 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  	skb_probe_transport_header(skb, 0);
>  
>  	rxhash = skb_get_hash(skb);
> +
>  #ifndef CONFIG_4KSTACKS
> -	local_bh_disable();
> -	netif_receive_skb(skb);
> -	local_bh_enable();
> +	if (!rx_batched) {
> +		local_bh_disable();
> +		netif_receive_skb(skb);
> +		local_bh_enable();
> +	} else {
> +		tun_rx_batched(tfile, skb, more);
> +	}
>  #else
>  	netif_rx_ni(skb);
>  #endif

If rx_batched has been set, and we are talking to clients not using
this new MSG_MORE facility (or such clients don't have multiple TX
packets to send to you, thus MSG_MORE is often clear), you are doing a
lot more work per-packet than the existing code.

You take the queue lock, you test state, you splice into a local queue
on the stack, then you walk that local stack queue to submit just one
SKB to netif_receive_skb().

I think you want to streamline this sequence in such cases so that the
cost before and after is similar if not equivalent.
