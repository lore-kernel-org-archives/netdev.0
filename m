From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
 negotiation
Date: Tue, 16 Dec 2008 01:40:45 -0800 (PST)
Message-ID: <20081216.014045.217150811.davem@davemloft.net>
References: <e2d7436a0812140650r41b601dfgc3bbf41f01c2bb5d@mail.gmail.com>
	<36660.148.187.160.35.1229358346.squirrel@148.187.160.35>
	<20081216052954.GA6199@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, acme@redhat.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49297
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbYLPJkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 04:40:43 -0500
In-Reply-To: <20081216052954.GA6199@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 16 Dec 2008 06:29:54 +0100

> | Hence I think we have a chance by going completely lockless here, by
> | loading all configured CCIDs at runtime. In this manner the per-connection
> | check "are all advertised CCIDs are loaded?" falls under the table, we
> | do not need to worry about concurrent access, and loading DCCP implies that
> | all needed CCIDs are there.
> Unfortunately this won't work since the CCIDs depend on dccp.ko being
> fully loaded, so requiring that CCID module are loaded during the
> loading process of dccp.ko creates a cyclic dependency.

I don't like this stuff at all.

Every new connection you're going to loop over the CCID
table and grab that CCID read lock N times.

The first time it will do something meaningful, and then
%99.999999999999 of subsequent calls will do nothing.

What kind of overhead is deserved by that access pattern?

And, if the first thing the first connection is going to do
is load all the modules, there is ZERO reason to make them
modular.  It's just useless seperation and it adds all of
this rediculious synchronization.

If it's modular "for the sake of development" I'm sure you
can simply reload the dccp.ko module when you make some
CCID algorithm change.

I'm tossing this patch set until we get something better
in this area.
