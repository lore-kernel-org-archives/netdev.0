From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Subject: Re: [RFC Patch v2] net: reserve ports for applications using fixed port numbers
Date: Thu, 4 Feb 2010 19:59:00 +0900
Message-ID: <201002041959.JEG43202.JQOFHFOVSFMtLO@I-love.SAKURA.ne.jp>
References: <20100204101533.4619.34599.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100204101533.4619.34599.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

Amerigo Wang wrote:
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index 2b79377..d3e160a 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -456,6 +456,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
>  		local_bh_disable();
>  		for (i = 1; i <= remaining; i++) {
>  			port = low + (i + offset) % remaining;
> +			if (inet_is_reserved_local_port(port))
> +				continue;
>  			head = &hinfo->bhash[inet_bhashfn(net, port,
>  					hinfo->bhash_size)];
>  			spin_lock(&head->lock);

I'm planning to add a LSM hook here.

If root user sets min port value less than 1024 to
/proc/sys/net/ipv4/ip_local_port_range , a process without CAP_NET_BIND_SERVICE
capability can bind to privileged port by "bind() with port == 0" or "connect()
without bind()" because the condition is

	err = -EACCES;
	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
		goto out;

I consider this is a security problem if MAC is enabled. MAC is used for
dividing root user's privilege. With MAC, somebody doing some part of root
user's jobs may set min port value to less than 1024.

Also, some applications needs fixed local port numbers (e.g. 3128 for Squid,
8080 for Tomcat). The port numbers I want to reserve are more complex than
simple min-max range like /proc/sys/net/ipv4/ip_local_reserved_ports .

Therefore, TOMOYO wants to insert a LSM hook (
http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/udp.c#L235
http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/inet_connection_sock.c#L114
http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/inet_hashtables.c#L459
) and allow reserving local ports like

  deny_autobind 0-1023
  deny_autobind 3128
  deny_autobind 8080

so that

  applications which need such ports won't be unexpectedly blocked by
  other application's temporary port usage (i.e. "bind() with port == 0" or
  "connect() without bind()")

and

  MAC guarantees that processes without CAP_NET_BIND_SERVICE can never bind
  to privileged port

.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
