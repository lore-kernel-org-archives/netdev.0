From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Thu, 11 Sep 2008 00:01:15 +0200
Message-ID: <20080910220115.GH20815@postel.suug.ch>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org, kaber@trash.net,
	lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42994 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117AbYIJWAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 18:00:55 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-09-10 10:42
> +void cgroup_tc_set_sock_classid(struct sock *sk)
> +{
> +	if (sk)
> +		sk->sk_cgroup_classid = cgroup_tc_classid(current);
> +}
> +
> @@ -1170,6 +1171,8 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
>  	if (err < 0)
>  		goto out_module_put;
> 
> +	cgroup_tc_set_sock_classid(sock->sk);
> +
>  	/*
>  	 * Now to bump the refcnt of the [loadable] module that owns this
>  	 * socket at sock_release time we decrement its refcnt.
> @@ -1444,6 +1447,8 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
>  	if (err < 0)
>  		goto out_fd;
> 
> +	cgroup_tc_set_sock_classid(newsock->sk);
> +
>  	if (upeer_sockaddr) {
>  		if (newsock->ops->getname(newsock, (struct sockaddr *)address,
>  					  &len, 2) < 0) {

The big disadvantage of this method is that it does not allow to change
the classid for sockets which already exist. It inherits the classid
at socket creation time and then sticks to it. So if you want to follow
this approach I'd suggest to at least store a reference to the cgroup
state and reference count it properly.

As for the locking that you mentioned in the other thread. IMHO it is
not possible to lookup a socket without taking at least one lock, but
I might be wrong there. Actually I think it will take even more locks
as different locks are used to f.e. protect listening and established
tcp sockets.
