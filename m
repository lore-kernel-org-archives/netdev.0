From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net/arp: ARP cache aging failed.
Date: Wed, 14 Dec 2016 22:15:06 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1612142151340.1681@ja.home.ssi.bg>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com> <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg> <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com> <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
 <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg> <c82b7b44-c0ad-9ee7-1114-3eae3b5cf75a@huawei.com> <1fdf938e-600c-ce58-ece1-06b816ddba1c@stressinduktion.org> <alpine.LFD.2.11.1611250957100.1966@ja.home.ssi.bg>
 <40b84d35-4185-bfbc-7f85-9d6abf984d31@stressinduktion.org> <alpine.LFD.2.11.1611252140120.1888@ja.home.ssi.bg> <74d41c47-7091-3c52-096d-5b9af2e0e9cf@huawei.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: YueHaibing <yuehaibing@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56830 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751845AbcLNUPb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 15:15:31 -0500
In-Reply-To: <74d41c47-7091-3c52-096d-5b9af2e0e9cf@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 14 Dec 2016, YueHaibing wrote:

> On 2016/11/26 4:40, Julian Anastasov wrote:
> > 
> > 	So, the idea is to move TCP and other similar
> > users to the new dst_confirm_sk() method. If other
> > dst_confirm() users are left, they should be checked
> > if dsts with rt_gateway = 0 can be wrongly used.
> 
> Sorry for so late.

	In fact, I'm late too because I almost finished
my changes, the only remaining part is the cxgb files...

> Based on your ideas, I make a patch and test it for a while.

	The problem is that it is valid only for TCP.
Also, this flag should be reset sometimes, eg. when sk dst
changes...

> It works for me.
> 
> @@ -847,7 +847,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  	return err;
> 
>  do_confirm:
> -	dst_confirm(&rt->dst);
> +	dst_confirm_sk(sk);

	MSG_CONFIRM from sendmsg needs special treatment. The
problem is that UDP sending does not lock the socket, so I also
added a skb flag to handle this situation in ip*_append_data.
We do not want threaded application firing at different
destinations to confirm the wrong neighbour. MSG_PROBE is
another issue, the XFRM dst chaining, etc...

	I hope, I'll be ready this weekend with few patches
that change all dst_confirm users... There I'll explain
everything in detail.

Regards
