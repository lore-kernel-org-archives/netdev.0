From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Tue, 28 Jun 2016 12:04:00 -0700
Message-ID: <5772CA20.4030002@intel.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com> <1467043649-28594-9-git-send-email-saeedm@mellanox.com> <577211E2.90802@gmail.com> <28223ec8-f105-d598-39ad-5dc93598dc64@mellanox.com> <5772A397.3010905@gmail.com> <5772B18A.9000300@gmail.com> <20160628184655.GB2089@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Ido Schimmel <idosch@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18193 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbcF1TFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 15:05:20 -0400
In-Reply-To: <20160628184655.GB2089@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/28/2016 11:46 AM, Jiri Pirko wrote:
> Tue, Jun 28, 2016 at 07:19:06PM CEST, john.fastabend@gmail.com wrote:
>> On 16-06-28 09:19 AM, John Fastabend wrote:
>>> On 16-06-28 03:25 AM, Or Gerlitz wrote:
>>>> On 6/28/2016 8:57 AM, John Fastabend wrote:
>>>>> On 16-06-27 09:07 AM, Saeed Mahameed wrote:
>>>>>> Add the commands to set and show the mode of SRIOV E-Switch, two
>>>>>> modes are supported:
>>>>>>
>>>>>> * legacy   : operating in the "old" L2 based mode (DMAC --> VF vport)
>>>>>> * offloads : offloading SW rules/policy (e.g Bridge/FDB or TC/Flows
>>>>>> based) set by the host OS
>>>>>>
>>>>>> Nice work overall also I really appreciated that the core networking
>>>>>> interfaces appear to able to support this without any change.
>>>> thanks..
>>>>
>>>>>> On this patch though do we really need modes like this? My concern with
>>>>>> modes is two fold. One its another knob that some controller will have
>>>>>> to get right which I would prefer to avoid. And two I suspect switching
>>>>>> between the two modes flushes the tables or leaves them in some
>>>>>> unexpected state? At least I can't figure out what the expected should
>>>>>> be off-hand.
>>>> Re the 1st concern (another knob), I think we do want that, see below
>>>>
>>>> Re the 2nd concern, I will re-read the cover letter and change logs and
>>>> if needed clarify/improve: the transition is clean! When you are moving
>>>> from legacy to offloads or the other way around, nothing is left in
>>>> unexpected state,  all HW forwarding tables as filled by the current
>>>> mode are flushed and next they are set as needed for the new mode.
>>>>
>>> OK if I had read the entire patch series maybe I would have caught this
>>> :)
>>>
>>>>>> Could we instead continue to use the "legacy" mode by default by just
>>>>>> populating the fdb table correctly and then if users want to enable
>>>>>> the "offloads" mode they can modify the fdb tables by deleting entries
>>>>>> or adding them or just extending the dmac/vf mapping via 'tc'. This
>>>>>> would seem natural to me. The flooding rules in fdb might need to be
>>>>>> exposed a bit more cleanly to get the right default flooding behavior
>>>>>> etc. But to me at least this would be much cleaner. Everything will be
>>>>>> nicely defined and we wont have issues with drivers doing slightly
>>>>>> and subtle different defaults between legacy/offload and the transitions
>>>>>> between the states or on resets or etc. If users need to discover the
>>>>>> current configuration then they just query fdb, query tc, and the state
>>>>>> is known no need for any magic toggle switch as best I can see.
>>>>
>>>> Few comments here:
>>>>
>>>> Each mode has it's own way of the driver doing setup for the HW tables
>>>> and how population of the HW tables is done.
>>> hmm so in the hardware I have there is actually a l2 table and various
>>> other tables so I don't have any issue with doing table setup. I would
>>> like to see a table_create/table_delete/table_show devlink commands at
>>> some point though but I'm not there yet. This would allow users to
>>> optimize the table slices if they cared to. But that is future work
>>> IMO. Certainly not needed in this series at least. If you want I can
>>> show you a patch I had for this against rocker but it was before devlink
>>> so it would need some porting.
>>>
>>>> The offloads mode needs to create a black hole miss rule and
>>>> send-to-vport rules and create the tables so they can contain later
>>>> rules set by the kernel in a way which is HW/driver dependent.
>>> Agreed a black hole miss rule needs to be applied but rather than apply
>>> it automatically with some toggle I would prefer to just add a 'tc' rule
>>> for this. Or alternatively it can be added by configuring flooding
>>> ports so that only a single port is in the flooding mode. This could
>>> all be done via 'bridge fdb ...' and 'bridge link ...' today I believe.
>>> Then the user defines the state and not the driver writer. It really is
>>> cleaner in my opinion.
>>>
>>> One oddball case I have is if I have two PF functions behind a single
>>> network facing port. Yes its a bit strange but in this case its nice to
>>> pick which host facing PF to flood on vs the driver picking one.
>>>
>>> And send-to-vport rules I'm not entirely clear on what these actually
>>> are used for. Is this a rule to match packets sent from a VF representer
>>> netdev to the actual VF pcie device? If this is the case its seems to
>>> me that any packet sent on a VF representer should be sent to the VF
>>> directly and these rules can be created when the VF is created. Or did
>>> you mean some other rule by this?
>>>
>>>> The legacy mode creates the tables differently and populates them later
>>>> with rule set by
>>>> the driver and not the kernel.
>>>>
>>>> Even if we put the different table setup issue a side, I don't think it
>>>> would be correct for bridge/tc to remove rules they didn't add, which is
>>>> needed under your proposal when moving from legacy type rules to
>>>> offloads mode. Querying is problematic too, since legacy could (and
>>>> does) involve some default rules set by the FW, e.g that deals with
>>>> outer world (== not belonging to VM on this host) MACs which are
>>>> invisible to the driver.
>>> But even legacy mode should report the correct fdb table and setup.
>>> I don't think querying should be a problem if the driver reports the
>>> configuration correctly. This allows us visibility into the driver
>>> default case so we don't have to guess what driver X writer implemented.
>>>
>>>> That legacy was here and we can't avoid handling it properly for which
>>>> this knob is needed. Note that a vendor can choose to put their default
>>>> to be offloads, hopefully over time, we will all go there :)
>>>>
>>> But you can come up in legacy mode and report it via the existing
>>> mechanisms 'tc', 'bridge', etc. and then users can transition to any
>>> mode they like using the tools.
>>>
>>> I really don't think the switch here is necessary if you implement the
>>> bridge hooks and tc hooks. cls_u32 can handle this for example and I
>>> would expect flower can as well if you want to do mgmt via flow based
>>> tc commands. And the bridge tool has the attributes for per port
>>> flooding but not sure off-hand if its packed into the msg sent to the
>>> driver. But we could fix that fairly easily in another patch series if
>>> needed.
>>>
>> Actually with a bit more thought it might be nice to have a
>> flag to enable/disable creation of vf netdev representer in case it
>> somehow causes issues with existing software. We typically
>> enable/disable features with ethtool feature flags though not via
>> devlink so I think it would fit better as an ethtool flag same as
>> all the other hardware features.
> This is not a property of a netdevice, but a devlink device. That should
> be a handle of creating/not creating representors. And I think that what
> this patch is doing serves that purpose as well. For legacy mode, the
> representors are not created, for offload/switchdev mode they are
> created.

