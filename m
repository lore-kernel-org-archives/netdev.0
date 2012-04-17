From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] l2tp: Introduce L2TPv3 IP encapsulation
 support for IPv6
Date: Tue, 17 Apr 2012 14:48:54 +0200
Message-ID: <1334666934.2472.36.camel@edumazet-glaptop>
References: <y>  <1334665766-11461-3-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64132 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072Ab2DQMs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 08:48:59 -0400
Received: by bkcik5 with SMTP id ik5so4511361bkc.19
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 05:48:58 -0700 (PDT)
In-Reply-To: <1334665766-11461-3-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 13:29 +0100, James Chapman wrote:
> L2TPv3 defines an IP encapsulation packet format where data is carried
> directly over IP (no UDP). The kernel already has support for L2TP IP
> encapsulation over IPv4 (l2tp_ip). This patch introduces support for L2TP
> IP encapsulation over IPv6.

...

> +	/* Check if the address belongs to the host. */
> +	if (addr_type != IPV6_ADDR_ANY) {
> +		struct net_device *dev = NULL;
> +
> +		if (addr_type & IPV6_ADDR_LINKLOCAL) {
> +			if (addr_len >= sizeof(struct sockaddr_in6) &&
> +			    addr->l2tp_scope_id) {
> +				/* Override any existing binding, if another
> +				 * one is supplied by user.
> +				 */
> +				sk->sk_bound_dev_if = addr->l2tp_scope_id;
> +			}
> +
> +			/* Binding to link-local address requires an
> +			   interface */
> +			if (!sk->sk_bound_dev_if)
> +				goto out_unlock;
> +
> +			err = -ENODEV;
> +			rcu_read_lock();
> +			dev = dev_get_by_index_rcu(sock_net(sk),
> +						   sk->sk_bound_dev_if);
> +			rcu_read_unlock();

			Here you can not dereference dev, since it can disappear after
rcu_read_unlock()

> +			if (!dev)
> +				goto out_unlock;
> +		}
> +
> +		/* ipv4 addr of the socket is invalid.  Only the
> +		 * unspecified and mapped address have a v4 equivalent.
> +		 */
> +		v4addr = LOOPBACK4_IPV6;
> +		err = -EADDRNOTAVAIL;

	So I suspect a potential problem here :

> +		if (!ipv6_chk_addr(sock_net(sk), &addr->l2tp_addr, dev, 0))
> +			goto out_unlock;
> +	}
> +

...

> +back_from_confirm:
> +	lock_sock(sk);
> +	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
> +			      ulen, transhdrlen, hlimit, tclass, opt,
> +			      &fl6, (struct rt6_info *)dst,
> +			      msg->msg_flags, dontfrag);
> +	if (err)
> +		ip6_flush_pending_frames(sk);
> +	else if (!(msg->msg_flags & MSG_MORE))
> +		err = l2tp_ip6_push_pending_frames(sk);
> +	release_sock(sk);
> +done:
> +	dst_release(dst);
> +out:
> +	fl6_sock_release(flowlabel);
> +
> +	/* Update stats */
> +	if (err < 0) {
> +		lsk->tx_errors++;
> +	} else {
> +		lsk->tx_packets++;

This is not SMP (especially on 32bit) safe, you dont own any lock

> +		lsk->tx_bytes += len;
> +	}
> +
> +	return err < 0 ? err : len;
> +
> +do_confirm:
> +	dst_confirm(dst);
> +	if (!(msg->msg_flags & MSG_PROBE) || len)
> +		goto back_from_confirm;
> +	err = 0;
> +	goto done;
> +}
> +
