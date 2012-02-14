From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Tue, 14 Feb 2012 10:57:04 -0800
Message-ID: <4F3AAE80.4040609@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>  <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>  <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com> <1329225526.2806.34.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: jhs@mojatatu.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1329225526.2806.34.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/14/2012 5:18 AM, jamal wrote:
> On Mon, 2012-02-13 at 07:13 -0800, John Fastabend wrote:
> 
>> The use case here is multiple VFs but the same solution should work with
>> multiple PFs as well. FDB controls should be independent of how the ports
>> are exposed VFs, PFs, VMDQ/queue pairs, macvlan, etc.
> 
> Makes sense.
> 
>> With events and ADD/DEL/GET FDB controls we can solve both cases. This also
>> solves Roopa's case with macvlan where she wants to add additional addresses
>> to macvlan ports.
> 
> Not familiar with that issue - I'll prowl the list.

Roopa was likely on the right track here,

http://patchwork.ozlabs.org/patch/123064/

But I think the proper syntax is to use the existing PF_BRIDGE:RTM_XXX
netlink messages. And if possible drive this without extending ndo_ops.

An ideal user space interaction IMHO would look like,

[root@jf-dev1-dcblab iproute2]# ./br/br fdb add 52:e5:62:7b:57:88 dev veth10
[root@jf-dev1-dcblab iproute2]# ./br/br fdb
port    mac addr                flags
veth2   36:a6:35:9b:96:c4       local
veth4   aa:54:b0:7b:42:ef       local
veth0   2a:e8:5c:95:6c:1b       local
veth6   6e:26:d5:43:a3:36       local
veth0   f2:c1:39:76:6a:fb
veth8   4e:35:16:af:87:13       local
veth10  52:e5:62:7b:57:88       static
veth10  aa:a9:35:21:15:c4       local
[root@jf-dev1-dcblab iproute2]# ./br/br fdb add dev eth3 to 52:e5:62:7b:57:88
RTNETLINK answers: Invalid argument

Using Stephen's br tool. First command adds FDB entry to SW bridge and
if the same tool could be used to add entries to embedded bridge I think
that would be the best case. So no RTNETLINK error on the second cmd. Then
embedded FDB entries could be dumped this way also so I get a complete view
of my FDB setup across multiple sw bridges and embedded bridges.

I don't think br is part of iproute2 yet I just pulled it out of some RFC
but it works reasonably well and is intuitive enough.

> 
>> Yes it should flood here, unless its acting as a 802.1Qbg VEB or VEPA.
> 
> Ok. So there is a toggle somewhere which controls how flooding should
> happen.
> 

Yes. The hardware has a bit to support this which is currently not exposed
to user space. That's a case where we have 'yet another knob' that needs
a clean solution. This causes real bugs today when users try to use the
macvlan devices in VEPA mode on top of SR-IOV. By the way these modes are
all part of the 802.1Qbg spec which people actually want to use with Linux
so a good clean solution is probably needed.

>>
>> Maybe not. But the kernel already has the needed signals with one extra
>> hook we can save running a daemon in user space. Maybe that's not a great
>> argument to add kernel code though.
> 
> You make a reasonable arguement to have it in the kernel but i think we
> win more if we separate the control. So while i empathize, I am hoping
> that youd go with the path that is hard to travel ;->
> 
>> The PF_BRIDGE:RTM_GETNEIGH,RTM_NEWNEIGH,RTM_DELNEIGH are registered in the
>> br_netlink_init() path. 
> 
> Hrm - hadnt paid attention to that before. Nasty.
> The bridge seems to be hard-coding policy on station movement, no? 
> This is a good example of the qualms i have on adding things to the
> kernel;->
> I may not want to auto update a MAC address moving ports as part of
> some policy i have. I can go and add YAK (Yet Another Knob) - but where
> is the line drawn?
> 

I have no problem with drawing the line here and trying to implement something
over PF_BRIDGE:RTM_xxx nlmsgs. I'll work with Roopa and see if we can come
up with something in the next couple days.

w.r.t. VEPA/VEB and flooding behavior we could probably have a bit to indicate
if the port is a flooding port or not. Then users could build any sort of forwarding
table they wanted OR we could just drive it through a notifier (ndo_ops?) in the
macvlan path which does VEPA today.

OK I'll try to write some actual code now that can be critiqued.

> cheers,
> jamal
> 
> 

