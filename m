From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] tcp: introduce TCP experimental option for
 SMC
Date: Mon, 06 Jul 2015 18:08:17 +0200
Message-ID: <1436198897.4571.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436195511-32314-1-git-send-email-ubraun@linux.vnet.ibm.com>
	 <1436195511-32314-2-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:34388 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618AbbGFQIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 12:08:22 -0400
In-Reply-To: <1436195511-32314-2-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-06 at 17:11 +0200, Ursula Braun wrote:
> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> The SMC-R protocol defines dynamic discovery of peers. This is done by
> implementing experimental TCP options as defined in RFC6994. The TCP code
> needs to be extended to support RFC6994.
> 
> Setting the TCP experimental option for SMC-R [2] will be triggered from
> kernel exploiters like the new SMC-R socket family by setting a new
> flag "syn_smc" on struct tcp_sock of the connecting and the listening
> socket. If the client peer is SMC-R capable, flag syn_smc is kept on the
> connecting socket after the 3-way TCP handshake, otherwise it is reset.
> If the server peer is SMC-R capable, the new connected TCP socket has
> the new flag set, otherwise not.
> 
> Code snippet client:
>   tcp_sk(sock->sk)->syn_smc = 1;
>   rc = kernel_connect(sock, addr, alen, flags);
>   if (tcp_sk(sock->sk)->syn_smc) {
>           /* switch to smc for this connection */
> 
> Code snippet server:
>   tcp_sk(sock->sk)->syn_smc = 1;
>   rc = kernel_listen(sock, backlog);
>   rc = kernel_accept(sock, &newsock, 0);
>   if (tcp_sk(newsock->sk)->syn_smc) {
>           /* switch to smc for this connection */
> 
> References:
> [1] Shared Use of TCP Experimental Options RFC 6994:
>     https://tools.ietf.org/rfc/rfc6994.txt
> [2] IANA ExID SMCR:
>     http://www.iana.org/assignments/tcp-parameters/tcp-parameters.xhtml#tcp-exids
> 
> This patch has already been posted in June 2013, but Dave Miller has
> postponed applying till the user of the new flags, ie. the entire SMC-R
> protocol stack is implemented.
> 
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>


>  struct tcp_out_options {
>  	u16 options;		/* bit field of OPTION_* */
> @@ -544,6 +545,14 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
>  		}
>  		ptr += (len + 3) >> 2;
>  	}
> +
> +	if (unlikely(OPTION_SMC & options)) {
> +		*ptr++ = htonl((TCPOPT_NOP  << 24) |
> +			       (TCPOPT_NOP  << 16) |
> +			       (TCPOPT_EXP <<  8) |
> +			       (TCPOLEN_EXP_SMC_BASE));
> +		*ptr++ = htonl(TCPOPT_SMC_MAGIC);
> +	}
>  }


I am concerned about adding an additional conditional branch in TCP
write fast path, on all hosts, while SMC seems to be available only for
some hardware class.
