From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 3/6] net: add new control message for
 incoming HW-timestamped packets
Date: Thu, 27 Apr 2017 12:15:54 +0200
Message-ID: <20170427101554.GF5654@localhost>
References: <20170426145035.25846-1-mlichvar@redhat.com>
 <20170426145035.25846-4-mlichvar@redhat.com>
 <CAF=yD-+XKGnGASVN4+W2u2A7CBqS9CRN2Jkvx6UoPQQ6jLpMkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755345AbdD0KP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 06:15:58 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+XKGnGASVN4+W2u2A7CBqS9CRN2Jkvx6UoPQQ6jLpMkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the comments.

On Wed, Apr 26, 2017 at 07:34:49PM -0400, Willem de Bruijn wrote:
> > +struct net_device *dev_get_by_napi_id(unsigned int napi_id)
> > +{
> > +       struct net_device *dev = NULL;
> > +       struct napi_struct *napi;
> > +
> > +       rcu_read_lock();
> > +
> > +       napi = napi_by_id(napi_id);
> > +       if (napi)
> > +               dev = napi->dev;
> > +
> > +       rcu_read_unlock();
> > +
> > +       return dev;
> > +}
> > +EXPORT_SYMBOL(dev_get_by_napi_id);
> 
> Returning dev without holding a reference is not safe. You'll probably
> have to call this with rcu_read_lock held instead.

How about changing the function to simply return the index instead of
the device (e.g. dev_get_ifindex_by_napi_id())? Would that be too
specific?

> >  /*
> >   * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
> >   */
> > @@ -699,8 +719,12 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
> >                 empty = 0;
> >         if (shhwtstamps &&
> >             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> 
> This information is also informative with software timestamps.

But is it useful and worth the cost? If I have two interfaces and only
one has HW timestamping, or just one interface which can timestamp
incoming packets at a limited rate, I would prefer to not waste CPU
cycles preparing and processing useless data.

> And getting the real iif is definitely useful outside timestamps.

Do you have an example? We have asked that in the original thread,
but no one suggested anything. For AF_PACKET there is PACKET_ORIGDEV.
When I was searching the Internet on how to get the index with INET
sockets, it looked like I was the only one who had this problem :).

> An
> alternative approach is to add versioning to IP_PKTINFO with a new
> setsockopt IP_PKTINFO_VERSION plus a new struct in_pktinfo_v2
> that extends in_pktinfo. Just a thought.

The struct would contain both the original and last interface index,
and the length as well? And similarly with in6_pktinfo?

If there is an agreement that the information would useful also for
other things than timestamping, I can try that. If not, I think it
would be better to keep it tied to HW timestamping.

-- 
Miroslav Lichvar
