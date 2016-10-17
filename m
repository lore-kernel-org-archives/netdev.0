From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
Date: Mon, 17 Oct 2016 06:10:23 -0400
Message-ID: <81e49d64-e0bc-2f43-7a9c-daefb12a4b8a@mojatatu.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <1476276069-5315-5-git-send-email-jiri@resnulli.us>
 <58025A90.9010608@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35023 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932687AbcJQKK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 06:10:27 -0400
Received: by mail-it0-f68.google.com with SMTP id 139so2888200itm.2
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 03:10:26 -0700 (PDT)
In-Reply-To: <58025A90.9010608@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some comments:
IIUC, the main struggle seems to be whether the redirect to dummy0
is useful or not? i.e instead of just letting the packets go up the
stack on eth1?
It seems like sflowd needs to read off eth1 via packet socket?
To be backward compatible - supporting that approach seems sensible.

Note:
There is a clear efficiency benefit of both using IFE encoding and
redirecting to dummy0.
1) Redirecting to dummy0 implies you dont need to exercise a bpf
filter around every packet that comes off eth1.
I understand there are probably not millions of pps for this case;
but in a non-offloaded cases it could be millions pps.
And in case of sampling over many ethx devices, you can redirect
samples from many other ethx devices.
So making dummy0 the sflow device is a win.
2) Encaping an IFE header implies a much more efficient bpf filter
(IFE ethertype is an excellent discriminator for bpf).

Additional benefit is as mentioned before - redirecting to a device
means you can send it remotely over ethernet to a more powerful
machine without having to cross kernel-userspace. Redirecting instead
of mirroring to tuntap is also an interesting option.

More comments below (on the sflow person's comment - dont seem him
on the Cc):

On 16-10-15 12:34 PM, Roopa Prabhu wrote:
> On 10/12/16, 5:41 AM, Jiri Pirko wrote:
>> From: Yotam Gigi <yotam.gi@gmail.com>


>> +
>> +struct sample_packet_metadata {
>> +	int sample_size;
>> +	int orig_size;
>> +	int ifindex;
>> +};
>> +
> This metadata does not look extensible.. can it be made to ?
>

Sure it can...

> With sflow in context, you need a pair of ifindex numbers to encode ingress and egress ports.

What is the use case for both?
> Ideally you would also include a sequence number and a count of the total number of packets
 > that were candidates for sampling.

Sequence number may make sense (they will help show a gap if something
gets dropped). But i am not sure about the stats consuming such space.
Stats are something that can be queried (tc stats should have a record
of how many bytes/packets )

>The OVS implementation is a good example, the metadata includes all the actions applied
>to the packet in the kernel data path.
>

Again not sure what the use case would be (and why waste such space
especially when you are sending over the wire with such details).

>> +	rcu_read_lock();
>> +	retval = READ_ONCE(s->tcf_action);
>> +
>> +	if (++s->packet_counter % s->rate == 0) {
>
> The sampling function isn’t random
>
> if (++s->packet_counter % s->rate == 0) {
>
> This is unsuitable for sFlow, which is specific about the random sampling function required.
>BPF, OVS, and the
> ULOG statistics module include efficient kernel based random sampling functions that could be used instead.
>

If i understood correctly, the above is a fallback sampling algorithm.
In the case of the spectrum it already does the sampling in the ASIC
so there is no need to repeat it in software.
Agreed that in that case the sampling approach is not sufficiently
random.

cheers,
jamal
