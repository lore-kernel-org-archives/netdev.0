From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Wed, 15 Feb 2012 17:26:28 -0800
Message-ID: <4F3C5B44.7000608@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>  <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>  <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>  <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com> <1329315057.4158.15.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1329315057.4158.15.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/15/2012 6:10 AM, Jamal Hadi Salim wrote:
> On Tue, 2012-02-14 at 10:57 -0800, John Fastabend wrote:
> 
>> Roopa was likely on the right track here,
>>
>> http://patchwork.ozlabs.org/patch/123064/
> 
> Doesnt seem related to the bridging stuff - the modeling looks
> reasonable however.
> 

The operations are really the same ADD/DEL/GET additional MAC
addresses to a port, in this case a macvlan type port. The
difference is the  macvlan port type drops any packet with an
address not in the FDB where the bridge type floods these.

>> But I think the proper syntax is to use the existing PF_BRIDGE:RTM_XXX
>> netlink messages. And if possible drive this without extending ndo_ops.
>>
>> An ideal user space interaction IMHO would look like,
>>
>> [root@jf-dev1-dcblab iproute2]# ./br/br fdb add 52:e5:62:7b:57:88 dev veth10
>> [root@jf-dev1-dcblab iproute2]# ./br/br fdb
>> port    mac addr                flags
>> veth2   36:a6:35:9b:96:c4       local
>> veth4   aa:54:b0:7b:42:ef       local
>> veth0   2a:e8:5c:95:6c:1b       local
>> veth6   6e:26:d5:43:a3:36       local
>> veth0   f2:c1:39:76:6a:fb
>> veth8   4e:35:16:af:87:13       local
>> veth10  52:e5:62:7b:57:88       static
>> veth10  aa:a9:35:21:15:c4       local
> 
> Looks nice, where is the targeted bridge(eg br0) in that syntax?

[root@jf-dev1-dcblab src]# br fdb help
Usage: br fdb { add | del | replace } ADDR dev DEV
       br fdb {show} [ dev DEV ]

In my example I just dumped all bridge devices,

#br fdb show dev bridge0

> 
>> Using Stephen's br tool. First command adds FDB entry to SW bridge and
>> if the same tool could be used to add entries to embedded bridge I think
>> that would be the best case. 
> 
> That would be nice (although adds dependency on the presence of the
> s/ware bridge). Would be nicer to have either a knob in the kernel to
> say "synchronize with h/w bridge foo" which can be turned off.  
> 

Seems we need both a synchronize and a { add | del | replace } option.

>> So no RTNETLINK error on the second cmd. Then
>> embedded FDB entries could be dumped this way also so I get a complete view
>> of my FDB setup across multiple sw bridges and embedded bridges.
> 
> So if you had multiple h/ware bridges - which one is tied to br0? 
> 

Not sure I follow but does the additional dev parameter above answer this?

> 
>> Yes. The hardware has a bit to support this which is currently not exposed
>> to user space. That's a case where we have 'yet another knob' that needs
>> a clean solution. This causes real bugs today when users try to use the
>> macvlan devices in VEPA mode on top of SR-IOV. By the way these modes are
>> all part of the 802.1Qbg spec which people actually want to use with Linux
>> so a good clean solution is probably needed.
> 
> 
> I think the knobs to "flood" and "learn" are important. The hardware
> seems to have the "flood" but not the "learn/discover". I think the
> s/ware bridge needs to have both. At the moment - as pointed out in that
> *NEIGH* notification, s/w bridge assumes a policy that could be
> considered a security flaw in some circles - just because you are my
> neighbor does not mean i trust you to come into my house; i may trust
> you partially and allow you only to come through the front door. Even in
> Canada with a default policy of not locking your door we sometimes lock
> our doors ;->
> 
> 
>> I have no problem with drawing the line here and trying to implement something
>> over PF_BRIDGE:RTM_xxx nlmsgs. 
> 
> 
> My comment/concern was in regard to the bridge built-in policy of
> reading from the neighbor updates (refer to above comments)
> 

So I think what your saying is a per port bit to disable learning...

hmm but if you start tweaking it too much it looks less and less like a
802.1D bridge and more like something you would want to build with tc or
openvswitch or tc+bridge or tc+macvlan.

.John

> cheers,
> jamal
> 
> 

