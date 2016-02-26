From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC 3/3] net: convert tc_u32 to use the intermediate representation
Date: Fri, 26 Feb 2016 08:34:49 -0800
Message-ID: <56D07EA9.5030502@gmail.com>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org> <1456421844-5901-4-git-send-email-pablo@netfilter.org> <56CF6612.6040900@gmail.com> <20160226142402.GB2523@salvia> <56D066D7.2090708@gmail.com> <20160226160222.GA4499@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	horms@verge.net.au
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35051 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbcBZQfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 11:35:03 -0500
Received: by mail-pa0-f41.google.com with SMTP id ho8so54954646pac.2
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 08:35:03 -0800 (PST)
In-Reply-To: <20160226160222.GA4499@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-26 08:02 AM, Pablo Neira Ayuso wrote:
> On Fri, Feb 26, 2016 at 06:53:11AM -0800, John Fastabend wrote:
>> On 16-02-26 06:24 AM, Pablo Neira Ayuso wrote:
>>> On Thu, Feb 25, 2016 at 12:37:38PM -0800, John Fastabend wrote:
>>>> On 16-02-25 09:37 AM, Pablo Neira Ayuso wrote:
>>>>> This patch moves the u32 parser from the ixgbe that John has made to the
>>>>> core u32. This parser has been adapted to build the intermediate
>>>>> representation.
>>>>>
>>>>> To store the parsing information, this patch introduces a parse table
>>>>> object, one per device, so we don't need to store the parsing states in
>>>>> the adapter, which is the major dependency with previous patches.
>>>>>
>>>>> Since u32 allows rules connected via links, the u32 parser tracks this
>>>>> links and then generates the intermediate representation that is passed
>>>>> to the ixgbe driver.
>>>>
>>>> It also supports hash tables and loops.
>>>
>>> Then, it is a matter of extending the tc-u32 parser and the IR to
>>> support whatever you need.
>>
>> sure but its easier for me to just consume u32 at the moment. And I
>> am concerned about performance overhead with this IR. I'm going to need
>> to have a performant solution eventually and I don't like converting
>> into one IR only to go into another.
> 
> Just because you want to early microoptimize this thing by saving a
> little of extra code that runs from the control plane path.

But the entire parser + hardware setup is only 149 lines of code plus
a header file. And 45 lines of it hardware specific code and 15 lines
of it are comments. So the entire piece that takes u32 to hardware is
less than 100 lines of code. I'm going to take that block of code and
share it across all my drivers and just write models for each one. After
I make some firmware changes I'll just read the model in from the
firmware and I wont even need that piece. If/when other driver writers
want to use that core loop I created I'll lift it into some helper
routine anyone can call.

I'll do the flower classifier with a static map from keys to u32 if
folks think that is valuable. And that will only be a handful of lines
of code.

So I guess your right I'm not arguing so much against some IR if its
warranted just that the IR proposed here with AST and all seems
unnecessary for offloading front-ends that are so simple when I have
one more or less already. It seems to push the notion of an AST from
nft onto 'tc' which IMO has no need for it.

> 
>>>>> New drivers will only have to implement the jit translation code based
>>>>> on the intermediate representation. With some extra work, I think it
>>>>> should be possible to generalize the existing tc specific ndo action so
>>>>> it can be used by other frontends.
>>>>>
>>>>> I tried to stick to John's original u32 frontend parser as much as
>>>>> possible, adapting it to build the intermediate representation.
>>>>>
>>>>> After this change, we don't expose the tc action structure layout and
>>>>> other similar frontend details to the backend anymore to the backend
>>>>> anymore. I think this is good since changes in the frontend should not
>>>>> need to be propagated to the 1..n drivers supporting u32 offloads. In
>>>>> that sense, this helps to keep the frontend software representation
>>>>> separated from low-level backend driver details.
>>>>>
>>>>> After this patch, it should be possible to put the tc_cls_u32_knode
>>>>> structure into diet since we only need the handle (as unique id) and the
>>>>> ast tree.
>>>>>
>>>>
>>>> On ixgbe this is true but going forward I can support hash functions
>>>> so you need the divisor, prio, and handle minimally. I'm not sure how
>>>> to do hash tables for example in this IR yet. Might be there I'm still
>>>> trying to grok the IR details.
>>>
>>> We just need a description with the list elements that you want to
>>> place in the hashtable.
>>>
>>> The matching can be expressed in ast by adding a list of elements that
>>> are part of the hashtable:
>>>
>>>                  relational
>>>                     / \
>>>                    /   \
>>>                   /     \
>>>            payload      list of elements
>>>   (offset, base, len)       |
>>>                             \
>>>                              --> e1 --> e2 --> ... --> en
>>
>> Sure it can be done but taking the u32 directly and flower directly is
>> so easy I don't see the need for the complexity.
> 
> You prefer to push the complexity on the driver side. Then, the
> complexity will spread all over the place.

