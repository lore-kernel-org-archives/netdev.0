From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [RFT] Re: Fw: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR
Date: Fri, 10 Oct 2003 12:40:52 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010154052.GA11366@conectiva.com.br>
References: <20031008133345.49f71991.davem@redhat.com> <20031010023644.GA8365@conectiva.com.br> <20031010032244.GB8365@conectiva.com.br> <20031009211437.2cf87a4f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, dmerillat@sequiam.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031009211437.2cf87a4f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Thu, Oct 09, 2003 at 09:14:37PM -0700, David S. Miller escreveu:
> 
> Even if they make the OOPS go away, all of these patches are
> not correct.
> 
> You have to consider the timewait sockets just like established
> sockets in the bind conflict test.
> 
> Therefore in the most inner part of this chain of if's you need
> to have something like:
> 
> 	u32 rcv_saddr;
> 
> 	if (sk->sk_state == TCP_TIME_WAIT) {
> 		struct tcp_tw_bucket *tw = tcptw_sk(sk2);
> 		rcv_saddr = tw->tw_rcv_saddr;
> 	} else {
> 		struct inet_sock *inet = inet_sk(sk2);
> 		rcv_saddr = inet->rcv_saddr;
> 	}
> 	if (!rcv_saddr || !sk->rcv_saddr ||
> 	    sk->rcv_saddr == rcv_saddr)
> 		... blah blah blah ...

Gotcha, I'm working on this now, creating inet_rcv_saddr and inet6_rcv_saddr
inline functions, and in the process I'm finding what seems like a bug in
ipv6_rcv_saddr_equal, look at this:

        if (sk2->sk_family == AF_INET6 &&
            !ipv6_addr_cmp(&np->rcv_saddr,
                           (sk2->sk_state != TCP_TIME_WAIT ?
                            &inet6_sk(sk2)->rcv_saddr :
                            &tcptw_sk(sk)->tw_v6_rcv_saddr)))
                                      ^^
                                      ^^
shouldn't the tcp_tw_sk(sk) be tcp_tw_sk(sk2)?

And in this function we have the guard against it being a tcp_tw_bucket, but
not in all places...

Anyway, I'll be posting patches today.

- Arnaldo
