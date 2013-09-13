From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Fri, 13 Sep 2013 10:46:42 +0800
Message-ID: <52327C92.5010009@windriver.com>
References: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de>	<20130912134409.GB21212@gondor.apana.org.au>	<alpine.DEB.2.02.1309121636010.4089@ionos.tec.linutronix.de> <20130912.133252.425268707009916773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <herbert@gondor.hengli.com.au>, <steffen.klassert@secunet.com>,
	<dborkman@redhat.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, John Stultz <john.stultz@linaro.org>
To: David Miller <davem@davemloft.net>, <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130912.133252.425268707009916773.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave/Thomas

On 2013=E5=B9=B409=E6=9C=8813=E6=97=A5 01:32, David Miller wrote:
> From: Thomas Gleixner<tglx@linutronix.de>
> Date: Thu, 12 Sep 2013 16:43:37 +0200 (CEST)
>
>> So what about going back to timer_list timers and simply utilize
>> register_pm_notifier(), which will tell you that the system resumed?
>
> The thing to understand is that there are two timeouts for an IPSEC
> rule, a soft and a hard timeout.
>
> There is a gap between these two exactly so that we can negotiate a
> new encapsulation with the IPSEC gateway before communication ceases
> to be possible over the IPSEC protected path.
>
> So the idea is that the soft timeout triggers the re-negotiation,
> and after a hard timeout the IPSEC path is no longer usable and
> all communication will fail.
>
> Simply triggering a re-negoation after every suspend/resume makes
> no sense at all.  Spurious re-negotiations are undesirable.
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (*a*)

What's the differences between this with re-negotiation after every
system wall clock changing by using clock_was_set notifier?


 > On 2013=E5=B9=B408=E6=9C=8802=E6=97=A5 06:35, David Miller wrote:
 >
 > I suspect the thing to do is to have system time changes generate a
 > notifier when clock_was_set() is called.
 >
 > The XFRM code would walk the rules and pretend that we hit the soft
 > timeout for every rule that we haven't hit the soft timeout yet
 > already.
 >
 > If a rule hit the soft timeout, force a hard timeout.
 >
 > When forcing a soft timeout, adjust the hard timeout to be
 > (hard_timeout - soft_timeout) into the future.



> What we want are real timers.  We want that rather than a "we
> suspended so just assume all timers expired" event which is not very
> useful for this kind of application.
>

Here we are facing two problems:)

(1) what kind timer should xfrm_state should employ, Two requirements h=
ere:
     First one, KEY lifetime should include suspend/resume time. Second=
 one,
     system wall clock time changing(backward/forward) should *not* imp=
act
     *timer* timeout event(not the soft/hard IPsec events fired to user=
 space!)

     net-next commit 99565a6c471cbb66caa68347c195133017559943 ("xfrm: M=
ake
     xfrm_state timer monotonic") by utilizing *CLOCK_BOOTTIME* has sol=
ved this problem.

(2) What I have been bugging you around here for this long time is real=
ly the second
     problem, I'm sorry I didn't make it clearly to you and others, whi=
ch is below:

     Why using wall clock time to calculate soft/hard IPsec events when=
 xfrm_state timer
     out happens in its timeout handler? Because even if xfrm_state usi=
ng CLOCK_BOOTTIME,
     system wall clock time changing will surely disturb soft/hard IPse=
c events, which
     you raised your concern about in (*a*).

     The initial approach( http://marc.info/?l=3Dlinux-netdev&m=3D13753=
4280429187&w=3D2) has
     tried to solve this second problem by eliminating depending system=
 wall clock in
     xfrm_state timer timeout handler.

I think this time, I have made this situation crystal clear.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