As I noted above the complexity is small.

> 
>>>>> I couldn't send any more incremental changes to update previous work
>>>>> since the u32 parser and the internal representation were put together,
>>>>> that why this patch is slightly large.
>>>>>
>>>>> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>>>>> ---
>>>>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   4 -
>>>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 216 ++++++++--------
>>>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 112 --------
>>>>>  include/net/pkt_cls.h                          |   3 +
>>>>>  net/sched/cls_u32.c                            | 344 +++++++++++++++++++++++++
>>>>
>>>> Feels like a lot of code to me when the original direct u32 to hw
>>>> was reasonably small and the flower implementation is small as well.
>>>
>>> This is your tc-u32 parser plus simple boiler plate code to build the
>>> IR that will be common to everyone. Without this, other drivers will
>>> have to track u32 links and so on.
>>
>> But you lost the model piece which allows me to easily change the
>> hardware underneath the driver.
> 
> You want to hide hardware capabilities behind that model.

No the capabilities are there read the model file. And u32 supports
arbitrary offset:value:mask pairs the file is just exposing the
capabilities in a somewhat general form for devices that are less
flexible and can not consume arbitrary tuples.

Not trying to hide anything... but I don't want to recompile my
kernel just because some user creates a new header type or field.

Anwyays it is sort of independent of IR or not. But I noted it because I
don't want to see things like match ipv4 field X this is a step
backwards.

> 
>>> Other than that, we'll end up with 1..N different u32 parsers in the
>>> backend.
>>
>> well if folks like the way I wrote the u32 parser we could standardize
>> the model and header for u32 and give them helper functions.
> 
> I see, so now you agree with me that the u32 parser should be moved to
> the core, that's good.

Sure as I noted above I am more arguing that the AST IR proposed here is
a bit more than is needed for tc. And seems to be driven entirely by
nft and as I sort of refine my thinking around this through
this thread I'm not sure we need to unify nft/tc at the bottom of the
stack. If nft needs a AST object that is one thing but its not needed
to get tc into the hardware.

Further I've only implemented a single driver at this point so I don't
have anything to actually use a IR as I write the next driver I'll
load the u32 parser and pieces into the core where they are helpful.
This seems pragmatic to me vs building something that has no users yet.

> 
>> But by writing your own model you can optimize it.
> 
> I see, but you mean you keep using this ugly IR representation:
> 
>  struct tc_cls_u32_knode {
>         struct tcf_exts *exts;
>         struct tc_u32_sel *sel;
>         u32 handle;
>         u32 val;
>         u32 mask;
>         u32 link_handle;
>         u8 fshift;
>  };

Yep, but I don't think its so ugly and its simple, easy to understand,
and easy to translate into hardware and to/from the tc frontends.

> 
> that exposes the tc frontend details. Sorry, but this is not nice.
> 

meh pragmatically it works and is easy to translate into and out of.
So rename the structures if that helps. Call it struct tc_actions and
struct tc_selectors.

