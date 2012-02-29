From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Tue, 28 Feb 2012 20:40:06 -0800
Message-ID: <4F4DAC26.4050108@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>  <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>  <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>  <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com>  <1329315057.4158.15.camel@mojatatu>  <4F3C5B44.7000608@intel.com>  <1329488932.2272.19.camel@mojatatu>  <4F3E8A01.5000205@intel.com> <1329568900.3027.0.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, kernel@wantstofly.org
To: jhs@mojatatu.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1329568900.3027.0.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/18/2012 4:41 AM, jamal wrote:
> On Fri, 2012-02-17 at 09:10 -0800, John Fastabend wrote:
> 
>> Yes I agree that is the goal.
>>
>>> One last comment:
>>> With synchronization there are other challenges when the entry in the
>>> hardware conflicts with the entry in software when you intend the
>>> behavior to be the same. This is not such a big deal with bridging but
>>> becomes more apparent when you start offloading ACLs etc.
>>>
>>
>> OK and these sorts of conflicts certainly don't need to be resolved
>> by kernel code. So I think this is a reasonable reason to drive the
>> synchronization into a user space daemon.
> 
> 
> Yep. 
> Thanks for listening John. Waiting to see them patches.
> 
> cheers,
> jamal
> 
> 
> 

+Lennert

OK back to this. The last piece is where to put these messages...
we could take PF_ROUTE:RTM_*NEIGH

     PF_ROUTE:RTM_NEWNEIGH - Add a new FDB entry to an offloaded
                             switch.
     PF_ROUTE:RTM_DELNEIGH - Delete a FDB entry from an offlaoded
                             switch.
     PF_ROUTE:RTM_GETNEIGH - Dumps the embedded FDB table

The neighbor code is using the PF_UNSPEC protocol type so we won't
collide with these unless someone was using PF_ROUTE and relying on
falling back to PF_UNSPEC however I couldn't find any programs that
did this iproute2 certainly doesn't. And the bridge pieces are using
PF_BRIDGE so no collision there.

I briefly thought about trying to pull the PF_BRIDGE protocol out
and use this for both types but I think its better to leave the
bridge code alone and there is also the issue of disambiguating a msg
at a port which has both an embedded switch and has SW bridge for a
master.

Also if there are embedded switches with learning capabilities they
might want to trigger events to user space. In this case having
a protocol type makes user space a bit easier to manage. I've
added Lennert so maybe he can comment I think the Marvell chipsets
might support something along these lines. The SR-IOV chipsets I'm
aware of _today_ don't do learning. Learning makes the event model
more plausible.

The other mechanism would be to embed some more attributes into the
PF_UNSPEC:RTM_XXXLINK msg however I'm thinking that if we want to
support learning and triggering events then we likely also don't
want to send these events to every app with RTNLGRP_LINK set.

Plus there is already a proliferation of LINK attributes and dumping
the FDB out of this seems a bit much but could be done with some
bitmasks. Although the current ext_filter_mask u32 doesn't seem to
be sufficient for events to trigger this.

so much for a short note...

Thanks
.John




