From: Simon Horman <horms@verge.net.au>
Subject: Re: Kconfig warnings on latest GIT
Date: Fri, 11 May 2007 12:08:54 +0900
Message-ID: <20070511030852.GJ10715@verge.net.au>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au> <46434ED0.6030808@freescale.com> <20070511012529.GC10715@verge.net.au> <Pine.LNX.4.64.0705102046400.10555@gate.crashing.org> <20070511020545.GG10715@verge.net.au> <Pine.LNX.4.64.0705102111570.11348@gate.crashing.org> <20070511022721.GI10715@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: sam@ravnborg.org, Timur Tabi <timur@freescale.com>,
	Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ismail =?iso-8859-1?Q?D=F6nmez?= <ismail@pardus.org.tr>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:45467 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755807AbXEKDI6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 23:08:58 -0400
Content-Disposition: inline
In-Reply-To: <20070511022721.GI10715@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 11:27:22AM +0900, Simon Horman wrote:
> On Thu, May 10, 2007 at 09:13:34PM -0500, Kumar Gala wrote:
> > On Fri, 11 May 2007, Simon Horman wrote:
> > 
> > > On Thu, May 10, 2007 at 08:47:05PM -0500, Kumar Gala wrote:
> > > > Try this patch:
> > >
> > > That certainly resolves the problem for me.
> > > I'll see about doing something like that for the similar
> > > Kconfig problems that I see.
> > 
> > I've got a similar fix for SYS_SUPPORTS_APM_EMULATION already.  I'll push
> > both of these to Paul.  If you can put something in place for the
> > Atari/68k and send it to Geert that would be good (feeling a little lazy
> > right now :)
> > 
> > I'm still not happy about this fix.  I'd like to get Sam's feeling on if
> > we can fixup kconfig not to warn if the dependency isn't meet.  I think
> > the select is valid, and would prefer to fix this properly before we paper
> > tape over it.
> 
> I agree. I had thought a little about a kconfig fix. Though I'm
> wondering if removing the warning will lead to oodles of dangling
> symbols and invalid checks over time.
> 
> In any case, I'll look into the Atari problem. At least that way
> there will be some patches to add to the discussion.

The fix below seems to work for the ATARI problem.
Do you want me to submit it properly, do you want to
submit it along with the other patches, or do you think
we should sit on things for a bit?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] [IA64] ATARI_KBD_CORE only exists on m68k

ATARI_KBD_CORE doesn't exist on architectures other than m68k,
which causes the following warnings:

drivers/input/keyboard/Kconfig:170:warning: 'select' used by config symbol 'KEYBOARD_ATARI' refers to undefined symbol 'ATARI_KBD_CORE'
drivers/input/mouse/Kconfig:181:warning: 'select' used by config symbol 'MOUSE_ATARI' refers to undefined symbol 'ATARI_KBD_CORE'

By reversing the Kconfig logic, the same results should occur on
m68k as the current code, but the warnings go away on other platforms.

Cc: Kumar Gala <galak@kernel.crashing.org>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
 arch/m68k/Kconfig              |    1 +
 drivers/input/keyboard/Kconfig |    1 -
 drivers/input/mouse/Kconfig    |    1 -
 3 files changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6/arch/m68k/Kconfig
===================================================================
--- linux-2.6.orig/arch/m68k/Kconfig	2007-05-11 11:37:25.000000000 +0900
+++ linux-2.6/arch/m68k/Kconfig	2007-05-11 11:42:48.000000000 +0900
@@ -410,6 +410,7 @@ config STRAM_PROC
 	  Say Y here to report ST-RAM usage statistics in /proc/stram.
 
 config ATARI_KBD_CORE
+	default y if KEYBOARD_ATARI || MOUSE_ATARI
 	bool
 
 config HEARTBEAT
Index: linux-2.6/drivers/input/keyboard/Kconfig
===================================================================
--- linux-2.6.orig/drivers/input/keyboard/Kconfig	2007-05-11 11:37:25.000000000 +0900
+++ linux-2.6/drivers/input/keyboard/Kconfig	2007-05-11 11:42:53.000000000 +0900
@@ -167,7 +167,6 @@ config KEYBOARD_AMIGA
 config KEYBOARD_ATARI
 	tristate "Atari keyboard"
 	depends on ATARI
-	select ATARI_KBD_CORE
 	help
 	  Say Y here if you are running Linux on any Atari and have a keyboard
 	  attached.
Index: linux-2.6/drivers/input/mouse/Kconfig
===================================================================
--- linux-2.6.orig/drivers/input/mouse/Kconfig	2007-05-11 11:40:32.000000000 +0900
+++ linux-2.6/drivers/input/mouse/Kconfig	2007-05-11 11:42:58.000000000 +0900
@@ -178,7 +178,6 @@ config MOUSE_AMIGA
 config MOUSE_ATARI
 	tristate "Atari mouse"
 	depends on ATARI
-	select ATARI_KBD_CORE
 	help
 	  Say Y here if you have an Atari and want its native mouse
 	  supported by the kernel.