Even in legacy mode, i think there is a value in creating VP representor 
netdevs.
We are planning to expose VF statistics,  ntuple filters, additional 
fdb, vlan entries via this
netdev for VFs in the default mode.

Isn't it possible to switch to offloads mode by deleting the 'legacy' 
flow rules and
adding 'offloads' flow rules from userspace?


>
> Does not make sense to have this in ethtool one bit to me.
>
>
>> The above points in the last mail are more about how it influences the
>> forwarding rules in the switch and my preference would be that it
>> doesn't change how the forwarding works in the switch and instead the
>> forwarding state is managed via standard tools 'tc', 'bridge', etc. So
>> I think my comments are still relevant. However as long as when we
>> query the nic/switch we get the correct information back in any mode
>> I'm not too concerned I suspect any software that actually uses this
>> will have to query and reconfigure either way counting on driver
>> writers to get policy correct is not a stable way to write usermode
>> software.
>>
>> All that said I don't plan to change the forwarding state this way
>> with the intel drivers when implementing the vf representer.
>>
>> Yet another reason not to change the state of the forwarding rules is
>> even on older hardware that only supports l2 mac/vlan based forwarding
>> having a VF representer is useful to configure the device and send/recv
>> some basic control packets (e.g. lldp). On these devices l2 mac/vlan
>> mode is the only one supported.
>>
>>>>>> Otherwise I didn't review the mlx code but read the commit msgs and
>>>>>> it looks good. I'll take a closer look in the morning.
>>>> appreciated
>>>>
