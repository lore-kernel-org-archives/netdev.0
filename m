From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: FYI: struct sock class hierarchy
Date: Mon, 20 Dec 2004 15:06:15 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0412201426310.28353@w-sridhar.beaverton.ibm.com>
References: <41C50633.1010102@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41C50633.1010102@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arnaldo,

The name struct stream_sock seems to indicate that this structure is needed
only for SOCK_STREAM sockets. But in reality this structure is required for
any connected sockets(ex: SOCK_SEQPACKET).
I cannot think of good name for this structure, but struct conn_sock
to indicate any connected socket seems to be the best i can come up with.

Also If i understand the hierarchy correctly, stream_sock is a specialization
of struct inet_sock.  So can we include stream_sock also in the hierarchy
as follows although i would prefer renaming stream_sock to conn_sock.

> tcp6_sock <- tcp_sock <- stream_sock <- inet_sock <- sock

struct stream_sock {
	struct inet_sock	inet;
	struct stream_opt	sopt;
}

struct tcp_sock {
	struct stream_sock ssk;
	struct tcp_opt	 tcp;
}

Thanks
Sridhar

On Sun, 19 Dec 2004, Arnaldo Carvalho de Melo wrote:

> Dave,
>
> 	Further info on that struct sock hierarchy stuff I'm mentioned
> that I planned doing while at the netsummit, with the changes I have
> in one of my pending trees, things are now looking like this:
>
> struct inet_sock {
>          struct sock        sk;
>          struct stream_sock *pssk;
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>          struct ipv6_pinfo  *pinet6;
> #endif
>          struct inet_opt    inet;
> };
>
> I.e. inet sock is an specialization of struct sock (the pointer to any
> instance of both structs point to the same memory address).
>
> Now tcp:
>
> struct tcp_sock {
>          struct inet_sock        inet;
>          struct tcp_opt          tcp;
>          struct stream_sock      ssk;
> };
>
> Now it is tcp_sock that is an specialization of struct inet_sock, that is,
> in turn, as said above, an specialization of struct sock (the pointer
> to any instance of the three structs points to the same memory address)
>
> And finally struct tcp6_sock:
>
> struct tcp6_sock {
>          struct tcp_sock    tcp;
>          struct ipv6_pinfo  inet6;
> };
>
> I guess you got the idea:
>
> tcp6_sock <- tcp_sock <- inet_sock <- sock
>
> This was done for struct udp_sock, raw6_sock, sctp_sock, etc
>
> Using this approach we see clearly how the layouts are organized and
> the relations among the, ho-hum, classes, i.e. the class hierarchy.
>
> For further eye candy please take a look at:
>
> http://master.kernel.org/~acme/sock_class_hierarchy.ps
>
> That has the complete struct sock class hierarchy subtree for inet
> protocols, including SCTP, DCCP, raw, raw6, tcp_tw_bucket, etc.
>
> Apart from the introduction of struct stream_sock it is completely
> equivalent to the current state of things in Linus tree, but much
> clearer, IMHO, by not having all those cut'n'pasted layouts, complete
> with the #ifdef IPV6 optimization for when IPv6 is not compiled.
>
> BTW, this #ifdef IPV6 is wrong, as it leads to a kernel where IPV6
> can't be later compiled and loaded, but this remains a futile exercise
> while the other #ifdef IPV6 is scattered in the common IPV6/IPV4
> code:
>
> [acme@oldpandora stream_sock-2.6]$ grep -l IPV6 net/ipv4/*.c | wc -l
> 6
>
> But this is something we'll possibly address in the future... :-)
>
> - Arnaldo
>
>
>
