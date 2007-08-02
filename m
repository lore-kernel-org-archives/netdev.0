From: Matt Mackall <mpm@selenic.com>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Wed, 1 Aug 2007 21:02:19 -0500
Message-ID: <20070802020219.GM11166@waste.org>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <20070731121735.GA1046@ff.dom.local> <46AF4F9C.5060000@googlemail.com> <20070801095920.GA1941@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com,
	Sam Ravnborg <sam@ravnborg.org>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:46995 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbXHBCCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 22:02:14 -0400
Content-Disposition: inline
In-Reply-To: <20070801095920.GA1941@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 01, 2007 at 11:59:21AM +0200, Jarek Poplawski wrote:
> On Tue, Jul 31, 2007 at 05:05:00PM +0200, Gabriel C wrote:
> > Jarek Poplawski wrote:
> > > On Tue, Jul 31, 2007 at 12:14:36PM +0200, Gabriel C wrote:
> > >> Jarek Poplawski wrote:
> > >>> On 28-07-2007 20:42, Gabriel C wrote:
> > >>>> Andrew Morton wrote:
> > >>>>> On Sat, 28 Jul 2007 17:44:45 +0200 Gabriel C <nix.or.die@googlemail.com> wrote:
> > >>>>>
> > >>>>>> Hi,
> > >>>>>>
> > >>>>>> I got this compile error with a randconfig ( http://194.231.229.228/MM/randconfig-auto-82.broken.netpoll.c ).
> > >>>>>>
> > >>>>>> ...
> > >>>>>>
> > >>>>>> net/core/netpoll.c: In function 'netpoll_poll':
> > >>>>>> net/core/netpoll.c:155: error: 'struct net_device' has no member named 'poll_controller'
> > >>>>>> net/core/netpoll.c:159: error: 'struct net_device' has no member named 'poll_controller'
> > >>>>>> net/core/netpoll.c: In function 'netpoll_setup':
> > >>>>>> net/core/netpoll.c:670: error: 'struct net_device' has no member named 'poll_controller'
> > >>>>>> make[2]: *** [net/core/netpoll.o] Error 1
> > >>>>>> make[1]: *** [net/core] Error 2
> > >>>>>> make: *** [net] Error 2
> > >>>>>> make: *** Waiting for unfinished jobs....
> > >>>>>>
> > >>>>>> ...
> > >>>>>>
> > >>>>>>
> > >>>>>> I think is because KGDBOE selects just NETPOLL.
> > >>>>>>
> > >>>>> Looks like it.
> > >>>>>
> > >>>>> Select went and selected NETPOLL and NETPOLL_TRAP but things like
> > >>>>> CONFIG_NETDEVICES and CONFIG_NET_POLL_CONTROLLER remain unset.  `select'
> > >>>>> remains evil.
> > >>> ...
> > >>>> I think there may be a logical issue ( again if I got it right ).
> > >>>> We need some ethernet card to work with kgdboe right ? but we don't have any if !NETDEVICES && !NET_ETHERNET.
> > >>>>
> > >>>> So maybe some ' depends on ... && NETDEVICES!=n && NET_ETHERNET!=n ' is needed too ? 
> > >>> IMHO, the only logical issue here is netpoll.c mustn't use 
> > >>> CONFIG_NET_POLL_CONTROLLER code without #ifdef if it doesn't
> > >>> add this dependency itself.
> > >>>
> > >> Well it does if NETDEVICES && if NET_ETHERNET which booth are N when !NETDEVICES is why KGDBOE uses select and not depends on.
> > > 
> > > "does if XXX" means may "use if XXX".
> > 
> > From what I know means only use "if xxx" on !xxx everything inside the "if xxx" is n and "depends on <something inside the if xxx> 
> > does not work.
> > 
> > ...
> > 
> > menuconfig FOO
> > 	bool "FOO"
> > 	depends on BAR
> > 	default y 
> > 	-- help --
> > 	something
> > if FOO
> > 
> > config BAZ
> > 	depends on WHATEVR && !NOT_THIS
> > 
> > menuconfig SOMETHING_ELSE
> > 	....
> > if SOMETHING_ELSE
> > 
> > config BLUBB
> > 	depends on PCI && WHATNOT
> > 
> > endif # SOMETHING_ELSE
> > 
> > config NETPOLL
> >         def_bool NETCONSOLE
> >         
> > config NETPOLL_TRAP
> >         bool "Netpoll traffic trapping"
> >         default n
> >         depends on NETPOLL
> >           
> > config NET_POLL_CONTROLLER
> >         def_bool NETPOLL
> > 
> > endif # FOO
> > 
> > Now if you set FOO=n all is gone and your driver have to select whatever it needs from there.
> 
> Probably not exactly so...
> 
> >From drivers/net/Kconfig:
> 
> > # All the following symbols are dependent on NETDEVICES - do not repeat
> > # that for each of the symbols.
> > if NETDEVICES
> 
> So, according to this netpoll could presume NETDEVICES and
> NET_POLL_CONTROLLER are always on.
> 
> But, as you've found, it's possible to select NETPOLL and !NETDEVICES,
> so this comment is at least not precise.
> 
> On the other side something like this:
> 
> ...
> endif # NETDEVICES
> 
> config NETPOLL
>         depends on NETDEVICES
>         def_bool NETCONSOLE
> 
> config NETPOLL_TRAP
>         bool "Netpoll traffic trapping"
>         default n
>         depends on NETPOLL
> 
> config NET_POLL_CONTROLLER
>         def_bool NETPOLL
>         depends on NETPOLL
> 
> 
> seems to select NET_POLL_CONTROLLER after selecting NETPOLL, but
> still doesn't check for NETDEVICES dependency.

That's odd. Adding Sam to the cc:.

> > >> Now KGDBOE just selects NETPOLL and NETPOLL_TRAP.
> > >> Adding 'select CONFIG_NET_POLL_CONTROLLER' let kgdboe compiles but the question is does it work without any ethernet card ?
> > > 
> > > Why kgdboe should care what netpoll needs? So, I hope, you are adding
> > > this select under config NETPOLL. On the other hand, if NETPOLL should
> > > depend on NET_POLL_CONTROLLER there is probably no reason to have them
> > > both.
> > 
> > NET_POLL_CONTROLLER has def_bool NETPOLL if NETDEVICES .
> > 
> > Net peoples ping ?:)

How about cc:ing the netpoll maintainer?
 
> OK, I wasn't right here: there is no visible reason for both in the
> kernel code, but I can imagine there could be some external users of
> NET_POLL_CONTROLLER without NETPOLL.

I don't know of any. As far as I can tell at this point,
NET_POLL_CONTROLLER == NETPOLL.

-- 
Mathematics is the supreme nostalgia of our time.
