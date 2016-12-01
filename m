From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: [PATCH] ipv6:ip6_xmit remove unnecessary np NULL check
Date: Wed, 30 Nov 2016 22:29:29 -0800
Message-ID: <1480573769.18162.265.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480401179-9220-1-git-send-email-manjeet.p@samsung.com>
         <CGME20161129152615epcas3p4929492c0e63d8e859bbff6264a13c56d@epcas3p4.samsung.com>
         <20161201061422epcms5p83ef5b41a335c4556dd2bc725eed38d8d@epcms5p8>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Manjeet Pawar <manjeet.p@samsung.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        PANKAJ MISHRA <pankaj.m@samsung.com>,
        Ajeet Kumar Yadav <ajeet.y@samsung.com>
To: r.thapliyal@samsung.com, Lorenzo Colitti <lorenzo@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201061422epcms5p83ef5b41a335c4556dd2bc725eed38d8d@epcms5p8>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-01 at 06:14 +0000, Rohit Thapliyal wrote:
> Hi,
> 
Hi,

Do not top post on netdev, and do not use HTML format : it wont reach
netdev.

 
> 
> Found at just one place in ping_v6_sendmsg, where np is checked for
> NULL.
> 
> And I am not sure, if it is really required there also. 
> 
> So, I am not sure if sk_fullsock will ever return NULL in inet6_sk.
> 
Well I am sure. You can trust me. You can read git history for the
details.
> 
> sk_fullsock(__sk) ? inet_sk(__sk)->pinet6 : NULL;
> 


Yes, Lorenzo mentioned this ping_v6_sendmsg() useless code, but
apparently never sent the cleanup. This is really minor you know...

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 66e2d9dfc43a87ebed092d024e5bf2752b755d0e..775a9365725dd400c36e2510c685d08bf4a7d4b0 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -125,12 +125,6 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		return PTR_ERR(dst);
 	rt = (struct rt6_info *) dst;
 
-	np = inet6_sk(sk);
-	if (!np) {
-		err = -EBADF;
-		goto dst_err_out;
-	}
-
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
 	else if (!fl6.flowi6_oif)
@@ -165,7 +159,6 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	}
 	release_sock(sk);
 
-dst_err_out:
 	dst_release(dst);
 
 	if (err)




> 
> Thanks, 
> 
> Rohit Thapliyal
> 
>  
> 
> --------- Original Message ---------
> 
> Sender : Eric Dumazet <eric.dumazet@gmail.com>
> 
> Date : 2016-11-30 00:26 (GMT+9)
> 
> Title : Re: [PATCH] ipv6:ip6_xmit remove unnecessary np NULL check
> 
>  
> 
> On Tue, 2016-11-29 at 12:02 +0530, Manjeet Pawar wrote:
> > From: Rohit Thapliyal <r.thapliyal@samsung.com>
> > 
> > np NULL check doesn't seem required here as it shall never
> > be NULL anyways in inet6_sk(sk).
> > 
> > Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
> > Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
> > Signed-off-by: David Miller <davem@davemloft.net>
> > Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>
> > 
> > ---
> > v2->v3: Modified as per the suggestion from David Miller
> >         ip6_xmit calls are made without checking NULL np
> >         pointer, so no need to explicitly check NULL np in
> >         ip6_xmit.
> > 
> >  include/linux/ipv6.h  | 2 +-
> >  net/ipv6/ip6_output.c | 3 +--
> >  2 files changed, 2 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> > index a064997..6c9c604 100644
> > --- a/include/linux/ipv6.h
> > +++ b/include/linux/ipv6.h
> > @@ -299,7 +299,7 @@ struct tcp6_timewait_sock {
> >  
> >  static inline struct ipv6_pinfo *inet6_sk(const struct sock *__sk)
> >  {
> > -	return sk_fullsock(__sk) ? inet_sk(__sk)->pinet6 : NULL;
> > +	return inet_sk(__sk)->pinet6;
> 
> 
> David suggestion was about np being NULL or not in ip6_xmit()
> 
> But have you checked inet6_sk() was never called for a TCPv6 TIMEWAIT or
> SYN_RECV request ?
> 
> >  }
> >  
> >  static inline struct raw6_sock *raw6_sk(const struct sock *sk)
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 59eb4ed..f8c63ec 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -213,8 +213,7 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
> >  	/*
> >  	 *	Fill in the IPv6 header
> >  	 */
> > -	if (np)
> > -		hlimit = np->hop_limit;
> > +	hlimit = np->hop_limit;
> >  	if (hlimit < 0)
> >  		hlimit = ip6_dst_hoplimit(dst);
> >  
> 
> This part is fine.
> 
> 
> 
> 
> --
> 
> Thanks and Regards,
> 
> Rohit Thapliyal
> 
> Lead Engineer
> 
> Samsung SRI-D
> Phone: +91-9717627969
> 
> 
> 
> 
> 
> 
