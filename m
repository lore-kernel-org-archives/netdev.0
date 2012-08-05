From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 5 Aug 2012 21:50:31 +0300
Message-ID: <20120805185031.GA18640@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754796Ab2HESuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2012 14:50:00 -0400
Content-Disposition: inline
In-Reply-To: <87boitz044.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 02, 2012 at 10:15:23AM -0700, Eric W. Biederman wrote:
> Or Gerlitz <ogerlitz@mellanox.com> writes:
> 
> > From: Erez Shitrit <erezsh@mellanox.co.il>
> >
> > The eipoib driver provides a standard Ethernet netdevice over
> > the InfiniBand IPoIB interface .
> >
> > Some services can run only on top of Ethernet L2 interfaces, and cannot be
> > bound to an IPoIB interface. With this new driver, these services can run
> > seamlessly.
> 
> Do I read this code correctly that what you are doing is not tunneling
> ethernet over IB but instead you are removing an ethernet header and
> replacing it with an IB header?
> 
> Do I also read this code correctly if you can't find your destination
> mac address in your ""neighbor table"" you do a normal IPoIB arp
> for the infiniband GUID?
> 
> Do I read this right that if presented with a non-IPv4 or ARP packet
> this code will do something undefined and unpredictable?
> 
> Maybe this makes some sense but just skimming it looks like you
> are trying to force a square peg into a round hole resulting in
> some weird code and some very weird maintainability issues.
> 
> I am honestly surprised at this approach.  I would think it would be
> faster and simpler to run an IB queue pair directly to the hypervisor or
> possibly even the guest operating system bypassing the kernel and doing
> all of this translation in userspace.
> 
> Eric

I'm on vacation and I have not looked at the patches, at Erez' request,
just reacting to the presentation and the discussion.

Bypassing the kernel has its own set of issues, not the
least of which is the need to lock all of guest memory which breaks
overcommit. Running an IB queue pair directly to the hypervisor
will also break live migration.

Another problem with exposing IB to guests has to do with the fact that
IB addresses such as combinations of LIDs, GIDs and QPNs to best of my
knowledge do not support soft hardware address setting, which interferes
with live migration.

So it seems that a sane solution would involve an extra level of
indirection, with guest addresses being translated to host IB addresses.

As long as you do this, maybe using an ethernet frame format makes
sense.

So far the things that make sense. Here are some that don't, to me:

- Is a pdf presentation all you have in terms of documentation?
  We are talking communication protocols here - I would expect a
  proper spec, and some effort to standardize, otherwise where's the
  guarantee it won't change in an incompatible way?
  Other things that I would expect to be addressed in such a spec is
  interaction with other IPoIB features, such as connected
  mode, checksum offloading etc, and IB features such as multipath etc.

- The way you encode LID/QPN in the MAC seems questionable. IIRC there's
  more to IB addressing than just the LID.  Since everyone on the subnet
  need access to this translation, I think it makes sense to store it in
  the SM. I think this would also obviate some IPv4 specific hacks
  in kernel.

- IGMP/MAC snooping in a driver is just too hairy.
  As you point out, bridge currently needs the uplink in promisc mode.
  I don't think a driver should work around that limitation.
  For some setups, it might be interesting to remove the
  promisc mode requirement, failing that,
  I think you could use macvtap passthrough.

- Currently migration works without host kernel help, would be
  preferable to keep it that way.


Hope this helps,
MST

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
