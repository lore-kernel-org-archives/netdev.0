From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Sat, 28 Jul 2007 10:26:39 -0700
Message-ID: <20070728102639.872ec9a0.akpm@linux-foundation.org>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<46AB646D.8020104@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54235 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbXG1R0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2007 13:26:47 -0400
In-Reply-To: <46AB646D.8020104@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Jul 2007 17:44:45 +0200 Gabriel C <nix.or.die@googlemail.com> wrote:

> Hi,
> 
> I got this compile error with a randconfig ( http://194.231.229.228/MM/randconfig-auto-82.broken.netpoll.c ).
> 
> ...
> 
> net/core/netpoll.c: In function 'netpoll_poll':
> net/core/netpoll.c:155: error: 'struct net_device' has no member named 'poll_controller'
> net/core/netpoll.c:159: error: 'struct net_device' has no member named 'poll_controller'
> net/core/netpoll.c: In function 'netpoll_setup':
> net/core/netpoll.c:670: error: 'struct net_device' has no member named 'poll_controller'
> make[2]: *** [net/core/netpoll.o] Error 1
> make[1]: *** [net/core] Error 2
> make: *** [net] Error 2
> make: *** Waiting for unfinished jobs....
> 
> ...
> 
> 
> I think is because KGDBOE selects just NETPOLL.
> 

Looks like it.

Select went and selected NETPOLL and NETPOLL_TRAP but things like
CONFIG_NETDEVICES and CONFIG_NET_POLL_CONTROLLER remain unset.  `select'
remains evil.

Something like this..

--- a/lib/Kconfig.kgdb~kgdb-kconfig-fix
+++ a/lib/Kconfig.kgdb
@@ -175,8 +175,7 @@ endchoice
 config KGDBOE
 	tristate "KGDB: On ethernet" if !KGDBOE_NOMODULE
 	depends on m && KGDB
-	select NETPOLL
-	select NETPOLL_TRAP
+	depends on NETPOLL_TRAP && NET_POLL_CONTROLLER
 	help
 	  Uses the NETPOLL API to communicate with the host GDB via UDP.
 	  In order for this to work, the ethernet interface specified must
_

