From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/udp: slab-out-of-bounds Read in udp_recvmsg
Date: Wed, 15 Mar 2017 15:45:55 -0700
Message-ID: <1489617955.28631.164.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+aKW-yNfdWBvAWck3xNFKKeKEf8BNOmtFg2EZZjN98BVg@mail.gmail.com>
         <1489593673.28631.150.camel@edumazet-glaptop3.roam.corp.google.com>
         <1489594233.28631.152.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170315.150829.1653001387394027005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, ycheng@google.com, soheil@google.com,
        ncardwell@google.com, zzoru007@gmail.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315.150829.1653001387394027005.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-03-15 at 15:08 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 15 Mar 2017 09:10:33 -0700
> 
> > @@ -692,12 +692,17 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
> >  	    ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2))
> >  		empty = 0;
> >  	if (!empty) {
> > +		unsigned int hlen = skb_headlen(skb);
> > +
> >  		put_cmsg(msg, SOL_SOCKET,
> >  			 SCM_TIMESTAMPING, sizeof(tss), &tss);
> >  
> > -		if (skb->len && (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS))
> > +		if (hlen &&
> > +		    (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS) &&
> > +		    sk->sk_protocol == IPPROTO_TCP &&
> > +		    sk->sk_type == SOCK_STREAM)
> >  			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_OPT_STATS,
> > -				 skb->len, skb->data);
> > +				 hlen, skb->data);
> 
> Hmmm, what is the true intention of SOF_TIMESTAMPING_OPT_STATS then?  The
> existing code seems to want to dump the entire SKB into the cmsg, and if
> that's the case then the fix is to linearlize the skb before the put_cmsg()
> or have a way to put a non-linear SKB into a cmsg.

I simply matched the conditions in __skb_tstamp_tx() which builds the
skb :

+       if (tsonly) {
+#ifdef CONFIG_INET
+               if ((sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS) &&
+                   sk->sk_protocol == IPPROTO_TCP &&
+                   sk->sk_type == SOCK_STREAM)
+                       skb = tcp_get_timestamping_opt_stats(sk);
+               else
+#endif
+                       skb = alloc_skb(0, GFP_ATOMIC);
+       } else {


And note that I should have also used the #ifdef


A proper fix would be to find a bit in skb->cb[] to avoid duplicating
the test...
