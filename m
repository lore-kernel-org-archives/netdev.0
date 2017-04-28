From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: xdp_redirect ifindex vs port. Was: best API for returning/setting
 egress port?
Date: Fri, 28 Apr 2017 21:43:36 +0200
Message-ID: <dd965e88-b9fd-4d58-4272-07588b842252@stressinduktion.org>
References: <58F7E9F3.5090604@iogearbox.net>
 <20170420025611.GA53935@ast-mbp.thefacebook.com>
 <20170420081051.77a41aa8@redhat.com>
 <20170420171006.GA97067@ast-mbp.thefacebook.com>
 <20170425113453.5c72080f@redhat.com>
 <20170426002610.eihwmz4knbmrolfw@ast-mbp.dhcp.thefacebook.com>
 <59000EF6.1050204@gmail.com> <20170426111158.578b925e@redhat.com>
 <5900CC41.2070502@gmail.com> <c9b3ff9b-8938-3274-da29-c04f9da2a314@fb.com>
 <20170426205544.GA40859@C02RW35GFVH8> <20170427104121.32df2178@redhat.com>
 <53e9dd2f-f40a-b43b-99c9-62f5ce3a665c@fb.com> <5902CDC5.5010209@gmail.com>
 <b15f490d-5490-e309-9626-d35b8e932483@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53901 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753774AbdD1Tnl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:43:41 -0400
In-Reply-To: <b15f490d-5490-e309-9626-d35b8e932483@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.04.2017 07:30, Alexei Starovoitov wrote:
> On 4/27/17 10:06 PM, John Fastabend wrote:
>> That is more or less what I was thinking as well. The other question
>> I have though is should we have a bpf_redirect() call for the simple
>> case where I use the ifindex directly. This will be helpful for taking
>> existing programs from tc_cls into xdp. I think it makes sense to have
>> both bpf_tx_allports(), bpf_tx_port(), and bpf_redirect().
> 
> I think so too.
> Once netdevice is stored into netdev_array map the netdevice is pinned
> and we need to figure out what to do if somebody tries to delete it.
> Should we add a new netlink notifier that this netdev's refcnt is
> almost zero and it's only in netdev_array(s) ?

We basically do that automatically in netdev_wait_allrefs:

pr_emerg("unregister_netdevice: waiting for %s to become free. Usage
count = %d\n",
         dev->name, refcnt);

It is a very unpleasant warning and users probably think about a bug in
the kernel at first.

I don't think we should wait for user space to clean that up but have to
do it automatically from the kernel. Maybe we can introduce a special
value that basically NOPs the transmission. The hash table itself would
install a netdevice notifier and would clean all tables. Could
definitely cause some storm in the kernel, if a lot of keys are mapped
to the same interface.

> or should it be deleted from the array(s) automatically and
> then user space will be notified post-deletion?
> Both approaches have their pros and cons.

I am leaning more towards deleting it automatically. But walking all
tables and in there all keys might cause some unwanted load spikes.

> Whereas raw ifindex approach (via bpf_redirect) doesn't have these
> caveats. It's clear to both bpf prog and user space that ifindex
> can be stale and user space needs to monitor netdevs and update
> programs/maps.

A separate type for ifindex as key or value might be nice to expose this
information directly via the kernel (fdinfo etc.) but at the same time,
debugging infrastructure from user space can also easily deal with that.

Another approach would be:

ifindexes are allocated cyclic and also are signed int and not u32
during allocation. Maybe we can negate the ifindex during transmission
in the table and thus mark it as stale (or set it to -1)? This update
would be done by bpf_tx_*ports() that take a reference to a table and a
key and submit the packets on the appropriate ports and can flag the
relevant ifindexes as stale.

Just wanted to draft this idea, I am not particular happy with that
idea. Maybe someone comes up with a better one.

Thanks,
Hannes
