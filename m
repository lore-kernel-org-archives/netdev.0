From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v1 net-next 3/6] net: add new control message for incoming
 HW-timestamped packets
Date: Thu, 27 Apr 2017 07:38:04 -0400
Message-ID: <CA+FuTScHMLmmM+=50C+yutXCk56YzXE=ymg_3whFqG6w90aU5A@mail.gmail.com>
References: <20170426145035.25846-1-mlichvar@redhat.com> <20170426145035.25846-4-mlichvar@redhat.com>
 <CAF=yD-+XKGnGASVN4+W2u2A7CBqS9CRN2Jkvx6UoPQQ6jLpMkQ@mail.gmail.com> <20170427101554.GF5654@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36844 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753956AbdD0Lii (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:38:38 -0400
Received: by mail-wm0-f66.google.com with SMTP id u65so3939170wmu.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:38:37 -0700 (PDT)
Received: from mail-wr0-f175.google.com (mail-wr0-f175.google.com. [209.85.128.175])
        by smtp.gmail.com with ESMTPSA id l133sm7348192wmf.17.2017.04.27.04.38.35
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 04:38:36 -0700 (PDT)
Received: by mail-wr0-f175.google.com with SMTP id w50so15573988wrc.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:38:35 -0700 (PDT)
In-Reply-To: <20170427101554.GF5654@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 6:15 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> Thanks for the comments.
>
> On Wed, Apr 26, 2017 at 07:34:49PM -0400, Willem de Bruijn wrote:
>> > +struct net_device *dev_get_by_napi_id(unsigned int napi_id)
>> > +{
>> > +       struct net_device *dev = NULL;
>> > +       struct napi_struct *napi;
>> > +
>> > +       rcu_read_lock();
>> > +
>> > +       napi = napi_by_id(napi_id);
>> > +       if (napi)
>> > +               dev = napi->dev;
>> > +
>> > +       rcu_read_unlock();
>> > +
>> > +       return dev;
>> > +}
>> > +EXPORT_SYMBOL(dev_get_by_napi_id);
>>
>> Returning dev without holding a reference is not safe. You'll probably
>> have to call this with rcu_read_lock held instead.
>
> How about changing the function to simply return the index instead of
> the device (e.g. dev_get_ifindex_by_napi_id())? Would that be too
> specific?

I suspect so. If you can achieve the same by calling this function
within an rcu read_side critical section, I would do that.

>> >  /*
>> >   * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
>> >   */
>> > @@ -699,8 +719,12 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>> >                 empty = 0;
>> >         if (shhwtstamps &&
>> >             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
>>
>> This information is also informative with software timestamps.
>
> But is it useful and worth the cost? If I have two interfaces and only
> one has HW timestamping, or just one interface which can timestamp
> incoming packets at a limited rate, I would prefer to not waste CPU
> cycles preparing and processing useless data.
>
>> And getting the real iif is definitely useful outside timestamps.
>
> Do you have an example? We have asked that in the original thread,
> but no one suggested anything. For AF_PACKET there is PACKET_ORIGDEV.
> When I was searching the Internet on how to get the index with INET
> sockets, it looked like I was the only one who had this problem :).

Okay. Maybe I'm mistaken. If no one else responds with a use case,
then I agree that we can ignore these cases.

>> An
>> alternative approach is to add versioning to IP_PKTINFO with a new
>> setsockopt IP_PKTINFO_VERSION plus a new struct in_pktinfo_v2
>> that extends in_pktinfo. Just a thought.
>
> The struct would contain both the original and last interface index,
> and the length as well? And similarly with in6_pktinfo?
>
> If there is an agreement that the information would useful also for
> other things than timestamping, I can try that. If not, I think it
> would be better to keep it tied to HW timestamping.

Ack.
