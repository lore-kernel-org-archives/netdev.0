From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Distributed storage.
Date: Fri, 03 Aug 2007 16:53:37 +0200
Message-ID: <1186152817.12034.128.camel@twins>
References: <20070731171347.GA14267@2ka.mipt.ru>
	 <200708021408.24876.phillips@phunq.net>
	 <20070803102629.GB10089@2ka.mipt.ru> <20070803105747.GE10089@2ka.mipt.ru>
	 <1186144072.11797.55.camel@lappy>  <20070803134943.GA21221@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Phillips <phillips@phunq.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39290 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761564AbXHCOxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 10:53:40 -0400
In-Reply-To: <20070803134943.GA21221@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-03 at 17:49 +0400, Evgeniy Polyakov wrote:
> On Fri, Aug 03, 2007 at 02:27:52PM +0200, Peter Zijlstra (peterz@infradead.org) wrote:
> > On Fri, 2007-08-03 at 14:57 +0400, Evgeniy Polyakov wrote:
> > 
> > > For receiving situation is worse, since system does not know in advance
> > > to which socket given packet will belong to, so it must allocate from
> > > global pool (and thus there must be independent global reserve), and
> > > then exchange part of the socket's reserve to the global one (or just
> > > copy packet to the new one, allocated from socket's reseve is it was
> > > setup, or drop it otherwise). Global independent reserve is what I
> > > proposed when stopped to advertise network allocator, but it seems that
> > > it was not taken into account, and reserve was always allocated only
> > > when system has serious memory pressure in Peter's patches without any
> > > meaning for per-socket reservation.
> > 
> > This is not true. I have a global reserve which is set-up a priori. You
> > cannot allocate a reserve when under pressure, that does not make sense.
> 
> I probably did not cut enough details - my main position is to allocate
> per socket reserve from socket's queue, and copy data there from main
> reserve, all of which are allocated either in advance (global one) or
> per sockoption, so that there would be no fairness issues what to mark 
> as special and what to not.
> 
> Say we have a page per socket, each socket can assign a reserve for
> itself from own memory, this accounts both tx and rx side. Tx is not
> interesting, it is simple, rx has global reserve (always allocated on 
> startup or sometime way before reclaim/oom)where data is originally 
> received (including skb, shared info and whatever is needed, page is 
> just an exmaple), then it is copied into per-socket reserve and reused 
> for the next packet. Having per-socket reserve allows to have progress 
> in any situation not only in cases where single action must be 
> received/processed, and allows to be completely fair for all users, but
> not only special sockets, thus admin for example would be allowed to
> login, ipsec would work and so on...


Ah, I think I understand now. Yes this is indeed a good idea!

It would be quite doable to implement this on top of that I already
have. We would need to extend the socket with a sock_opt that would
reserve a specified amount of data for that specific socket. And then on
socket demux check if the socket has a non zero reserve and has not yet
exceeded said reserve. If so, process the packet.

This would also quite neatly work for -rt where we would not want
incomming packet processing to be delayed by memory allocations.

