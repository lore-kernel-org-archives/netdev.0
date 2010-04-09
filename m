From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] rfs: Receive Flow Steering
Date: Fri, 09 Apr 2010 09:37:50 +0200
Message-ID: <1270798670.2623.33.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63815 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386Ab0DIHhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:37:55 -0400
Received: by bwz1 with SMTP id 1so2317954bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 00:37:53 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 23:33 -0700, Tom Herbert a =C3=A9crit :

>  #ifdef CONFIG_RPS
> +/* One global table that all flow-based protocols share. */
> +struct rps_sock_flow_table *rps_sock_flow_table;
> +EXPORT_SYMBOL(rps_sock_flow_table);
> +
> +int rps_sock_flow_sysctl(ctl_table *table, int write, void __user *b=
uffer,
> +			 size_t *lenp, loff_t *ppos)
> +{
> +	unsigned int orig_size, size;
> +	int ret, i;
> +	ctl_table tmp =3D {
> +		.data =3D &size,
> +		.maxlen =3D sizeof(size),
> +		.mode =3D table->mode
> +	};
> +	struct rps_sock_flow_table *orig_sock_table, *sock_table;
> +
> +	rcu_read_lock();
> +
> +	orig_sock_table =3D rcu_dereference(rps_sock_flow_table);
> +	size =3D orig_size =3D orig_sock_table ? orig_sock_table->mask + 1 =
: 0;
> +
> +	ret =3D proc_dointvec(&tmp, write, buffer, lenp, ppos);
> +
> +	if (write) {
> +		if (size) {
> +			size =3D roundup_pow_of_two(size);
> +			if (size !=3D orig_size) {
> +				sock_table =3D
> +				    vmalloc(RPS_SOCK_FLOW_TABLE_SIZE(size));
> +				if (!sock_table) {
> +					rcu_read_unlock();
> +					return -ENOMEM;
> +				}
> +
> +				sock_table->mask =3D size - 1;
> +			} else
> +				sock_table =3D orig_sock_table;
> +
> +			for (i =3D 0; i < size; i++)
> +				sock_table->ents[i] =3D RPS_NO_CPU;
> +		} else
> +			sock_table =3D NULL;
> +
> +		if (sock_table !=3D orig_sock_table) {
> +			rcu_assign_pointer(rps_sock_flow_table, sock_table);
> +			synchronize_rcu();
> +			vfree(orig_sock_table);
> +		}
> +	}
> +
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
>  /

It is not allowed to call vmalloc() inside rcu_read_unlock() section.

Anyway, rcu_read_unlock() is not appropriate (you want mutual exclusion
betwen concurrent writers here)

You should use a mutex here.
Or a spinlock (if you do the vmalloc()/vfree() things outside of the
locked section)




