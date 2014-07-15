From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 01/11] openvswitch: Allow each vport to have
 an array of 'port_id's.
Date: Tue, 15 Jul 2014 11:16:01 -0700
Message-ID: <CALnjE+qFW=4A24N=tbLei-3A3JO=qW2GWJvfJPJiwUCfLehpQQ@mail.gmail.com>
References: <1405444476-16867-1-git-send-email-pshelar@nicira.com>
	<53C56558.5090404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alex Wang <alexw@nicira.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:58758 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752536AbaGOSQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 14:16:03 -0400
Received: by mail-vc0-f175.google.com with SMTP id hu12so5942942vcb.34
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 11:16:01 -0700 (PDT)
In-Reply-To: <53C56558.5090404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 10:31 AM, Nikolay Aleksandrov
<nikolay@redhat.com> wrote:
> <snip>
>> +/**
>> + *   ovs_vport_set_upcall_portids - set upcall portids of @vport.
>> + *
>> + * @vport: vport to modify.
>> + * @ids: new configuration, an array of port ids.
>> + *
>> + * Sets the vport's upcall_portids to @ids.
>> + *
>> + * Returns 0 if successful, -EINVAL if @ids is zero length or cannot be parsed
>> + * as an array of U32.
>> + *
>> + * Must be called with ovs_mutex.
>> + */
>> +int ovs_vport_set_upcall_portids(struct vport *vport,  struct nlattr *ids)
>> +{
>> +     struct vport_portids *old, *vport_portids;
>> +
>> +     if (!nla_len(ids) || nla_len(ids) % sizeof(u32))
>> +             return -EINVAL;
>> +
>> +     old = ovsl_dereference(vport->upcall_portids);
>> +
>> +     vport_portids = kmalloc(sizeof(*vport_portids) + nla_len(ids),
>> +                             GFP_KERNEL);
> ^^^^^^^
> Shouldn't there be a null check after the kmalloc instead of directly
> dereferencing vport_portids ?
>
right, I will update the patch.

>> +     vport_portids->n_ids = nla_len(ids) / sizeof(u32);
>> +     vport_portids->rn_ids = reciprocal_value(vport_portids->n_ids);
>> +     nla_memcpy(vport_portids->ids, ids, nla_len(ids));
>> +
>> +     rcu_assign_pointer(vport->upcall_portids, vport_portids);
>> +
>> +     if (old)
>> +             call_rcu(&old->rcu, vport_portids_destroy_rcu_cb);
>> +
>> +     return 0;
>> +}
> <snip>
>
