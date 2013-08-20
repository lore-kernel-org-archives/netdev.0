From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 21:18:15 -0700
Message-ID: <5212EE07.2090803@fatooh.org>
References: <521061B4.1030508@fatooh.org>   <1376839467.21329.36.camel@edumazet-glaptop>   <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>   <1376870425.4226.25.camel@edumazet-glaptop>   <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>  <20130819123314.GC3583@cpaasch-mac>   <1376918657.4226.59.camel@edumazet-glaptop>   <20130819134919.GF3583@cpaasch-mac>  <1376920685.4226.61.camel@edumazet-glaptop>  <alpine.DEB.2.00.1308192207130.27869@blackhole.kfki.hu> <1376946527.4226.80.camel@edumazet-glaptop> <alpine.DEB.2.00.1308192330200.28532@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1308192330200.28532@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-08-19 15:07, Jozsef Kadlecsik wrote:
> It can be fixed by fixing the middlebox, or disabling SACK by the 
> TCPOPTSTRIP target, or by relaxing conntrack. For the latter, the next 
> untested patch may be sufficient:
> 
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 7dcc376..8b5d783 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> @@ -649,6 +649,11 @@ static bool tcp_in_window(const struct nf_conn *ct,
>  		 receiver->td_end, receiver->td_maxend, receiver->td_maxwin,
>  		 receiver->td_scale);
>  
> +	/* Fall back to ACK when SACK is bogus */
> +	if (!(before(sack, receiver->td_end + 1) &&
> +	      after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1)))
> +		sack = ack;
> +	      
>  	pr_debug("tcp_in_window: I=%i II=%i III=%i IV=%i\n",
>  		 before(seq, sender->td_maxend + 1),
>  		 after(end, sender->td_end - receiver->td_maxwin - 1),
> 
> However it is good to cover the issue thus?

This didn't quite apply to my kernel tree, but I let patch apply it with
fuzz=2 and got:

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 2f80107..94b326b 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -653,6 +653,11 @@ static bool tcp_in_window(const struct nf_conn *ct,
        in_recv_win = !receiver->td_maxwin ||
                      after(end, sender->td_end - receiver->td_maxwin - 1);
 
+       /* Fall back to ACK when SACK is bogus */
+       if (!(before(sack, receiver->td_end + 1) &&
+             after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1)))
+               sack = ack;
+
        pr_debug("tcp_in_window: I=%i II=%i III=%i IV=%i\n",
                 before(seq, sender->td_maxend + 1),
                 (in_recv_win ? 1 : 0),



I can confirm, that does indeed work! Thank you. I will continue watching
this thread for other things to test, if need be.

-Corey
