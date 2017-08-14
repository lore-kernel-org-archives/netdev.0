From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next V2 3/3] tap: XDP support
Date: Mon, 14 Aug 2017 10:43:54 +0200
Message-ID: <599162CA.4080504@iogearbox.net>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com> <1502451678-17358-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kubakici@wp.pl
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502451678-17358-4-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/2017 01:41 PM, Jason Wang wrote:
> This patch tries to implement XDP for tun. The implementation was
> split into two parts:
[...]
> @@ -1402,6 +1521,22 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>   	skb_reset_network_header(skb);
>   	skb_probe_transport_header(skb, 0);
>
> +	if (generic_xdp) {
> +		struct bpf_prog *xdp_prog;
> +		int ret;
> +
> +		rcu_read_lock();
> +		xdp_prog = rcu_dereference(tun->xdp_prog);

The name generic_xdp is a bit confusing in this context given this
is 'native' XDP, perhaps above if (generic_xdp) should have a comment
explaining semantics for tun and how it relates to actual generic xdp
that sits at dev->xdp_prog, and gets run from netif_rx_ni(). Or just
name the bool xdp_handle_gso with a comment that we let the generic
XDP infrastructure deal with non-linear skbs instead of having to
re-implement the do_xdp_generic() internals, plus a statement that
the actual generic XDP comes a bit later in the path. That would at
least make it more obvious to read, imho.

> +		if (xdp_prog) {
> +			ret = do_xdp_generic(xdp_prog, skb);
> +			if (ret != XDP_PASS) {
> +				rcu_read_unlock();
> +				return total_len;
> +			}
> +		}
> +		rcu_read_unlock();
> +	}
> +
>   	rxhash = __skb_get_hash_symmetric(skb);
>   #ifndef CONFIG_4KSTACKS
>   	tun_rx_batched(tun, tfile, skb, more);
>
