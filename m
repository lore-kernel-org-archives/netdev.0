From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Mon, 16 Nov 2009 09:02:32 -0800
Message-ID: <65634d660911160902t677a4fb4r71602cb0d10f1cce@mail.gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	 <87hbt0kaae.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:15767 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbZKPRCc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 12:02:32 -0500
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id nAGH2aMZ030722
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 09:02:37 -0800
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by spaceape8.eur.corp.google.com with ESMTP id nAGH2SGi000906
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 09:02:33 -0800
Received: by pwi12 with SMTP id 12so3619585pwi.2
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 09:02:32 -0800 (PST)
In-Reply-To: <87hbt0kaae.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> + =A0 =A0 case __constant_htons(ETH_P_IPV6):
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, sizeof(*ip6)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 ip6 =3D (struct ipv6hdr *) skb->data;
>> + =A0 =A0 =A0 =A0 =A0 =A0 ip_proto =3D ip6->nexthdr;
>> + =A0 =A0 =A0 =A0 =A0 =A0 addr1 =3D ip6->saddr.s6_addr32[3];
>> + =A0 =A0 =A0 =A0 =A0 =A0 addr2 =3D ip6->daddr.s6_addr32[3];
>
> Why only [3] ? Is this future proof?
>
No.  But it's same as inet6_ehashfn :-)

>> + =A0 =A0 for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq=
_cpus)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct softnet_data *queue =3D &per_cpu(so=
ftnet_data, cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __smp_call_function_single(cpu, &queue->cs=
d, 0);
>
> How do you get around the standard deadlocks with IPI called from
> irq disabled section?
>

What are the standard deadlocks?  Looks like __send_remote_softirq
will call __smp_call_function with irq's disabled...

> And why are the interrupts are disabled here anyways?
>

Protects rps_remote_softirq_cpus.


> It's a standard pet peeve of me, but it's quite unlikely you'll
> get any useful entropy at this time of kernel startup.
>
> Normally it's always the same.
>
Would it make sense to just use skb_tx_hashrnd for the receive hash
key also (renaming it to be more general)?


>> + =A0 =A0 if (err)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return err;
>> +
>> + =A0 =A0 rtnl_lock();
>
> It seems weird to do user parsing while holding that lock.
> Better first set up and allocate and then finally initialize global s=
tate.

Yes.  We could build a new map each time and then insert it into the
device structure using an rcu lock (which I hope would be sufficient
locking)

Thanks,
Tom
