From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: FYI: struct sock class hierarchy
Date: Sun, 19 Dec 2004 02:40:19 -0200
Message-ID: <41C50633.1010102@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

	Further info on that struct sock hierarchy stuff I'm mentioned
that I planned doing while at the netsummit, with the changes I have
in one of my pending trees, things are now looking like this:

struct inet_sock {
         struct sock        sk;
         struct stream_sock *pssk;
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
         struct ipv6_pinfo  *pinet6;
#endif
         struct inet_opt    inet;
};

I.e. inet sock is an specialization of struct sock (the pointer to any
instance of both structs point to the same memory address).

Now tcp:

struct tcp_sock {
         struct inet_sock        inet;
         struct tcp_opt          tcp;
         struct stream_sock      ssk;
};

Now it is tcp_sock that is an specialization of struct inet_sock, that is,
in turn, as said above, an specialization of struct sock (the pointer
to any instance of the three structs points to the same memory address)

And finally struct tcp6_sock:

struct tcp6_sock {
         struct tcp_sock    tcp;
         struct ipv6_pinfo  inet6;
};

I guess you got the idea:

tcp6_sock <- tcp_sock <- inet_sock <- sock

This was done for struct udp_sock, raw6_sock, sctp_sock, etc

Using this approach we see clearly how the layouts are organized and
the relations among the, ho-hum, classes, i.e. the class hierarchy.

For further eye candy please take a look at:

http://master.kernel.org/~acme/sock_class_hierarchy.ps

That has the complete struct sock class hierarchy subtree for inet
protocols, including SCTP, DCCP, raw, raw6, tcp_tw_bucket, etc.

Apart from the introduction of struct stream_sock it is completely
equivalent to the current state of things in Linus tree, but much
clearer, IMHO, by not having all those cut'n'pasted layouts, complete
with the #ifdef IPV6 optimization for when IPv6 is not compiled.

BTW, this #ifdef IPV6 is wrong, as it leads to a kernel where IPV6
can't be later compiled and loaded, but this remains a futile exercise
while the other #ifdef IPV6 is scattered in the common IPV6/IPV4
code:

[acme@oldpandora stream_sock-2.6]$ grep -l IPV6 net/ipv4/*.c | wc -l
6

But this is something we'll possibly address in the future... :-)

- Arnaldo