>> Anyways at the moment it looks like we will only have two the Intel
>> and mlx ones I haven't seen anyone else working on this yet.
> 
> I don't see any convincing argument so far to stick to your approach
> and not to use some kind of generic IR.
> 
> And even if you have concerns on the generic IR, you can propose
> amendments for it to improve it since that would be core
> infrastructure.
> 

If we insist on IR I would either like to use a tc-IR that is basically
what I have today. Or really create a generic IR using eBPF so that I
don't have two. This AST thing feels like lots of complexity for no
good reason. But I don't see any reason to do this until I implement
my next driver where I can use the IR. So I'm going to start working
on the i40e driver soon and can add it then when its needed.

[...]

>>
>> Its a firmware/ucode update we do this already today and the
>> infrastructure to do it has been in the kernel for a long time.
>> Firmware has always been a binary blob it has to be. All this means is
>> we have to read the parser out at init() time of the driver instead of
>> using a static model.h header. Hardware is not going to be static
>> anymore.
>>
>> Even if its based on the device ID its the same problem I wouldn't
>> want a bunch of if (device X) do this else (device y) do that and
>> so on.
> 
> That is code that you can keep in your driver side. I don't think
> that's a argument not to have a consolidated infrastructure that is
> better for everyone.
> 

I think you are right my comment was something of a false argument it
is sort of independent of if you have an IR or not. It just points out
your translation of my ixgbe code was not optimal in my opinion an
really says nothing about your IR.

>>> I don't think this is the way to go.
>>>
>>>> [...]
>>>>
>>>>>  static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
>>>>>  				  __be16 protocol,
>>>>>  				  struct tc_cls_u32_offload *cls)
>>>>>  {
>>>>>  	u32 loc = cls->knode.handle & 0xfffff;
>>>>>  	struct ixgbe_hw *hw = &adapter->hw;
>>>>> -	struct ixgbe_mat_field *field_ptr;
>>>>>  	struct ixgbe_filter f;
>>>>> -#ifdef CONFIG_NET_CLS_ACT
>>>>> -	const struct tc_action *a;
>>>>> -#endif
>>>>> -	int i, err = 0;
>>>>> +	int err = 0;
>>>>>  	u32 handle;
>>>>>  
>>>>>  	memset(&f.mask, 0, sizeof(union ixgbe_atr_input));
>>>>>  	handle = cls->knode.handle;
>>>>>  
>>>>> -	/* At the moment cls_u32 jumps to transport layer and skips past
>>>>> -	 * L2 headers. The canonical method to match L2 frames is to use
>>>>> -	 * negative values. However this is error prone at best but really
>>>>> -	 * just broken because there is no way to "know" what sort of hdr
>>>>> -	 * is in front of the transport layer. Fix cls_u32 to support L2
>>>>> -	 * headers when needed.
>>>>> -	 */
>>>>> -	if (protocol != htons(ETH_P_IP))
>>>>
>>>> This was hardcoded originally just to find the inital offset going
>>>> forward I want to patch u32 to start at the link layer to avoid
>>>> this.
>>>
>>> Then, you extend the tc-u32 parser, but from the frontend core
>>> infrastructure code, so everyone we'll benefit for this incremental
>>> update.
>>
>> We will push these patches into u32 anyways and it doesn't need the IR
>> to benefit everyone.
> 
> I see, now you're convinced to push the tc-u32 parser to the core
> infrastructure.

Yep I'm convinced plus I need to enable other drivers. By and large
I'm more arguing over what IR I guess. I want a light-weight simple
one and you propose something a bit heavier in my opinion.

> 
>>>> [...]
>>>>
>>>>> -		if (!found_entry)
>>>>> -			goto err_out;
>>>>> -	}
>>>>> +	if (net_ir_jit(&cls->knode.ast, &ixgbe_desc, &f) < 0)
>>>>> +		return -EINVAL;
>>>>>  
>>>>
>>>> OK but this takes a cls_u32 offload engine that was running on a handful
>>>> of LOC + a header file description that in the future will be read out
>>>> of firmware and replaces it with an entire infrastructure. I'm not
>>>> convinced the added complexity is worth it.
>>>
>>> It's all about consolidating infrastructure.
>>>
>>
>> sure I just think we are getting ahead of ourselves here and
>> consolidating a single driver and single classifier and creating a lot
>> of code along the way when the current implementation is simple IMO with
>> this I have to follow an AST and pointers and a bunch of allocs. As the
>> guy writing the driver I see no need for it yet.
> 
> This is not creating a lot of code.
> 
> My patch is basically moving your u32 parser into the core, this is
> probably the largest piece of code in this patchset.
> 
> The remaining bits are just a simple infrastructure to build an AST
> and walk over it.
> 
> $ wc -l net/core/ir.c
> 273 net/core/ir.c

