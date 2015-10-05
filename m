From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 00/14] rocker: add support for multiple worlds
Date: Mon, 05 Oct 2015 09:58:06 -0700
Message-ID: <5612AC1E.1050504@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <56129A32.1010201@gmail.com> <20151005163012.GO2278@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	idosch@mellanox.com, eladr@mellanox.com, tgraf@suug.ch,
	ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36263 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbbJEQ6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 12:58:21 -0400
Received: by pablk4 with SMTP id lk4so181096033pab.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 09:58:20 -0700 (PDT)
In-Reply-To: <20151005163012.GO2278@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-05 09:30 AM, Jiri Pirko wrote:
> Mon, Oct 05, 2015 at 05:41:38PM CEST, john.fastabend@gmail.com wrote:
>> On 15-10-04 02:25 PM, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> This patchset allows new rocker worlds to be easily added in future (like eBPF
>>> based one I have been working on). The main part of the patchset is the OF-DPA
>>> carve-out. It resuts in OF-DPA specific file. Clean cut.
>>> The user is able to change rocker port world/mode using rtnl.
>>>
>>
>> Hi Jiri,
>>
>> I'm not sure I understand the motivation here. Are you thinking the
>> "real" drivers will start to load worlds or what I've been calling
>> profiles on the devices I have here. If this is the case using
>> opaque strings without any other infrastructure around it to expose
>> what the profile is doing is not sufficient in my opinion. What I
>> would rather have is for drivers to expose the actual configuration
>> parameters they are using, preferable these would be both readable
>> and writable so we don't end up with what the firmware/device driver
>> writers think is best. I think we can get there by exposing a model
>> of the device and configuring "tables". I'll post my latest patch
>> set today to give you a better idea what I'm thinking here. Without
>> this I guess you will end up with drivers creating many profiles and
>> in no consistent way so you end up with here is my "vxlan" profile,
>> here is my "geneve" profile, here is my "magic-foo" profile, etc. I
>> wanted to avoid this.
> 
> This is just for rocker purposes. I do not want to do something similar
> for real devices. It does not make sense as real hw always have some
> hard-wired topology. Rocker HW does not. I think that this is the main
> part that may cause some misunderstandings.

I think your underestimating the flexibility of hardware. And
completely missing the hardware that is based on FPGAs and/or cell
architectures. This hardware is available today and could support
topology changes like this. But even less exotic hardware can/will
support parser updates which makes the device behave differently.

Other hardware can reconfigure the topology within some constraints,
the fm10k device supports this model. An extreme example would put
an ebpf interpreter in a fpga on the nic and expose it via a driver.

If its just for rocker purposes I'm not really excited about adding
it to the kernel to support a qemu device. If we allow it for one
driver I don't see how/why we should block it for "real" devices.
>From the kernels point of view these are all real drivers. I could
build a qemu model that maps 1:1 with real hardware and do a drop
in replacement.

> 
> Rocker has a notion of "worlds". When a port is set to be in a certain
> world, it behaves in completely different way. Now we have just OF-DPA
> world. I will be adding BPF world shortly.
> 
> This has nothing to do with profiles as you describe it, this is
> something completely different!
> 
> 

I'm missing why its different.

Would you object to me adding multiple worlds to fm10k
using opaque strings? I'll create a world with a topology that maps
well to ipv4 networks, a world for ipv6 networks, a world for l2 flat
networks, etc. Each world in this example will have a specific table
topology and parser to support it. In this sense the ports will behave
in completely different ways i.e. packets will be processed by
different pipelines. Are you suggesting we do this?

I'm not sure what you mean by completely different? Is it just a
different parser and table topology? Real hardware can support changing
or at least modifying these today.

>>
>> But if this is only meant to be a rocker thing then why expose it on
>> the driver side vs just compiling it on the qemu side? If its just
> 
> I want user to be able to set the world/mode of the port on fly. No need to
> re-set the hardware if possible to do it from driver.
> 

But the user has no way to know what these strings are doing?

> 
>> for convenience and only meant for the emulated device we should be
>> clear in the documentation and patch set.
> 
> This is rocker-only patchset, where do you want to clear it?
> 

I don't think this is reasonable from the kernel side to "know" or
expose a driver is running on qemu like this. The kernel shouldn't
know or care if a device is emulated or not.

> 
>>
>> Final, comment can we abstract the interfaces better? An L2 and L3
>> table could be mapped generically onto a table pipeline model if the
>> driver gave some small hints like this is my l2 table and this is my l3
>> table. Then you don't need all the world specific callbacks and the
>> OF-DPA model just looks like an instance of a pipeline with some
>> specific hints where to put l2/l3 rules.
> 
> I think you are missing something, or I am. How do you map BPF world
> pipeline into tables? The idea of the worlds is to do *completely*
> different HW implementation, not just rewire some pre-defined tables.
> For BPF world, there will be just BPF interpreter sitting inside HW
> and running arbitrary code, no tables.

hmm I need to document the prototype we have. I'll put that on my
list to do.

What we did is used "maps" to add the rules and then put a BPF
classifier in front of them that selects a rule in the map.

Maybe I need to see your code but if your pushing l2/l3 rules down
those need to interact with a table I presume? At least this seems
to be the most natural way. If your not pushing rules I'm not sure
how you do L3 routing? maybe you only support l2 leaning.

> 
> 
>>
>> Like I said I'll send some patches, they will be a bit rough and
>> against fm10k driver. I'll just send out what I have end of day here.
> 
> Your patchset sounds totally unrelated to this one. Let's make that clear.
> 

Its related in that if you expose your device model you do not need
opaque strings to do wholesale reconfiguration of the device. Instead
if the parts of the device that are configurable are exposed to the
user they can build the "world" they want.

.John
