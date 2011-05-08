From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 11:09:35 +0100
Message-ID: <443ACEB21CD1E406E4AE377F@nimrod.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304785589.3207.5.camel@edumazet-laptop>	
 <178E8895FB84C07251538EF7@Ximines.local>	
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793553.3207.24.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:45040 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014Ab1EHKJm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 06:09:42 -0400
In-Reply-To: <1304793553.3207.24.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 7 May 2011 20:39:13 +0200 Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:

> Le samedi 07 mai 2011 =C3=A0 20:32 +0200, Eric Dumazet a =C3=A9crit :
>
> Also you could patch synchronize_sched() itself instead of
> synchronize_net()

OK, I did this, plus instrumented the call to rcu_barrier()
you mentioned:

Looking at the synchronize_net() and rcu_barrier() calls:
 Total 8.43935 Usage 399 Average 0.02115 elsewhere
 Total 10.65050 Usage 200 Average 0.05325 rcu_barrier
 Total 9.28948 Usage 200 Average 0.04645 synchronize_net

it's spending about 1/3 of its time in that rcu_barrier, 1/3
in synchronize_sched() and 1/3 elsewere.

Turning now to the synchronize_sched() (per your patch), I see

  Total 16.36852 Usage 400 Average 0.04092 synchronize_sched()

Note "Usage 400". That's because precisely half the calls to
synchronize_sched() occur outside of synchronize_net(), and
half occur within synchronize_net() (per logs)

A typical interface being removed looks like this:
May  8 09:47:31 nattytest kernel: [  177.030197] synchronize_sched() in=
=20
66921 us
May  8 09:47:31 nattytest kernel: [  177.030957] begin synchronize_net(=
)
May  8 09:47:31 nattytest kernel: [  177.120085] synchronize_sched() in=
=20
89080 us
May  8 09:47:31 nattytest kernel: [  177.120819] end synchronize_net()
May  8 09:47:31 nattytest kernel: [  177.121698] begin rcu_barrier()
May  8 09:47:31 nattytest kernel: [  177.190152] end rcu_barrier()


So for every interface being destroyed (I'm doing 200 as veths
are pairs), we do 2 synchronize_sched() calls and 1 rcu_barrier.
Each of these takes roughly 42ms with CONFIG_HZ set to 100,
leading to 125ms per interface destroy, and 250ms per veth
pair destroy.

It may be a naive question but why would we need to do
2 synchronize_sched() and 1 rcu_barrier() to remove an
interface?

--=20
Alex Bligh
