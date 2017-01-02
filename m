From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon, 2 Jan 2017 14:58:06 -0800
Message-ID: <586ADAFE.1010105@gmail.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33794 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756381AbdABW6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:58:21 -0500
Received: by mail-pg0-f65.google.com with SMTP id b1so31556704pgc.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 14:58:21 -0800 (PST)
In-Reply-To: <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-02 02:21 PM, Jamal Hadi Salim wrote:
> On 17-01-02 01:23 PM, John Fastabend wrote:
> 
>>
>> Additionally I would like to point out this is an arbitrary length binary
>> blob (for undefined use, without even a specified encoding) that gets pushed
>> between user space and hardware ;) This seemed to get folks fairly excited in
>> the past.
>>
> 
> The binary blob size is a little strange - but i think there is value
> in storing some "cookie" field. The challenge is whether the kernel
> gets to intepret it; in which case encoding must be specified. Or
> whether we should leave it up to user space - in which something
> like tc could standardize its own encodings.
> 

Well having the length value avoids ending up with cookie1, cookie2, ...
values as folks push more and more data into the cookie.

I don't see any use in the kernel interpreting it. It has no use
for it as far as I can see. It doesn't appear to be metadata which
we use skb->mark for at the moment.

>> Some questions, exactly what do you mean by "port mappings" above? In
>> general the 'tc' API uses the netdev the netlink msg is processed on as
>> the port mapping. If you mean OVS port to netdev port I think this is
>> a OVS problem and nothing to do with 'tc'. For what its worth there is an
>> existing problem with 'tc' where rules only apply to a single ingress or
>> egress port which is limiting on hardware.
>>
> 
> In our case the desire is to be able to correlate for a system wide
> mostly identity/key mapping.
> 

The tuple <ifindex:qdisc:prio:handle> really should be unique why
not use this for system wide mappings?

The only thing I can think to do with this that I can't do with
the above tuple and a simple userspace lookup is stick hardware specific
"hints" in the cookie for the firmware to consume. Which would be
very helpful for what its worth.

>> The UFID in my ovs code base is defined as best I can tell here,
>>
>>         [OVS_FLOW_ATTR_UFID] = { .type = NL_A_UNSPEC, .optional = true,
>>                                  .min_len = sizeof(ovs_u128) },
>>
>> So you need 128 bits if you want a 1:1 mapping onto 'tc'. So rather
>> than an arbitrary blob why not make the case that 'tc' ids need to be
>> 128 bits long? Even if its just initially done in flower call it
>> flower_flow_id and define it so its not opaque and at least at the code
>> level it isn't an arbitrary blob of data.
>>
> 
> I dont know what this UFID is, but do note:
> The idea is not new - the FIB for example has some such cookie
> (albeit a tiny one) which will typically be populated to tell
> you who/what installed the entry.
> I could see f.e use for this cookie to simplify and pretty print in
> a human language for the u32 classifier (i.e user space tc sets
> some fields in the cookie when updating kernel and when user space
> invokes get/dump it uses the cookie to intepret how to pretty print).
> 
> I have attached a compile tested version of the cookies on actions
> (flat 64 bit; now that we have experienced the use when we have a
> large number of counters - I would not mind a 128 bit field).
> 

Its a bit strange to push it as an action when its not really an
action in the traditional datapath.

I suspect the OVS usage is a simple 1:1 lookup from OVS id to TC id to
avoid a userspace map lookup.

> 
> cheers,
> jamal
> 
>> And what are the "next" uses of this besides OVS. It would be really
>> valuable to see how this generalizes to other usage models. To avoid
>> embedding OVS syntax into 'tc'.
>>
>> Finally if you want to see an example of binary data encodings look at
>> how drivers/hardware/users are currently using the user defined bits in
>> ethtools ntuple API. Also track down out of tree drivers to see other
>> interesting uses. And that was capped at 64bits :/
>>
>> Thanks,
>> John
>>
>>
>>
>>
>>
> 
