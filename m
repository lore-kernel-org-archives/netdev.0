From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 27 Sep 2016 08:39:59 -0700
Message-ID: <1474990799.28155.54.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160927150831.GN1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34251 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932297AbcI0PkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:40:02 -0400
In-Reply-To: <20160927150831.GN1876@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-27 at 18:08 +0300, Cyrill Gorcunov wrote:

> +static struct sock *raw_sock_get(struct net *net, const struct inet_diag_req_v2 *r)
> +{
> +	struct raw_hashinfo *hashinfo = raw_get_hashinfo(r);
> +	struct sock *sk = NULL, *s;
> +	int slot;
> +
> +	if (IS_ERR(hashinfo))
> +		return ERR_CAST(hashinfo);
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

Minor detail, but note that raw sockets do not use rcu (yet)

Since you have read_lock(&hashinfo->lock), no writer can suddenly change
sk->sk_refcnt to a zero value.

Therefore, a mere "sock_hold(sk)" should be enough to get a reference on
the socket.

Using atomic_inc_not_zero() also works, but might distract/confuse the
next guy trying to understand this code ;)



> +	read_unlock(&hashinfo->lock);
> +
> +	return sk ? sk : ERR_PTR(-ENOENT);
> +}
> +
