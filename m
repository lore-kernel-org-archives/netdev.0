From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Fri, 17 Feb 2012 09:10:25 -0800
Message-ID: <4F3E8A01.5000205@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>  <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>  <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>  <1329225526.2806.34.camel@mojatatu>  <4F3AAE80.4040609@intel.com>  <1329315057.4158.15.camel@mojatatu>  <4F3C5B44.7000608@intel.com> <1329488932.2272.19.camel@mojatatu>
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
In-Reply-To: <1329488932.2272.19.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/17/2012 6:28 AM, jamal wrote:
> On Wed, 2012-02-15 at 17:26 -0800, John Fastabend wrote:
>> On 2/15/2012 6:10 AM, Jamal Hadi Salim wrote:
>>> On Tue, 2012-02-14 at 10:57 -0800, John Fastabend wrote:
>>>
>>>> Roopa was likely on the right track here,
>>>>
>>>> http://patchwork.ozlabs.org/patch/123064/
>>>
>>> Doesnt seem related to the bridging stuff - the modeling looks
>>> reasonable however.
>>>
>>
>> The operations are really the same ADD/DEL/GET additional MAC
>> addresses to a port, in this case a macvlan type port. The
>> difference is the  macvlan port type drops any packet with an
>> address not in the FDB where the bridge type floods these.
> 
> Ok.
> [the vlan piece really should have been an integrated part of bridging;
> in the early days this was the case]
> 
> 
>> [root@jf-dev1-dcblab src]# br fdb help
>> Usage: br fdb { add | del | replace } ADDR dev DEV
>>        br fdb {show} [ dev DEV ]
>>
>> In my example I just dumped all bridge devices,
>>
> 
> Ok, makes sense.
> 
> 
>> Seems we need both a synchronize and a { add | del | replace } option.
> 
> I am conflicted on this.
> Not sure if that is a command line thing or something built into a user
> space daemon. It may be useful to have the command line variant but i
> feel having a daemon take care of things helps in faster
> synchronization.
> I think user space is a good spot to add such functionality (as opposed
> to the kernel). That way user space can work with h/ware switching such
> as yours as well as a standalone switching chips (from sillicon vendors
> like Marvel etc).
> IMO, the average user doesnt need to be aware of such low level stuff;
> so the default should be for the user not to be responsible for
> configuration of synchronization. IOW, I want to just run well
> understood user interface tools things like ifconfig, ip link etc, the
> new br tool and not even need to be aware that we are offloading.
> So as long as s/w br0 is mapping to the bridge on ixgb-0 i dont need
> to know ixgb0 h/w bridge exists.
> 

Yes I agree that is the goal.

> One last comment:
> With synchronization there are other challenges when the entry in the
> hardware conflicts with the entry in software when you intend the
> behavior to be the same. This is not such a big deal with bridging but
> becomes more apparent when you start offloading ACLs etc.
> 

OK and these sorts of conflicts certainly don't need to be resolved
by kernel code. So I think this is a reasonable reason to drive the
synchronization into a user space daemon.

> 
>> So I think what your saying is a per port bit to disable learning...
>> hmm but if you start tweaking it too much it looks less and less like a
>> 802.1D bridge and more like something you would want to build with tc or
>> openvswitch or tc+bridge or tc+macvlan.
> 
> These are pretty commodity features in most silicon switching chips ive
> come across. You have a knob to control learning and another to control
> flooding.
> 

All right this looks like a follow up patch to me. First build the interface
to configure the HW FDB. Then a second series to add a flooding knob which
works for both embedded switches and software switches.

> cheers,
> jamal
> 
