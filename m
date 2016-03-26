From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Fri, 25 Mar 2016 17:16:08 -0700
Message-ID: <20160326001600.GA29626@kafai-mba.local>
References: <CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
 <CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
 <20160322060220.GA50824@kafai-mba.local>
 <CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
 <20160322173939.GA53936@kafai-mba.local>
 <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
 <CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
 <1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAC15z3g-LDOdpcsZEs6XFFOOb92bXAbdOORdnd+MTvF62TgSiA@mail.gmail.com>
 <20160325235527.GA29327@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57029 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751872AbcCZAQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 20:16:16 -0400
Content-Disposition: inline
In-Reply-To: <20160325235527.GA29327@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 04:55:27PM -0700, Martin KaFai Lau wrote:
>  void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
>  {
> +	struct dst_entry *odst;
> +
> +	odst = sk_dst_get(sk);
> +
>  	ip6_update_pmtu(skb, sock_net(sk), mtu,
>  			sk->sk_bound_dev_if, sk->sk_mark);
> +
> +	if (odst && !odst->error &&
> +	    !ip6_dst_check(odst, inet6_sk(sk)->dst_cookie)) {
> +		struct dst_entry *ndst;
> +		struct flowi6 fl6;
> +
> +		build_skb_flow_key(&fl6, skb, sock_net(sk),
> +				   sk->sk_bound_dev_if, sk->sk_mark);
> +		ndst = ip6_route_output(sock_net(sk), NULL, &fl6);
> +		if (!ndst->error)
> +			ip6_dst_store(sk, ndst, NULL, NULL);
oops...missed:
		else
			dst_release(ndst);
> +	}
> +
> +	dst_release(odst);
>  }
>  EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
>
> --
> 2.5.1
