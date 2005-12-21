From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC][PATCH 4/5] I/OAT DMA support and TCP acceleration
Date: Wed, 21 Dec 2005 07:20:43 +0100
Message-ID: <43A8F43B.6020307@cosmosbay.com>
References: <1135142263.13781.21.camel@cleech-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Grover, Andrew" <andrew.grover@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932288AbVLUGU4@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <1135142263.13781.21.camel@cleech-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech a =E9crit :
> Structure changes for TCP recv offload to I/OAT
>=20
> Adds an async_wait_queue and some additional fields to tcp_sock, a
> copied_early flag to sb_buff and a dma_cookie_t to tcp_skb_cb
>=20
> Renames cleanup_rbuf to tcp_cleanup_rbuf and makes it non-static so w=
e
> can call it from tcp_input.c=20
>=20
> ---=20
>  include/linux/skbuff.h   |    5 +++--
>  include/linux/tcp.h      |    9 +++++++++
>  include/net/tcp.h        |   10 ++++++++++
>  net/core/skbuff.c        |    1 +
>  net/ipv4/tcp.c           |   11 ++++++-----
>  net/ipv4/tcp_ipv4.c      |    4 ++++
>  net/ipv4/tcp_minisocks.c |    1 +
>  net/ipv6/tcp_ipv6.c      |    1 +
>  8 files changed, 35 insertions(+), 7 deletions(-)
> diff -urp a/include/linux/skbuff.h b/include/linux/skbuff.h
> --- a/include/linux/skbuff.h	2005-12-21 12:05:09.000000000 -0800
> +++ b/include/linux/skbuff.h	2005-12-21 12:10:14.000000000 -0800
> @@ -248,7 +248,7 @@ struct sk_buff {
>  	 * want to keep them across layers you have to do a skb_clone()
>  	 * first. This is owned by whoever has the skb queued ATM.
>  	 */
> -	char			cb[40];
> +	char			cb[44];

Hi Chris

Please consider not enlarging cb[] if not CONFIG_NET_DMA ?

I mean, most machines wont have a compatable NIC, so why should they pa=
y the=20
price (memory, cpu) in a critical structure named sk_buff ?

#ifdef CONFIG_NET_DMA
typedef dma_cookie_t net_dma_cookie_t;
#else
typedef struct {} net_dma_cookie_t;
#endif

=2E..

	char   cb[40+sizeof(net_dma_cookie_t)];


Same remark apply for the rest of your patch : Please consider to make =
added=20
fields and code conditional to CONFIG_NET_DMA

Eric
