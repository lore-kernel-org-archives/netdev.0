From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 12:03:49 -0500
Message-ID: <52FA57F5.3080400@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F7D7EE.7010302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	vyasevic@redhat.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:48338 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbaBKRDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:03:52 -0500
Received: by mail-ie0-f172.google.com with SMTP id u16so371653iet.31
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 09:03:52 -0800 (PST)
In-Reply-To: <52F7D7EE.7010302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/14 14:33, John Fastabend wrote:
> On 02/09/2014 07:06 AM, Jamal Hadi Salim wrote:

>
>> +    if (ndm->ndm_ifindex) {
>> +        dev = __dev_get_by_index(net, ndm->ndm_ifindex);
>> +        if (dev == NULL) {
>> +            pr_info("PF_BRIDGE: RTM_GETNEIGH with unknown ifindex\n");
>> +            return -ENODEV;
>> +        }
>> +
>> +        if (!(dev->priv_flags & IFF_EBRIDGE)) {
>
> Can we drop this 'if case' and just use the 'if (ops->ndo_fdb_dump)'
> below? IFF_EBRIDGE is specific to ./net/bridge so it will fail for
> macvlans and I think the command is useful in both cases.
>

My only worry is:
The target ndm_ifindex is to a bridge device i.e something
that has an "fdb" (user space says "br X" then we use X to
mean we are talking about a bridge device. This is what
brctl showmacs <X> means.
I know this doesnt seem right relative to current point of
view where the target is the bridge port ifindex.
I'd be more than happy to make the change if it makes sense,
but i am struggling with that thought.

>
>> +            pr_info("PF_BRIDGE: RTM_GETNEIGH %s not a bridge device\n",
>> +                dev->name);
>> +            return -EINVAL;
>>          }
>> +        ops = dev->netdev_ops;
>> +        if (ops->ndo_fdb_dump) {
>> +            idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
>> +        } else {
>
> Is there any problem with using the ndo_dflt_fdb_dump() in the else
> here?
>

If the assumption is the target ifindex is to a bridge device, I would
expect it MUST have a ops->ndo_fdb_dump(), no?
the default dumper deals with bridge ports (which may be bridges, but
if i wanted their databases i would address them)

> Userspace should be able to easily learn which ports are ebridge ports
> so I don't think that should be an issue. Anyways with the above
> IFF_EBRIDGE check you should never hit this else case although I think
> its safe to drop the above check as noted.
>

Right - so if i can find out which is an ebridge i can send it the
same request.

cheers,
jamal
