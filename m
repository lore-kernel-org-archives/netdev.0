From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't access
 comm channel before PF is ready
Date: Thu, 6 Mar 2014 23:58:19 +0200
Message-ID: <CAJZOPZKfZ3Lp7XwasR19M1QC+5+ksQst8SORAxi2A7NVeHp7qg@mail.gmail.com>
References: <CAJZOPZLbmnaS_7mnOrMhp4ZrgehF+rgqnef0TEkJ3q8551OXDA@mail.gmail.com>
	<20140306.154804.999275744020224288.davem@davemloft.net>
	<CAJZOPZKdxmZ1NBKxnSeAnQv-F=e0zQBsjTON64RE67EitkySLQ@mail.gmail.com>
	<20140306.161258.1157292873686161603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, Narendra_K@dell.com,
	Sreekanth_Reddy@dell.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: David Miller <davem@davemloft.net>, Don Dutile <ddutile@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:63695 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbaCFV6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:58:20 -0500
Received: by mail-pa0-f52.google.com with SMTP id rd3so3235512pab.25
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 13:58:19 -0800 (PST)
In-Reply-To: <20140306.161258.1157292873686161603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 6, 2014 at 11:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Thu, 6 Mar 2014 23:08:36 +0200
>> On Thu, Mar 6, 2014 at 10:48 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Or Gerlitz <or.gerlitz@gmail.com>
>>> Date: Thu, 6 Mar 2014 22:19:48 +0200

>>>>> This synchronization scheme doesn't look right to me at all.
>>>>> It's global, so VF's for _any_ PF will probe defer while one is enabling SRIOV.
>>>>> It doesn't seem correct to cause unrelated VF's to defer the probe.
>>>> Can you please elaborate a bit why you find this approach to be
>>>> incorrect? basically, these nested VF probed are a bit headache
>>>> anyway, so we didn't find such global deferring to be problematic.

>>> What if a second PF starts to init and call pci_enable_sriov(), while the VFs
>>> from a previous PF probed call mlx4_init_slave()?
>>> It will increment pf_loading() and force those unreladed VFs to defer.

>> By "unreladed VFs" I assume you mean unrelated VFs that belong to the
>> 1st VF, which is OK for them to probe, right? so yes, this is sort of
>> conservative approach that wait till all PFs are fully ready, and I
>> understand you don't like it, but still, I would be happy to know
>> what's wrong in doing so..

> My understanding is that the relationship between these devices is:
>         PF --> VF1, VF2, VF3, ...
>
> and these VF children are (essentially) instantiated by
> pci_enable_sriov() calls.
>
> Therefore if we:
>
>         probe PF1
>
> we go:
>
>         pf_loading++
>         pci_enable_sriov();
>         PF1_VF1 defers
>         PF1_VF2 defers
>         PF1_VF3 defers
>         ...
>         pf_loading--
>
> next:
>
>         probe PF2
>
>         pf_loading++
> ..

correct, that would be the situation

> at this point any attempt of PF1's VFs to init will defer, what will
> cause them to properly retry that init?

So... we were thinking that there is a mechanism that causes them to
retry that init as long as they return -EPROBE_DEFER or they succeed,
isn't that the case?
