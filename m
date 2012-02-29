From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Wed, 29 Feb 2012 08:56:19 -0500
Message-ID: <1330523779.18226.17.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu>  <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu>  <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu>  <4F4DAC26.4050108@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, kernel@wantstofly.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4F4DAC26.4050108@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-02-28 at 20:40 -0800, John Fastabend wrote:

> OK back to this. The last piece is where to put these messages...
> we could take PF_ROUTE:RTM_*NEIGH
> 
>      PF_ROUTE:RTM_NEWNEIGH - Add a new FDB entry to an offloaded
>                              switch.
>      PF_ROUTE:RTM_DELNEIGH - Delete a FDB entry from an offlaoded
>                              switch.
>      PF_ROUTE:RTM_GETNEIGH - Dumps the embedded FDB table
> 

Why RTM_*NEIGH? RTM tends to map to Route/L3 and NEIGH tends to map
to ndisc or ARP both tied to IP address resolution. While both ARP/Ndisc
may play a role in the user space app populating the FDB, i dont think
they are necessary players.
Learning could be via a table entry miss and packet redirect to user
space.
So my suggestion is to use FDB_*ENTRY for names
 
> The neighbor code is using the PF_UNSPEC protocol type so we won't
> collide with these unless someone was using PF_ROUTE and relying on
> falling back to PF_UNSPEC however I couldn't find any programs that
> did this iproute2 certainly doesn't. And the bridge pieces are using
> PF_BRIDGE so no collision there.

They have to be different calls from the calls that talk to the s/ware
bridge. In my opinion, as controversial as this may sound, you need to
be flexible enough that some vendor can replace these calls with
proprietary calls which are more efficient for their hardware. So a
"plugin" to replace these calls in the user space code would be a 
good idea. Alternatively, you could make that something they do at
the driver level i.e from user space to kernel it is "hardware, please
addthistotheFDBtable()" call and the implementation of that could be
proprietary to the specific hardware.

[..]

> Also if there are embedded switches with learning capabilities they
> might want to trigger events to user space. In this case having
> a protocol type makes user space a bit easier to manage. I've
> added Lennert so maybe he can comment I think the Marvell chipsets
> might support something along these lines. The SR-IOV chipsets I'm
> aware of _today_ don't do learning. Learning makes the event model
> more plausible.

The other events to consider is aging of hardware entries.

> The other mechanism would be to embed some more attributes into the
> PF_UNSPEC:RTM_XXXLINK msg however I'm thinking that if we want to
> support learning and triggering events then we likely also don't
> want to send these events to every app with RTNLGRP_LINK set.

I think this needs to be a different event message. 
FDB_TABLEMISS? FDB_EXCEPTION?

> Plus there is already a proliferation of LINK attributes and dumping
> the FDB out of this seems a bit much but could be done with some
> bitmasks. Although the current ext_filter_mask u32 doesn't seem to
> be sufficient for events to trigger this.

Dumping the FDB table should be something along the lines of FDB_GET
with the dump flag. It shouldnt tie to the LINK side of things.

cheers,
jamal

