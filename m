From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 4 Sep 2012 00:22:30 +0300
Message-ID: <20120903212230.GA6795@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZ+ZHBg=vswgmWWz2D0GyWhD-ghkuY9_7CQB47uDmyzhsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>,
	Ali Ayoub <ali@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578Ab2ICVVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 17:21:31 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZ+ZHBg=vswgmWWz2D0GyWhD-ghkuY9_7CQB47uDmyzhsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 03, 2012 at 11:53:56PM +0300, Or Gerlitz wrote:
> Michael S. Tsirkin <mst@redhat.com> wrote:
> 
> > [...] so it seems that a sane solution would involve an extra level of
> > indirection, with guest addresses being translated to host IB addresses.
> > As long as you do this, maybe using an ethernet frame format makes sense.
> 
> > So far the things that make sense. Here are some that don't, to me:
> 
> > - Is a pdf presentation all you have in terms of documentation?
> >   We are talking communication protocols here - I would expect a
> >   proper spec, and some effort to standardize, otherwise where's the
> >   guarantee it won't change in an incompatible way?
> >   Other things that I would expect to be addressed in such a spec is
> >   interaction with other IPoIB features, such as connected
> >   mode, checksum offloading etc, and IB features such as multipath etc.
> >
> > - The way you encode LID/QPN in the MAC seems questionable. IIRC there's
> >   more to IB addressing than just the LID.  Since everyone on the subnet
> >   need access to this translation, I think it makes sense to store it in
> >   the SM. I think this would also obviate some IPv4 specific hacks in kernel.
> 
> > - IGMP/MAC snooping in a driver is just too hairy.
> >   As you point out, bridge currently needs the uplink in promisc mode.
> >   I don't think a driver should work around that limitation.
> >   For some setups, it might be interesting to remove the promisc
> >  mode requirement, failing that, I think you could use macvtap passthrough.
> >
> > - Currently migration works without host kernel help, would be
> >   preferable to keep it that way.
> 
> Hi Michael,
> 
> If we rewind to this point, basically, you had few concerns

I think some other people gave feedback too, you need to address it in
the patch (as opposed to by mail - even if it's in documentation or
comments) don't just focus on what I wrote.

> 
> 0. not enough documentation
> 
> 1. the sender VM MAC isn't preserved when the packet is received
> 
> 2. the IGMP snooping we planned to do within netdevice - isn't good practice
> 
> 3. mangling of ARPs within netdevice - isn't good practice as well.
> 
> For 0,1,2 we have a way to address  (see below)
> 
> So we are remained with #3 - the ARPs -- thinking on this a little
> further, FWIW there --are-- components in the kernel which
> mangle/generate ARPs and are exposing netdevice, such as openvswitch,
> anyway:
> 
> does it make sense to forward ARPs received into / sent over the
> eIPoIB netdevice (e.g using some sort of rule) to some outer entity
> such as user-space
> daemon  for interception and later re-injection into eIPoIB?
> 
> Or.

Well if this is all you want to do, you can bind a packet socket to the
interface, and drop them at the nic.  It is harder to do for incoming
ARP requests though.

I would do something else: send ARPs out to some defined IB address.
This could be local host or queries from some SA property.  Said remote
side could send you the responses in ethernet format so you do not need
to mangle responses at all.  Similarly for incoming ARP requests.

The rule to do this can also just redirect non IP packets -
this is IPoIB after all.

> Documentation we will fix,

And just to stress the point, document the limitations as well.

> Preserving remote VM mac at the receiver we have few directions for
> solution, e.g either along your suggestion with SA records and/or with
> using "alias GUIDs" (details TBD when the submission resumes).
> 
> Multicast we accept the direction you suggested - implement  support
> for multicast non promiscuous in the elements "above" eIPoIB (bridge,
> macvtap, etc).
