From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] [BUG?] ip ru flush && RTNETLINK answers: Numerical result
 out of range
Date: Mon, 19 Mar 2007 06:54:15 +0100
Message-ID: <45FE2587.3050205@trash.net>
References: <200703190046.47021.luciano@lugmen.org.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Luciano Ruete <luciano@lugmen.org.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48578 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965634AbXCSFyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 01:54:18 -0400
In-Reply-To: <200703190046.47021.luciano@lugmen.org.ar>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luciano Ruete wrote:
> After an: 
> # ip ru flush
> I loose all my ip rules but the priority 0 one. 
> root@sarasvati:~# ip ru
> 0:      from all lookup 255
> root@sarasvati:~#  
> 
> Ok with that, but now i'm not able to insert any new rule.
> This leads to a total loose of conectivity.
> 
> root@sarasvati:~# ip ru add from all table default
> RTNETLINK answers: Numerical result out of range
> root@sarasvati:~# ip ru add from all lookup main
> RTNETLINK answers: Numerical result out of range
> 
> Even seting the priority value by hand, i got the same error:
> 
> root@sarasvati:~# ip ru add from all lookup main priority 32766
> RTNETLINK answers: Numerical result out of range
> 
> To be able to send this e-mail without rebooting i had to insert my gw ip 
> routes in table 255.
> 
> Is this a bug in iproute?
> 
> Some adiotional data:
> ip utility, iproute2-ss060323
> Linux sarasvati 2.6.20-5-386 #2 Sat Jan 6 14:44:57 UTC 2007 i686 GNU/Linux


The problem seems to be the nla policy added in 2.6.19 or 2.6.20.
When specifying a prefix as "all", iproute adds a zero byte long
attribute (FRA_SRC in this case). The IPv4 fib_rules policy states
that it has to be exactly 4 bytes long, which makes validation fail.
This also affects IPv6 and DECnet.

I would argue that iproute is broken and shouldn't add a zero
byte long attribute, but we still need to make sure the kernel
accepts these attributes as valid.

Thomas, I can't see a clean way to fix this right now that
doesn't either bloat struct nla_policy or removes FRA_SRC/FRA_DST
from the policy, could you please look into this? Thanks.

