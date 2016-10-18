From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
Date: Mon, 17 Oct 2016 17:17:12 -0700
Message-ID: <58056A08.5070809@cumulusnetworks.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us> <1476276069-5315-5-git-send-email-jiri@resnulli.us> <58025A90.9010608@cumulusnetworks.com> <81e49d64-e0bc-2f43-7a9c-daefb12a4b8a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33594 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754397AbcJRARP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 20:17:15 -0400
Received: by mail-pf0-f171.google.com with SMTP id 128so85436459pfz.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 17:17:15 -0700 (PDT)
In-Reply-To: <81e49d64-e0bc-2f43-7a9c-daefb12a4b8a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/16, 3:10 AM, Jamal Hadi Salim wrote:
>
> Some comments:
> IIUC, the main struggle seems to be whether the redirect to dummy0
> is useful or not? i.e instead of just letting the packets go up the
> stack on eth1?

yep, correct...given existing workflow for the non-offloaded case is
to receive sample packets via bpf filter on socket or
use netlink as a sample delivery mechanism (NFLOG eg)


> It seems like sflowd needs to read off eth1 via packet socket?
> To be backward compatible - supporting that approach seems sensible.
>
> Note:
> There is a clear efficiency benefit of both using IFE encoding and
> redirecting to dummy0.
> 1) Redirecting to dummy0 implies you dont need to exercise a bpf
> filter around every packet that comes off eth1.
> I understand there are probably not millions of pps for this case;
> but in a non-offloaded cases it could be millions pps.
> And in case of sampling over many ethx devices, you can redirect
> samples from many other ethx devices.
> So making dummy0 the sflow device is a win.
> 2) Encaping an IFE header implies a much more efficient bpf filter
> (IFE ethertype is an excellent discriminator for bpf).
>
> Additional benefit is as mentioned before - redirecting to a device
> means you can send it remotely over ethernet to a more powerful
> machine without having to cross kernel-userspace. Redirecting instead
> of mirroring to tuntap is also an interesting option.

sure, this seems like a good option to have.
generally you have one instance of the sampling agent on a hyper visor or switch.
But, if you have use-cases where monitoring agents run external, sure.
would have preferred if it was optional or an addon and not the default.

Regarding the device, yeah, agree there are pros and cons.
An additional device just to sample packets seems like an overkill.
But, if there is no other other option, and there are benefits to it, no objections.
Hopefully we can add another option on the existing api to skip the device in the future.


>
>
> On 16-10-15 12:34 PM, Roopa Prabhu wrote:
>> On 10/12/16, 5:41 AM, Jiri Pirko wrote:
>>> From: Yotam Gigi <yotam.gi@gmail.com>
>
>
>>> +
>>> +struct sample_packet_metadata {
>>> +    int sample_size;
>>> +    int orig_size;
>>> +    int ifindex;
>>> +};
>>> +
>> This metadata does not look extensible.. can it be made to ?
>>
>
> Sure it can...
>
>> With sflow in context, you need a pair of ifindex numbers to encode ingress and egress ports.
>
> What is the use case for both?

I have heard that most monitoring tools have moved to ingress only sampling because of operational
complexity (use case is sflow). I think hardware also supports ingress and egress only sampling.
better to have an option to reflect that in the api.

>> Ideally you would also include a sequence number and a count of the total number of packets
> > that were candidates for sampling.
>
> Sequence number may make sense (they will help show a gap if something
> gets dropped). But i am not sure about the stats consuming such space.
> Stats are something that can be queried (tc stats should have a record
> of how many bytes/packets )

sure, thats fine.
>
>> The OVS implementation is a good example, the metadata includes all the actions applied
>> to the packet in the kernel data path.
>>
>
> Again not sure what the use case would be (and why waste such space
> especially when you are sending over the wire with such details).

All this is being used currently.., But, this can be other api's sflow uses
for monitoring.
http://openvswitch.org/support/ovscon2014/17/1400-ovs-sflow.pdf

Does not have to be part of the main/basic sampling api...
it was just an example.

>
>>> +    rcu_read_lock();
>>> +    retval = READ_ONCE(s->tcf_action);
>>> +
>>> +    if (++s->packet_counter % s->rate == 0) {
>>
>> The sampling function isn’t random
>>
>> if (++s->packet_counter % s->rate == 0) {
>>
>> This is unsuitable for sFlow, which is specific about the random sampling function required.
>> BPF, OVS, and the
>> ULOG statistics module include efficient kernel based random sampling functions that could be used instead.
>>
>
> If i understood correctly, the above is a fallback sampling algorithm.
> In the case of the spectrum it already does the sampling in the ASIC
> so there is no need to repeat it in software.
> Agreed that in that case the sampling approach is not sufficiently
> random.

yes. and since the same sampling api will be used for offloaded and non-offloaded case,
the sampling algo here for the non-offloaded case...can do better .. atleast match the existing
api efficiency. We would want people to use the same api for the offload and non-offloaded case.

thanks,
Roopa
