From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit  to upper layer
Date: Fri, 13 Mar 2009 22:10:59 +0000
Message-ID: <1236982259.3300.13.camel@achroite>
References: <1236866906.3221.11.camel@achroite>
	 <1236926602.2567.528.camel@ymzhang>
	 <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
	 <20090313.115137.254924980.davem@davemloft.net>
	 <65634d660903131401v24d0b5aarec36ad95220ba201@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yanmin_zhang@linux.intel.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:45329 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755184AbZCMWLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:11:15 -0400
In-Reply-To: <65634d660903131401v24d0b5aarec36ad95220ba201@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-03-13 at 14:01 -0700, Tom Herbert wrote:
> On Fri, Mar 13, 2009 at 11:51 AM, David Miller <davem@davemloft.net> wrote:
> >
> > From: Tom Herbert <therbert@google.com>
> > Date: Fri, 13 Mar 2009 10:06:56 -0700
> >
> > > You'll definitely want to look at the hardware provided hash.  We've
> > > been using a 10G NIC which provides a Toeplitz hash (the one defined
> > > by Microsoft) and a software RSS-like capability to move packets from
> > > an interrupting CPU to another for processing.  The hash could be used
> > > to index to a set of CPUs, but we also use the hash as a connection
> > > identifier to key into a lookup table to steer packets to the CPU
> > > where the application is running based on the running CPU of the last
> > > recvmsg.  Using the device provided hash in this manner is a HUGE win,
> > > as opposed to taking cache misses to get 4-tuple from packet itself to
> > > compute a hash.  I posted some patches a while back on our work if
> > > you're interested.
> >
> > I never understood this.
> >
> > If you don't let the APIC move the interrupt around, the individual
> > MSI-X interrupts will steer packets to individual specific CPUS and as
> > a result the scheduler will migrate tasks over to those cpus since the
> > wakeup events keep occuring there.
> 
> We are trying to follow the decisions scheduler as opposed to leading
> it.  This works on very loaded systems, with applications binding to
> cpusets, with threads that are receiving on multiple sockets.  I
> suppose it might be compelling if a NIC could steer packets per flow,
> instead of by a hash...

Depending on the NIC, RX queue selection may be done using a large
number of bits of the hash value and an indirection table or by matching
against specific values in the headers.  The SFC4000 supports both of
these, though limited to TCP/IPv4 and UDP/IPv4.  I think Neptune may be
more flexible.  Of course, both indirection table entries and filter
table entries will be limited resources in any NIC, so allocating these
wholly automatically is an interesting challenge.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

