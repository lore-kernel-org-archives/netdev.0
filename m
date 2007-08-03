From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 12:48:37 -0700
Message-ID: <200708031248.37804.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <20070803134943.GA21221@2ka.mipt.ru> <1186152817.12034.128.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-085-152.lax1.dsl.speakeasy.net ([64.81.85.152]:59265
	"EHLO moonbase" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760624AbXHCTsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 15:48:39 -0400
In-Reply-To: <1186152817.12034.128.camel@twins>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 August 2007 07:53, Peter Zijlstra wrote:
> On Fri, 2007-08-03 at 17:49 +0400, Evgeniy Polyakov wrote:
> > On Fri, Aug 03, 2007 at 02:27:52PM +0200, Peter Zijlstra wrote:
> > ...my main position is to
> > allocate per socket reserve from socket's queue, and copy data
> > there from main reserve, all of which are allocated either in
> > advance (global one) or per sockoption, so that there would be no
> > fairness issues what to mark as special and what to not.
> >
> > Say we have a page per socket, each socket can assign a reserve for
> > itself from own memory, this accounts both tx and rx side. Tx is
> > not interesting, it is simple, rx has global reserve (always
> > allocated on startup or sometime way before reclaim/oom)where data
> > is originally received (including skb, shared info and whatever is
> > needed, page is just an exmaple), then it is copied into per-socket
> > reserve and reused for the next packet. Having per-socket reserve
> > allows to have progress in any situation not only in cases where
> > single action must be received/processed, and allows to be
> > completely fair for all users, but not only special sockets, thus
> > admin for example would be allowed to login, ipsec would work and
> > so on...
>
> Ah, I think I understand now. Yes this is indeed a good idea!
>
> It would be quite doable to implement this on top of that I already
> have. We would need to extend the socket with a sock_opt that would
> reserve a specified amount of data for that specific socket. And then
> on socket demux check if the socket has a non zero reserve and has
> not yet exceeded said reserve. If so, process the packet.
>
> This would also quite neatly work for -rt where we would not want
> incomming packet processing to be delayed by memory allocations.

At this point we need "anything that works" in mainline as a starting 
point.  By erring on the side of simplicity we can make this 
understandable for folks who haven't spent the last two years wallowing 
in it.  The page per socket approach is about as simple as it gets.  I 
therefore propose we save our premature optimizations for later.

It will also help our cause if we keep any new internal APIs to strictly 
what is needed to make deadlock go away.  Not a whole lot more than 
just the flag to mark a socket as part of the vm writeout path when you 
get right down to essentials.

Regards,

Daniel
