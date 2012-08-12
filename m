From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 13:22:40 +0300
Message-ID: <20120812102240.GG1421@redhat.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
 <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
 <87boitz044.fsf@xmission.com>
 <20120805185031.GA18640@redhat.com>
 <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab2HLKYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 06:24:00 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 08, 2012 at 08:23:15AM +0300, Or Gerlitz wrote:
> On Sun, Aug 5, 2012 at 9:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> 
> [...]
> > So it seems that a sane solution would involve an extra level of
> > indirection, with guest addresses being translated to host IB addresses.
> > As long as you do this, maybe using an ethernet frame format makes sense.
> [...]
> 
> Yep, that's among the points we're trying to make, the way you've put
> it makes it clearer.
> 
> > So far the things that make sense. Here are some that don't, to me:
> 
> > - Is a pdf presentation all you have in terms of documentation?
> >   We are talking communication protocols here - I would expect a
> >   proper spec, and some effort to standardize, otherwise where's the
> >   guarantee it won't change in an incompatible way?
> 
> To be precise, the solution uses 100% IPoIB wire-protocol, so we don't
> see a need
> for any spec change / standardization effort.

Yes, I am guessing this is the real reason you pack LID/QPN
in the MAC - to make it all local. But it's a hack really,
and if you start storing it all in the SM you will need
to document the format so others can inter-operate.

> This might go to the 1st
> point you've
> brought... improve the documentation, will do that. The pdf you looked
> at was presented
> in a conference.
> 
> >   Other things that I would expect to be addressed in such a spec is
> >   interaction with other IPoIB features, such as connected
> >   mode, checksum offloading etc, and IB features such as multipath etc.
> 
> For the eipoib interface, it doesn't really matters if the underlyind
> ipoib clones used by it (we call them VIFs) use connected or datagram
> mode, what does matter is the MTU and offload features supported by
> these VIFs, for which the eipoib interface will have the min among all
> these VIFs. Since for a given eipoib nic, all its VIFs must originated
> from the same IPoIB PIF (e.g ib0) its easy admin job to make sure they
> all have the same mtu / features which are needed for that eipoib nic,
> e.g by using the same mode (connected/datagram for all of them), hope
> this is clear.
> 

Just pointing out all this needs to be documented.

> > - The way you encode LID/QPN in the MAC seems questionable. IIRC there's
> >   more to IB addressing than just the LID.  Since everyone on the subnet
> >   need access to this translation, I think it makes sense to store it in
> >   the SM. I think this would also obviate some IPv4 specific hacks in kernel.
> 
> The idead beyond the encoding was uniqueness, LID/QPN is unique per IB
> HCA end-node.

But then it breaks with VM migration, IB failover, softmac setting in
guest, probably more?

> I wasn't sure to understand the comment re the IPv4 hacks.

This refers to the ARP hack that you use to fix
VM migration.

> > - IGMP/MAC snooping in a driver is just too hairy.
> 
> mmm, any rough idea/direction how to do that otherwise?

Sure, even two ways, ideally you'd do both :)
A. fix macvtap
1. Use netdev_for_each_mc_addr etc to get multicast addresses
2. teach macvtap to fill that in (it currently floods multicasts
   for guest to guest communication so we ned to fix it anyway)

B. fix bridge
   teach bridge to work for VMs without using promisc mode


> >   As you point out, bridge currently needs the uplink in promisc mode.
> >   I don't think a driver should work around that limitation.
> >   For some setups, it might be interesting to remove the
> >   promisc mode requirement, failing that,
> >   I think you could use macvtap passthrough.
> 
> That's in the plans, the current code doesn't assume that the eipoib
> has bridge on top, for VM networking it works with bridge + tap,
> bridge + macvtap, but it would easily work with passthrough when we
> allow to create multiple eipoib interfaces on the same ipoib PIF (e.g
> today for the ib0 PIF we create eipoib eth0, and then two VIFs ib0.1
> and ib0.2 that are enslaved by eth0, but next we will create eth1 and
> eth2 which will use ib0.1 and ib0.2
> respectively.

The whole promisc mode emulation is there for the bridge, no?
Since you don't support promisc, ideally we'd check a hardware
capability and fail gracefully, though naturally this is not top
priority.

> > - Currently migration works without host kernel help, would be
> >   preferable to keep it that way.
> 
> OK
