From: Andrew Morton <akpm@osdl.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 13:20:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512132050.6eae6905.akpm@osdl.org>
References: <20040512020700.6f6aa61f.akpm@osdl.org>
	<20040512181903.GG13421@kroah.com>
	<40A26FFA.4030701@pobox.com>
	<20040512193349.GA14936@elte.hu>
	<Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
	<20040512200305.GA16078@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidel@xmailserver.org, jgarzik@pobox.com, greg@kroah.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20040512200305.GA16078@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ingo Molnar <mingo@elte.hu> wrote:
>
> 
> * Davide Libenzi <davidel@xmailserver.org> wrote:
> 
> > > why is it wrong?
> > 
> > For HZ == 1000 it's fine, even if it'd better to explicitly make it HZ
> > dependent and let the compiler to discard them.
> 
> the compiler cannot discard the multiplication and the division from the
> following:
> 
> 	x * 1000 / 1000
> 
> due to overflows. But we know that HZ is 1000 in the arch-dependent
> param.h, and in sched.c we use the HZ dependent variant:
> 
>  #ifndef JIFFIES_TO_MSEC
>  # define JIFFIES_TO_MSEC(x) ((x) * 1000 / HZ)
>  #endif
>  #ifndef MSEC_TO_JIFFIES
>  # define MSEC_TO_JIFFIES(x) ((x) * HZ / 1000)
>  #endif
> 

Yes, that's a correct optimisation.  This is simply a namespace clash.

How about we do:

#if HZ=1000
#define	MSEC_TO_JIFFIES(msec) (msec)
#define JIFFIES_TO_MESC(jiffies) (jiffies)
#elif HZ=100
#define	MSEC_TO_JIFFIES(msec) (msec * 10)
#define JIFFIES_TO_MESC(jiffies) (jiffies / 10)
#else
#define	MSEC_TO_JIFFIES(msec) ((HZ * (msec) + 999) / 1000)
#define	JIFFIES_TO_MSEC(jiffies) ...
#endif

in some kernel-wide header then kill off all the private implementations?
