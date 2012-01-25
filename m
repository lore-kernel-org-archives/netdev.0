From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC] Allow ipv6 proxies and arp proxies be shown with ip
Date: Thu, 26 Jan 2012 02:59:31 +0400
Message-ID: <20120125225931.GA11019@ms2.inr.ac.ru>
References: <1327484698-344265-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ynot@mohnatka.ru, davem@davemloft.net, netdev@vger.kernel.org,
	xemul@parallels.com
To: Tony Zelenoff <antonz@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:38696 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751089Ab2AYXOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 18:14:11 -0500
Content-Disposition: inline
In-Reply-To: <1327484698-344265-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2012 at 01:44:58PM +0400, Tony Zelenoff wrote:
> But, ~11 years were passed and this command is still alive and useful.

Indeed. :-)


> Unfortunately proper filling of proxy neighbour info is not possible in
> case of compatibility with ip itself. Returning structure field which
> store state of record is reached its 8 bits limit and new flag showing
> proxy can't be added.

It is not necessary, there exists flag NTF_PROXY in ndm_flags.



>		 And at this point i'm stucked a bit. The ip utility
> must show that exact address is not just neighbour, but is a proxy. Can
> somebody advice me how to do it? Or maybe the whole idea is not good at all,
> if so - please tell me why.

Apparently, ip utility requires some modifications as well.


However, it is necessary to preserve compatibility with older ip utility,
which could be confused seeing proxy entries in the same stream.


I see two variants:

1. On request to list proxy entries, ip utility could send request containing
   full ndmsg with NTF_PROXY set in ndm_flags. When kernel sees request without NTF_PROXY,
   it dumps normal neighbor table. When it sees NTF_PROXY, it dumps proxy table instead.

   From user viewpoint, "ip neigh list ..." works as usual, "ip neigh list proxy ..." will list
   proxy entries.

2. Adding RTM_*PNEIGH and the whole new set of "ip pneigh ..." commands.
   Logically, I would prefer this solution and, unless I was lazy 10 years ago, I would
   go this way. Unfortunately, this will break compatibility with existing
   "ip neigh add/del proxy ...", so that the kludge to intercept NTF_PROXY command in RTM_*NEIGH
   is still required and the solution loses half of its beauty.

So, seems #1 looks better.

Alexey
