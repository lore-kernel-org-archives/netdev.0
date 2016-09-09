From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 09 Sep 2016 12:55:13 -0700
Message-ID: <1473450913.18970.59.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160909182636.GC2366@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34126 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbcIITzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 15:55:16 -0400
In-Reply-To: <20160909182636.GC2366@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-09 at 21:26 +0300, Cyrill Gorcunov wrote:

...

> +static int raw_diag_dump_one(struct sk_buff *in_skb,
> +			     const struct nlmsghdr *nlh,
> +			     const struct inet_diag_req_v2 *r)
> +{
> +	struct raw_hashinfo *hashinfo = raw_get_hashinfo(r);
> +	struct net *net = sock_net(in_skb->sk);
> +	struct sock *sk = NULL, *s;
> +	int err = -ENOENT, slot;
> +	struct sk_buff *rep;
> +
> +	if (IS_ERR(hashinfo))
> +		return PTR_ERR(hashinfo);
> +
> +	read_lock(&hashinfo->lock);
> +	for (slot = 0; slot < RAW_HTABLE_SIZE; slot++) {
> +		sk_for_each(s, &hashinfo->ht[slot]) {
> +			sk = raw_lookup(net, s, r);
> +			if (sk)
> +				break;
> +		}
> +	}
> +	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +		sk = NULL;
> +	read_unlock(&hashinfo->lock);
> +	if (!sk)
> +		return -ENOENT;
> +
> +	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
> +			sizeof(struct inet_diag_meminfo) + 64,
> +			GFP_KERNEL);
> +	if (!rep)

There is a missing sock_put(sk)

> +		return -ENOMEM;
> +
> +	err = inet_sk_diag_fill(sk, NULL, rep, r,
> +				sk_user_ns(NETLINK_CB(in_skb).sk),
> +				NETLINK_CB(in_skb).portid,
> +				nlh->nlmsg_seq, 0, nlh);

sock_put(sk);

> +	if (err < 0) {
> +		kfree_skb(rep);


> +		return err;
> +	}
> +
> +	err = netlink_unicast(net->diag_nlsk, rep,
> +			      NETLINK_CB(in_skb).portid,
> +			      MSG_DONTWAIT);
> +	if (err > 0)
> +		err = 0;
> +	return err;
> +}
> +
