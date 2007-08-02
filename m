From: Satyam Sharma <satyam@infradead.org>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Thu, 2 Aug 2007 17:10:27 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708021641510.8258@enigma.security.iitk.ac.in>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com>
 <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com>
 <20070801095920.GA1941@ff.dom.local> <20070802020219.GM11166@waste.org>
 <20070802093659.GB27748@uranus.ravnborg.org>
 <alpine.LFD.0.999.0708021547420.8258@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, Jarek Poplawski <jarkao2@o2.pl>,
	Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, jason.wessel@windriver.com,
	amitkale@linsyssoft.com, zippel@linux-m68k.org, jengelh@gmx.de
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756930AbXHBL2b@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0708021547420.8258@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Read through the thread, looked at Kconfig files,
  did some tests. Adding Kconfig experts to Cc: list. ]


> On Thu, 2 Aug 2007, Sam Ravnborg wrote:
> 
> > > > 
> > > > ...
> > > > endif # NETDEVICES
> > > > 
> > > > config NETPOLL
> > > >         depends on NETDEVICES
> > > >         def_bool NETCONSOLE
> > > > 
> > > > config NETPOLL_TRAP
> > > >         bool "Netpoll traffic trapping"
> > > >         default n
> > > >         depends on NETPOLL
> > > > 
> > > > config NET_POLL_CONTROLLER
> > > >         def_bool NETPOLL
> > > >         depends on NETPOLL


Gargh, what we're seeing here is a whole bunch of bugs, I think. First
I thought this must be one of those randconfig-producing-wrong-configs
issues, but surprisingly, running "make oldconfig" on this .config on
a fresh 2.6.23-rc1-mm1 tree didn't change anything in the .config.


Kconfig bug #1:
===============

Which means, although:

*****
menuconfig BAZ

if BAZ

config BAR

endif
*****

is widely believed (by most folks, I've heard this on several threads,
and as written in the comment in drivers/net/Kconfig) to be equivalent to:

*****
menuconfig BAZ

if BAZ
endif

config BAR
	depends on BAZ
*****

this is *not* enforced by "make oldconfig"! And hence, the NETPOLL &&
!NETDEVICES situation we're seeing here.

[ We could also categorize this as a bug in Kconfig's "if", fwiw. ]


Kconfig bug #2:
===============

config FOO
	def_bool BAR

is supposed to ensure that FOO == BAR (as Matt mentioned earlier).

However, even this is *not* enforced by "make oldconfig". And hence,
the NETPOLL && !NET_POLL_CONTROLLER situation we're seeing here.

In fact, I believe it's possible to even pass a NETCONSOLE but
!NETPOLL kind of .config through "make oldconfig" but it still won't
catch it, and build breakages *will* occur.

[ We could also categorize this as a bug in Kconfig's "def_bool", fwiw. ]

Possibly, we could also decide to just blame "randconfig" for the whole
issue, and forget about these, because I think it's highly unlikely
(though not impossible) for people with "real" .configs to hit the
problems we saw above.


KGDBOE bug #1:
==============

config KGDBOE in lib/Kconfig.kgdb must also "depend on" NETDEVICES,
and select NET_POLL_CONTROLLER also.


KGDBOE bug #2:
==============

config KGDBOE_NOMODULE is a sad, sad option, and must be killed. The
"if !KGDBOE_NOMODULE" in KGDBOE must be removed, and it must lose its
dependency on "m".


Satyam
