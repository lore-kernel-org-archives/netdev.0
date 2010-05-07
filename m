From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 07:39:34 +0200
Message-ID: <1273210774.2222.45.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com>
	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:60852 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab0EGFjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:39:39 -0400
Received: by bwz19 with SMTP id 19so371604bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 22:39:38 -0700 (PDT)
In-Reply-To: <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 17:25 +0530, Bhaskar Dutta a =C3=A9crit :
> On Thu, May 6, 2010 at 12:23 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> > I am not familiar with this code, but I suspect same per_cpu data c=
an be
> > used at both time by a sender (process context) and by a receiver
> > (softirq context).
> >
> > To trigger this, you need at least two active md5 sockets.
> >
> > tcp_get_md5sig_pool() should probably disable bh to make sure curre=
nt
> > cpu wont be preempted by softirq processing
> >
> >
> > Something like :
> >
> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > index fb5c66b..e232123 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -1221,12 +1221,15 @@ struct tcp_md5sig_pool          *tcp_get_md=
5sig_pool(void)
> >        struct tcp_md5sig_pool *ret =3D __tcp_get_md5sig_pool(cpu);
> >        if (!ret)
> >                put_cpu();
> > +       else
> > +               local_bh_disable();
> >        return ret;
> >  }
> >
> >  static inline void             tcp_put_md5sig_pool(void)
> >  {
> >        __tcp_put_md5sig_pool();
> > +       local_bh_enable();
> >        put_cpu();
> >  }
> >
> >
> >
>=20
> I put in the above change and ran some load tests with around 50
> active TCP connections doing MD5.
> I could see only 1 bad packet in 30 min (earlier the problem used to
> occur instantaneously and repeatedly).
>=20


> I think there is another possibility of being preempted when calling
> tcp_alloc_md5sig_pool()
> this function releases the spinlock when calling __tcp_alloc_md5sig_p=
ool().
>=20
> I will run some more tests after changing the  tcp_alloc_md5sig_pool
> and see if the problem is completely resolved.

I cant see a race with spinlock in
tcp_alloc_md5sig_pool/__tcp_alloc_md5sig_pool().

We allocate structures for all cpus, so preemption.migration should be
OK

Could you elaborate please ?


