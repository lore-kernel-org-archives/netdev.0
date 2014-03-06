From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't
 access comm channel before PF is ready
Date: Thu, 06 Mar 2014 16:12:58 -0500 (EST)
Message-ID: <20140306.161258.1157292873686161603.davem@davemloft.net>
References: <CAJZOPZLbmnaS_7mnOrMhp4ZrgehF+rgqnef0TEkJ3q8551OXDA@mail.gmail.com>
	<20140306.154804.999275744020224288.davem@davemloft.net>
	<CAJZOPZKdxmZ1NBKxnSeAnQv-F=e0zQBsjTON64RE67EitkySLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, ogerlitz@mellanox.com, yevgenyp@mellanox.com,
	Narendra_K@dell.com, Sreekanth_Reddy@dell.com,
	netdev@vger.kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbaCFVNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:13:00 -0500
In-Reply-To: <CAJZOPZKdxmZ1NBKxnSeAnQv-F=e0zQBsjTON64RE67EitkySLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 6 Mar 2014 23:08:36 +0200

> On Thu, Mar 6, 2014 at 10:48 PM, David Miller <davem@davemloft.net> wrote:
>> From: Or Gerlitz <or.gerlitz@gmail.com>
>> Date: Thu, 6 Mar 2014 22:19:48 +0200
>>> On Thu, Mar 6, 2014 at 10:12 PM, David Miller <davem@davemloft.net> wrote:
> 
>>>> > +static atomic_t pf_loading = ATOMIC_INIT(0);
>>>> > @@ -1407,6 +1409,11 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
>>>> > +     if (atomic_read(&pf_loading)) {
>>>> > +             mlx4_warn(dev, "PF is not ready. Deferring probe\n");
>>>> > +             return -EPROBE_DEFER;
>>>> > +     }
>>>> > +
>>>> > @@ -2319,7 +2326,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
>>>> >
>>>> >               if (num_vfs) {
>>>> >                       mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n",num_vfs);
>>>> > +
>>>> > +                     atomic_inc(&pf_loading);
>>>> >                       err = pci_enable_sriov(pdev, num_vfs);
>>>> > +                     atomic_dec(&pf_loading);
>>>> > +
> 
>>>> This synchronization scheme doesn't look right to me at all.
>>>> It's global, so VF's for _any_ PF will probe defer while one is enabling SRIOV.
>>>> It doesn't seem correct to cause unrelated VF's to defer the probe.
> 
>>> Can you please elaborate a bit why you find this approach to be
>>> incorrect? basically, these nested VF probed are a bit headache
>>> anyway, so we didn't find such global deferring to be problematic.
> 
>> What if a second PF starts to init and call pci_enable_sriov(), while the VFs
>> from a previous PF probed call mlx4_init_slave()?
>> It will increment pf_loading() and force those unreladed VFs to defer.
> 
> By "unreladed VFs" I assume you mean unrelated VFs that belong to the
> 1st VF, which is OK for them to probe, right? so yes, this is sort of
> conservative approach that wait till all PFs are fully ready, and I
> understand you don't like it, but still, I would be happy to know
> what's wrong in doing so..

My understanding is that the relationship between these devices is:

	PF --> VF1, VF2, VF3, ...

and these VF children are (essentially) instantiated by
pci_enable_sriov() calls.

Therefore if we:

	probe PF1

we go:

	pf_loading++
	pci_enable_sriov();
	PF1_VF1 defers
	PF1_VF2 defers
	PF1_VF3 defers
	...
	pf_loading--

next:

	probe PF2

	pf_loading++
..

at this point any attempt of PF1's VFs to init will defer, what will
cause them to properly retry that init?
