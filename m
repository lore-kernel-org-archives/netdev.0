From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] Re: Fw: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR
Date: Thu, 9 Oct 2003 21:14:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031009211437.2cf87a4f.davem@redhat.com>
References: <20031008133345.49f71991.davem@redhat.com>
	<20031010023644.GA8365@conectiva.com.br>
	<20031010032244.GB8365@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dmerillat@sequiam.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031010032244.GB8365@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Even if they make the OOPS go away, all of these patches are
not correct.

You have to consider the timewait sockets just like established
sockets in the bind conflict test.

Therefore in the most inner part of this chain of if's you need
to have something like:

	u32 rcv_saddr;

	if (sk->sk_state == TCP_TIME_WAIT) {
		struct tcp_tw_bucket *tw = tcptw_sk(sk2);
		rcv_saddr = tw->tw_rcv_saddr;
	} else {
		struct inet_sock *inet = inet_sk(sk2);
		rcv_saddr = inet->rcv_saddr;
	}
	if (!rcv_saddr || !sk->rcv_saddr ||
	    sk->rcv_saddr == rcv_saddr)
		... blah blah blah ...
