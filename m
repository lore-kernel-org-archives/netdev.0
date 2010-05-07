From: Bhaskar Dutta <bhaskie@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 7 May 2010 14:29:48 +0530
Message-ID: <n2u571fb4001005070159y91d8b13crb20d2f14ea26dd1a@mail.gmail.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com>
	 <20100504091215.5a4a51f4@nehalam>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273210774.2222.45.camel@edumazet-laptop>
	 <1273219222.2261.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:49267 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab0EGI7t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 04:59:49 -0400
Received: by pxi5 with SMTP id 5so419474pxi.19
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 01:59:48 -0700 (PDT)
In-Reply-To: <1273219222.2261.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 7, 2010 at 1:30 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 07 mai 2010 =E0 07:39 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 06 mai 2010 =E0 17:25 +0530, Bhaskar Dutta a =E9crit :
>> > On Thu, May 6, 2010 at 12:23 AM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>>
>> > > I am not familiar with this code, but I suspect same per_cpu dat=
a can be
>> > > used at both time by a sender (process context) and by a receive=
r
>> > > (softirq context).
>> > >
>> > > To trigger this, you need at least two active md5 sockets.
>> > >
>> > > tcp_get_md5sig_pool() should probably disable bh to make sure cu=
rrent
>> > > cpu wont be preempted by softirq processing
>> > >
>> > >
>> > > Something like :
>> > >
>> > > diff --git a/include/net/tcp.h b/include/net/tcp.h
>> > > index fb5c66b..e232123 100644
>> > > --- a/include/net/tcp.h
>> > > +++ b/include/net/tcp.h
>> > > @@ -1221,12 +1221,15 @@ struct tcp_md5sig_pool =A0 =A0 =A0 =A0 =A0=
*tcp_get_md5sig_pool(void)
>> > > =A0 =A0 =A0 =A0struct tcp_md5sig_pool *ret =3D __tcp_get_md5sig_=
pool(cpu);
>> > > =A0 =A0 =A0 =A0if (!ret)
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_cpu();
>> > > + =A0 =A0 =A0 else
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_disable();
>> > > =A0 =A0 =A0 =A0return ret;
>> > > =A0}
>> > >
>> > > =A0static inline void =A0 =A0 =A0 =A0 =A0 =A0 tcp_put_md5sig_poo=
l(void)
>> > > =A0{
>> > > =A0 =A0 =A0 =A0__tcp_put_md5sig_pool();
>> > > + =A0 =A0 =A0 local_bh_enable();
>> > > =A0 =A0 =A0 =A0put_cpu();
>> > > =A0}
>> > >
>> > >
>> > >
>> >
>> > I put in the above change and ran some load tests with around 50
>> > active TCP connections doing MD5.
>> > I could see only 1 bad packet in 30 min (earlier the problem used =
to
>> > occur instantaneously and repeatedly).
>> >
>>
>>
>> > I think there is another possibility of being preempted when calli=
ng
>> > tcp_alloc_md5sig_pool()
>> > this function releases the spinlock when calling __tcp_alloc_md5si=
g_pool().
>> >
>> > I will run some more tests after changing the =A0tcp_alloc_md5sig_=
pool
>> > and see if the problem is completely resolved.
>
> Here is my official patch submission, could you please test it ?
>


Eric,

Thanks a lot! I will test it out and let you know.
BTW this patch seems to essentially do the same as the earlier fix you
had posted (where you just do bh disable/enable).
Am I missing something?

With the earlier fix, I ran load tests with 80 TCP connections for
over 6 hrs and found 5 bad checksum packets.
So there is still a problem. Without the fix I see a bad packet every
minute or so.

Bhaskar
