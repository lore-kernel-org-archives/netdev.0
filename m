From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon, 2 Jan 2017 10:23:27 -0800
Message-ID: <586A9A9F.4030002@gmail.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34873 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756508AbdABSXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 13:23:43 -0500
Received: by mail-pg0-f65.google.com with SMTP id i5so31071262pgh.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 10:23:42 -0800 (PST)
In-Reply-To: <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-02 06:59 AM, Jamal Hadi Salim wrote:
> 
> We have been using a cookie as well for actions (which we have been
> using but have been too lazy to submit so far). I am going to port
> it over to the newer kernels and post it.
> In our case that is intended to be opaque to the kernel i.e kernel
> never inteprets it; in that case it is similar to the kernel
> FIB protocol field.
> 
> In your case - could this cookie have been a class/flowid
> (a 32 bit)?
> And would it not make more sense for it the cookie to be
> generic to all classifiers? i.e why is it specific to flower?
> 
> cheers,
> jamal
> 
> On 17-01-02 08:13 AM, Paul Blakey wrote:
>> This is to support saving extra data that might be helpful on retrieval.
>> First use case is upcoming openvswitch flow offloads, extra data will
>> include UFID and port mappings for each added flow.
>>
>> Signed-off-by: Paul Blakey <paulb@mellanox.com>
>> Reviewed-by: Roi Dayan <roid@mellanox.com>
>> Acked-by: Jiri Pirko <jiri@mellanox.com>
>> ---

Additionally I would like to point out this is an arbitrary length binary
blob (for undefined use, without even a specified encoding) that gets pushed
between user space and hardware ;) This seemed to get folks fairly excited in
the past.

Some questions, exactly what do you mean by "port mappings" above? In
general the 'tc' API uses the netdev the netlink msg is processed on as
the port mapping. If you mean OVS port to netdev port I think this is
a OVS problem and nothing to do with 'tc'. For what its worth there is an
existing problem with 'tc' where rules only apply to a single ingress or
egress port which is limiting on hardware.

The UFID in my ovs code base is defined as best I can tell here,

        [OVS_FLOW_ATTR_UFID] = { .type = NL_A_UNSPEC, .optional = true,
                                 .min_len = sizeof(ovs_u128) },

So you need 128 bits if you want a 1:1 mapping onto 'tc'. So rather
than an arbitrary blob why not make the case that 'tc' ids need to be
128 bits long? Even if its just initially done in flower call it
flower_flow_id and define it so its not opaque and at least at the code
level it isn't an arbitrary blob of data.

And what are the "next" uses of this besides OVS. It would be really
valuable to see how this generalizes to other usage models. To avoid
embedding OVS syntax into 'tc'.

Finally if you want to see an example of binary data encodings look at
how drivers/hardware/users are currently using the user defined bits in
ethtools ntuple API. Also track down out of tree drivers to see other
interesting uses. And that was capped at 64bits :/

Thanks,
John
