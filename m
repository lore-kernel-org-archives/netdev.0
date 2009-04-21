From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Mon, 20 Apr 2009 20:26:13 -0700
Message-ID: <65634d660904202026r7d73f810s700bacb8756e0967@mail.gmail.com>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	 <87eivnpqde.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:45938 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbZDUD0R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 23:26:17 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n3L3QFpA002166
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 20:26:15 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by zps78.corp.google.com with ESMTP id n3L3PKsT020437
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 20:26:13 -0700
Received: by qyk35 with SMTP id 35so1121582qyk.6
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 20:26:13 -0700 (PDT)
In-Reply-To: <87eivnpqde.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 3:32 AM, Andi Kleen <andi@firstfloor.org> wrote=
:
>
> Tom Herbert <therbert@google.com> writes:
>
> > +static int netif_cpu_for_rps(struct net_device *dev, struct sk_buf=
f *skb)
> > +{
> > + =A0 =A0 cpumask_t mask;
> > + =A0 =A0 unsigned int hash;
> > + =A0 =A0 int cpu, count =3D 0;
> > +
> > + =A0 =A0 cpus_and(mask, dev->soft_rps_cpus, cpu_online_map);
> > + =A0 =A0 if (cpus_empty(mask))
> > + =A0 =A0 =A0 =A0 =A0 =A0 return smp_processor_id();
>
> There's a race here with CPU hotunplug I think. When a CPU is hotunpl=
ugged
> in parallel you can still push packets to it even though they are not
> drained. You probably need some kind of drain callback in a CPU hotun=
plug
> notifier that eats all packets left over.
>
We will look at that, the hotplug support may very well be lacking in t=
he patch.

> > +got_hash:
> > + =A0 =A0 hash %=3D cpus_weight_nr(mask);
>
> That looks rather heavyweight even on modern CPUs. I bet it's 40-50+ =
cycles
> alone forth the hweight and the division. Surely that can be done bet=
ter?
>
Agreed, I will try to pull in the RX hash from Dave Miller's remote
softirq patch.

> Also I suspect some kind of runtime switch for this would be useful.
>
> Also the manual set up of the receive mask seems really clumpsy. Coul=
dn't
> you set that up dynamically based on where processes executing recvms=
g()
> are running?
>
We have done exactly that.  It works very well in many cases
(application + platform combinations), but I haven't found it to be
better than doing the hash in all cases.  I could provide the patch,
but it might be more of a follow patch to this base one.

Thanks,
Tom
