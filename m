From: David Miller <davem@davemloft.net>
Subject: Re: Problem with "tcp: bind() fix when many ports are bound" commit
Date: Wed, 28 Apr 2010 09:50:32 -0700 (PDT)
Message-ID: <20100428.095032.32709294.davem@davemloft.net>
References: <4BD82B29.3000105@retis.net.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: grzegorz.chwesewicz@retis.net.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41649
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752953Ab0D1Qu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 12:50:26 -0400
In-Reply-To: <4BD82B29.3000105@retis.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grzegorz Chwesewicz <grzegorz.chwesewicz@retis.net.pl>
Date: Wed, 28 Apr 2010 14:33:45 +0200

> 	Hi, I have a problem with binding to port with the latest git kernel
> (my HEAD is at 1600f9def09de07c5dbeb539e978fa73880690dd). Please CC to
> me as I'm not subscribed to the list.

Please send networking bug reports CC:'d to netdev and the people
who wrote and signed off on the commit you've narrowed down the
problem to.

Otherwise the appropriate people will take longer to find out about
your bug, and therefore the bug will take longer to fix than
necessary.

Thanks.

> 
> Example with buggy kernel:
> 
> ensima-hp ~ # /etc/init.d/apache2 start
>  * Starting apache2 ...
> (98)Address already in use: make_sock: could not bind to address
> 127.0.0.1:80
> no listening sockets available, shutting down
> Unable to open logs
> 
> As you can see nothing is listening on port 80, but there are old
> connections to port 80 with CLOSE_WAIT and FIN_WAIT2 state.
> 
> ensima-hp ~ # netstat -pan --inet|grep 80
> netstat: no support for `AF INET (sctp)' on this system.
> tcp        0      0 127.0.0.1:631           0.0.0.0:*
> LISTEN      4806/cupsd
> tcp        1      0 127.0.0.1:54040         127.0.0.1:80
> CLOSE_WAIT  5814/konquerorHk573
> tcp        0      0 127.0.0.1:80            127.0.0.1:54042
> FIN_WAIT2   -
> tcp        0      0 127.0.0.1:80            127.0.0.1:54040
> FIN_WAIT2   -
> tcp        1      0 127.0.0.1:54042         127.0.0.1:80
> CLOSE_WAIT  6175/konquerordx573
> 
> So I can't start apache as long as these connections are not fully
> closed, after that apache starts without problems.
> 
> ensima-hp ~ # netstat -pan --inet|grep 80
> netstat: no support for `AF INET (sctp)' on this system.
> tcp        0      0 127.0.0.1:631           0.0.0.0:*
> LISTEN      4806/cupsd
> 
> ensima-hp ~ # /etc/init.d/apache2 start
>  * Starting apache2 ...		[OK]
> 
> Problem occured between 2.6.34-rc4 and latest git, bisect shows that the
> problem is caused by:
> 
> commit fda48a0d7a8412cedacda46a9c0bf8ef9cd13559
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Wed Apr 21 09:26:15 2010 +0000
> 
> tcp: bind() fix when many ports are bound
> 
> Reverting this commit from current HEAD, resolving conflict in
> 'net/ipv6/inet6_connection_sock.c' file, and compiling new kernel solves
> the problem.
> 
> 'net/ipv6/inet6_connection_sock.c' before resolving conflict:
> 
>  41         sk_for_each_bound(sk2, node, &tb->owners) {
>  42                 if (sk != sk2 &&
>  43                     (!sk->sk_bound_dev_if ||
>  44                      !sk2->sk_bound_dev_if ||
>  45 <<<<<<< HEAD
>  46                      sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
>  47                         if ((!sk->sk_reuse || !sk2->sk_reuse ||
>  48                              sk2->sk_state == TCP_LISTEN) &&
>  49                              ipv6_rcv_saddr_equal(sk, sk2))
>  50                                 break;
>  51                         else if (sk->sk_reuse && sk2->sk_reuse &&
>  52                                 !ipv6_addr_any(inet6_rcv_saddr(sk)) &&
>  53                                 ipv6_rcv_saddr_equal(sk, sk2))
>  54                                 break;
>  55                 }
>  56 =======
>  57                      sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
>  58                     (!sk->sk_reuse || !sk2->sk_reuse ||
>  59                      sk2->sk_state == TCP_LISTEN) &&
>  60                      ipv6_rcv_saddr_equal(sk, sk2))
>  61                         break;
>  62 >>>>>>> fda48a0... tcp: bind() fix when many ports are bound
>  63         }
>  64
>  65         return node != NULL;
> 
> 
> 
>  66 }
> 
> 'net/ipv6/inet6_connection_sock.c' after resolving conflict:
> 
>  41         sk_for_each_bound(sk2, node, &tb->owners) {
>  42                 if (sk != sk2 &&
>  43                     (!sk->sk_bound_dev_if ||
>  44                      !sk2->sk_bound_dev_if ||
>  45                      sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
>  46                     (!sk->sk_reuse || !sk2->sk_reuse ||
>  47                      sk2->sk_state == TCP_LISTEN) &&
>  48                      ipv6_rcv_saddr_equal(sk, sk2))
>  49                         break;
>  50         }
> 
> 
> 
>  51
>  52         return node != NULL;
>  53 }
> 
> -- 
> Greetings
> Grzegorz Chwesewicz
> mailto:grzegorz.chwesewicz@retis.net.pl
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
