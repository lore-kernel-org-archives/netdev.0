From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 11:07:54 -0500
Message-ID: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello everybody,

While looking into Coverity ID 1357474 I ran into the following piece  
of code at net/ipv4/inet_diag.c:392:

struct sock *inet_diag_find_one_icsk(struct net *net,
                                      struct inet_hashinfo *hashinfo,
                                      const struct inet_diag_req_v2 *req)
{
         struct sock *sk;

         rcu_read_lock();
         if (req->sdiag_family == AF_INET)
                 sk = inet_lookup(net, hashinfo, NULL, 0, req->id.idiag_dst[0],
                                  req->id.idiag_dport, req->id.idiag_src[0],
                                  req->id.idiag_sport, req->id.idiag_if);
#if IS_ENABLED(CONFIG_IPV6)
         else if (req->sdiag_family == AF_INET6) {
                 if (ipv6_addr_v4mapped((struct in6_addr  
*)req->id.idiag_dst) &&
                     ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src))
                         sk = inet_lookup(net, hashinfo, NULL, 0,  
req->id.idiag_dst[3],
                                          req->id.idiag_dport,  
req->id.idiag_src[3],
                                          req->id.idiag_sport,  
req->id.idiag_if);
                 else
                         sk = inet6_lookup(net, hashinfo, NULL, 0,
                                           (struct in6_addr  
*)req->id.idiag_dst,
                                           req->id.idiag_dport,
                                           (struct in6_addr  
*)req->id.idiag_src,
                                           req->id.idiag_sport,
                                           req->id.idiag_if);
         }
#endif

The issue here is that the position of arguments in the call to  
inet_lookup() and inet6_lookup() functions do not match the order of  
the parameters:

req->id.idiag_dport is passed to sport
req->id.idiag_sport is passed to dport

These are the function prototypes:

static inline struct sock *inet_lookup(struct net *net,
				       struct inet_hashinfo *hashinfo,
				       struct sk_buff *skb, int doff,
				       const __be32 saddr, const __be16 sport,
				       const __be32 daddr, const __be16 dport,
				       const int dif)

struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
			  struct sk_buff *skb, int doff,
			  const struct in6_addr *saddr, const __be16 sport,
			  const struct in6_addr *daddr, const __be16 dport,
			  const int dif)

My question here is if this is intentional?

In case it is not, I will send a patch to fix it. But first it would  
be great to hear any comment about it.

Thank you!
--
Gustavo A. R. Silva