OK but why do we need the AST at all? It isn't needed. Why not just take
what we have and literally move it into a core structure?

> 
>>>> [...]
>>>>
>>>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
>>>>> +++ /dev/null
>>>>> @@ -1,112 +0,0 @@
>>>>> -/*******************************************************************************
>>>>> - *
>>>>> - * Intel 10 Gigabit PCI Express Linux drive
>>>>> - * Copyright(c) 2016 Intel Corporation.
>>>>> - *
>>>>> - * This program is free software; you can redistribute it and/or modify it
>>>>> - * under the terms and conditions of the GNU General Public License,
>>>>> - * version 2, as published by the Free Software Foundation.
>>>>> - *
>>>>> - * This program is distributed in the hope it will be useful, but WITHOUT
>>>>> - * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
>>>>> - * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
>>>>> - * more details.
>>>>> - *
>>>>> - * You should have received a copy of the GNU General Public License along
>>>>> - * with this program.  If not, see <http://www.gnu.org/licenses/>.
>>>>> - *
>>>>> - * The full GNU General Public License is included in this distribution in
>>>>> - * the file called "COPYING".
>>>>> - *
>>>>> - * Contact Information:
>>>>> - * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
>>>>> - * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
>>>>> - *
>>>>> - ******************************************************************************/
>>>>> -
>>>>> -#ifndef _IXGBE_MODEL_H_
>>>>> -#define _IXGBE_MODEL_H_
>>>>> -
>>>>> -#include "ixgbe.h"
>>>>> -#include "ixgbe_type.h"
>>>>> -
>>>>> -struct ixgbe_mat_field {
>>>>> -	unsigned int off;
>>>>> -	unsigned int mask;
>>>>> -	int (*val)(struct ixgbe_fdir_filter *input,
>>>>> -		   union ixgbe_atr_input *mask,
>>>>> -		   u32 val, u32 m);
>>>>> -	unsigned int type;
>>>>> -};
>>>>
>>>> As noted above the intent is to make the parser programmable so
>>>> something like this model needs to exist for firmware to populate.
>>>
>>> Oh, again references to update via firmware.
>>>
>>> [...]
>>>> My preference is to hold this work until we get a few more driver
>>>> implementation for multiple things and see if that can scale easily
>>>> as I suspect it might without having to over-engineer it.
>>>
>>> I don't agree, that's simply preventing by now other frontends and
>>> drivers to get offload support.
>>
>> I don't think so at all. The driver support is simple at the moment
>> and the interface is still evolving in the frontend. What is this
>> preventing now? I can submit my flower implementation but the mlx folks
>> wanted to do it. The other concern about performance is also a big
>> one for me. And the AST as it is doesn't solve my eBPF case either so
>> maybe we should just lower everything to eBPF and have one IR instead
>> of two if we really want a universal IR.
> 
> I think you can push a restricted version of eBPF, the frontend parser
> won't be nice given that it will have to deal with all its complexity
> (compared to the smaller complexity of other existing frontends).
> AFAIK, there is no hardware fully supporting eBPF but some
> variants/limited versions of bpf-like things, and I don't know of any
> standarization effort on this from vendors. So to me you're worring on
> things that don't exist yet.
> 

Well they exist but don't have a Linux implementation because we haven't
built one yet. But I think I agree it might be worth keeping ebpf
separate for now.

Thanks,
John
