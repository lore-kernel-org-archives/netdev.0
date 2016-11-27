From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6:ipv6_pinfo dereferenced after NULL check
Date: Sun, 27 Nov 2016 15:25:03 -0500 (EST)
Message-ID: <20161127.152503.1338198255637289162.davem@davemloft.net>
References: <1479984117-39005-1-git-send-email-manjeet.p@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pankaj.m@samsung.com,
        ajeet.y@samsung.com, r.thapliyal@samsung.com,
        hannes@stressinduktion.org
To: manjeet.p@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479984117-39005-1-git-send-email-manjeet.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Manjeet Pawar <manjeet.p@samsung.com>
Date: Thu, 24 Nov 2016 16:11:57 +0530

> From: Rohit Thapliyal <r.thapliyal@samsung.com>
> 
> np checked for NULL and then dereferenced. It should be modified
> for NULL case.
> 
> Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>

I do not think inet6_sk(sk) can ever be NULL in this function.

All callers fall into two categories:

1) Calls where arguments already dereference np in some way to
   pass arguments to ip6_xmit():

net/dccp/ipv6.c:		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
net/ipv6/inet6_connection_sock.c:	res = ip6_xmit(sk, skb, &fl6, rcu_dereference(np->opt),
net/ipv6/tcp_ipv6.c:		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
net/sctp/ipv6.c:	res = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt), np->tclass);

2) Calls where the socket is a "control" socket which is initialized
   at procotol registration time and therefore definitely has
   a proper inet6_sk() pointer set up.

net/dccp/ipv6.c:		ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
net/ipv6/tcp_ipv6.c:		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);

Therefore, I think we should simply remove the NULL test entirely.
