From: dormando <dormando@rydia.net>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Thu, 7 Mar 2013 23:09:26 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1303072307580.11964@dflat>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>    <51356AC1.4090302@gmail.com>  <1362460046.15793.111.camel@edumazet-glaptop>   <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>  <1362494795.15793.113.camel@edumazet-glaptop>
  <alpine.DEB.2.02.1303061631290.6723@dflat> <1362663990.15793.208.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362663990.15793.208.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 2013-03-06 at 16:41 -0800, dormando wrote:
>
> > Ok... bridge module is loaded but nothing seems to be using it. No
> > bond/tunnels/anything enabled. I couldn't quickly figure out what was
> > causing it to load.
> >
> > We removed the need for macvlan, started machines with a fresh boot, and
> > they still crashed without it, after a few hours.
> >
> > Unfortunately I just saw a machine crash in the same way on 3.6.6 and
> > 3.6.9. I'm working on getting a completely pristine 3.6.6 and 3.6.9
> > tested. Our patches are minor but there were a few, so I'm backing it all
> > out just to be sure.
> >
> > Is there anything in particular which is most interesting? I can post lots
> > and lots and lots of information. Sadly bridge/macvlan weren't part of the
> > problem. .config, sysctls are easiest I guess? When this "hang" happens
> > the machine is still up somewhat, but we lose access to it. Syslog is
> > still writing entries to disk occasionally, so it's possible we could set
> > something up to dump more information.
> >
> > It takes a day or two to cycle this, so it might take a while to get
> > information and test crashes.
>
> Thanks !
>
> Please add a stack trace, it might help :
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 68f6a94..1d4d97e 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -141,8 +141,9 @@ void inet_sock_destruct(struct sock *sk)
>  	sk_mem_reclaim(sk);
>
>  	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
> -		pr_err("Attempt to release TCP socket in state %d %p\n",
> -		       sk->sk_state, sk);
> +		pr_err("Attempt to release TCP socket family %d in state %d %p\n",
> +		       sk->sk_family, sk->sk_state, sk);
> +		WARN_ON_ONCE(1);
>  		return;
>  	}
>  	if (!sock_flag(sk, SOCK_DEAD)) {

Ok. I have a pristine 3.6.6 up and testing now... It definitely looks like
we've been having this crash for quite a while, but much more rarely.
Recent changes in traffic have made it worse. I'll try your patch soon.

It'll take a few days to reproduce. I'll be back (ho ho ho). Please ping
with any ideas you folks might have in the meantime :(
