From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Tue, 22 Jan 2013 08:45:42 -0800
Message-ID: <1358873142.3464.3964.camel@edumazet-glaptop>
References: <20130122161038.GG4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122161038.GG4608@sociomantic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-22 at 17:10 +0100, Leandro Lucarella wrote:
> Hi, I'm having some problems with missing SYNs in a server with a high
> rate of incoming connections and, even when far from understanding the
> kernel,  I ended up looking at the kernel's source to try to understand
> better what's going on, because some stuff doesn't make a lot of sense
> to me.
> 
> The path I followed is this (line numbers for Linux 3.7):
> net/socket.c[3]
>     SYSCALL_DEFINE2(listen, int, fd, int, backlog)
>         backlog is truncated to sysctl_somaxconn and
>         sock->ops->listen(sock, backlog) is called, which I guess it
>         calls to inet_listen().
> 
> net/ipv4/af_inet.c[4]
>     int inet_listen(struct socket *sock, int backlog)
>         the backlog is assigned to sk->sk_max_ack_backlog and
>         inet_csk_listen_start(sk, backlog) is called (if the socket
>         wans't already in TCP_LISTEN state)
> 
> net/ipv4/inet_connection_sock.c[5]
>     int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
>         reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries) is
>         called, which I guess it creates the actual queue
> 
> net/core/request_sock.c[6]
>     int reqsk_queue_alloc(struct request_sock_queue *queue,
>                           unsigned int nr_table_entries)
>         nr_table_entries is first adjusted to satisfy:
>         8 <= nr_table_entries <= sysctl_max_syn_backlog
>         and then incremented by one and rounded up to the next power of
>         2.
> 
> So here are a couple of questions:
> 
> 1. What's the relation between the socket backlog and the queue created
>    by reqsk_queue_alloc()? Because the backlog is only adjusted not to
>    be grater than sysctl_somaxconn, but the queue size can be quite
>    different.
> 2. The comment just above the definition of reqsk_queue_alloc() about
>    sysctl_max_syn_backlog says "Maximum number of SYN_RECV sockets in
>    queue per LISTEN socket.". But then nr_table_entries is not only
>    rounded up to the next power of 2, is incremented by one before that,
>    so a backlog of, for example, 128, would end up with 256 table
>    entries even if sysctl_max_syn_backlog is 128.
> 3. Why is there a nr_table_entries + 1 at all in there? Looking at the
>    commit that introduced this[1] I can't find any explanation and I've
>    read some big projects are using backlogs of 511 because of this[2].
>    (which BTW, ff the queue is really a hash table, looks like an awful
>    idea).
> 4. I found some places sk->sk_ack_backlog is checked against
>    sk->sk_max_ack_backlog to see if new requests should be dropped, but
>    I also saw checks like inet_csk_reqsk_queue_young(sk) > 1 or
>    inet_csk_reqsk_queue_is_full(sk), so I guess the queue is used too.
> 
> 
> Thanks a lot.
> 
> [1] http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=commitdiff;h=72a3effaf633bcae9034b7e176bdbd78d64a71db
> [2] http://blog.dubbelboer.com/2012/04/09/syn-cookies.html#a_reasonably_backlog_size
> [3] http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/socket.c;h=2ca51c719ef984cdadef749008456cf7bd5e1ae4;hb=HEAD#l1544
> [4] http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/ipv4/af_inet.c;h=24b384b7903ea7a59a11e7a4cbf06db996498924;hb=HEAD#l192
> [5] http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/ipv4/inet_connection_sock.c;h=d0670f00d5243f95bec4536f60edf32fa2ded850;hb=HEAD#l729
> [6] http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/core/request_sock.c;h=c31d9e8668c30346894adbf3be55eed4beeb1258;hb=HEAD#l23
> 


What particular problem do you have ?

A serious rewrite of LISTEN code is needed, because the current
implementation doesn't scale :

The SYNACK retransmits are done by a single timer wheel, holding the
socket lock for too long. So increasing the backlog to 2^16 or 2^17 is
not really an option.

Hash table are nice, but if we have to scan them, holding a single lock,
they are not so nice.
