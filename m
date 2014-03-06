From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't access
 comm channel before PF is ready
Date: Thu, 6 Mar 2014 23:08:36 +0200
Message-ID: <CAJZOPZKdxmZ1NBKxnSeAnQv-F=e0zQBsjTON64RE67EitkySLQ@mail.gmail.com>
References: <1394123297-7878-3-git-send-email-amirv@mellanox.com>
	<20140306.151254.914568962698409365.davem@davemloft.net>
	<CAJZOPZLbmnaS_7mnOrMhp4ZrgehF+rgqnef0TEkJ3q8551OXDA@mail.gmail.com>
	<20140306.154804.999275744020224288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, Narendra_K@dell.com,
	Sreekanth_Reddy@dell.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:59436 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbaCFVIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:08:36 -0500
Received: by mail-pb0-f51.google.com with SMTP id uo5so3159426pbc.38
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 13:08:36 -0800 (PST)
In-Reply-To: <20140306.154804.999275744020224288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 6, 2014 at 10:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <or.gerlitz@gmail.com>
> Date: Thu, 6 Mar 2014 22:19:48 +0200
>> On Thu, Mar 6, 2014 at 10:12 PM, David Miller <davem@davemloft.net> wrote:

>>> > +static atomic_t pf_loading = ATOMIC_INIT(0);
>>> > @@ -1407,6 +1409,11 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
>>> > +     if (atomic_read(&pf_loading)) {
>>> > +             mlx4_warn(dev, "PF is not ready. Deferring probe\n");
>>> > +             return -EPROBE_DEFER;
>>> > +     }
>>> > +
>>> > @@ -2319,7 +2326,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
>>> >
>>> >               if (num_vfs) {
>>> >                       mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n",num_vfs);
>>> > +
>>> > +                     atomic_inc(&pf_loading);
>>> >                       err = pci_enable_sriov(pdev, num_vfs);
>>> > +                     atomic_dec(&pf_loading);
>>> > +

>>> This synchronization scheme doesn't look right to me at all.
>>> It's global, so VF's for _any_ PF will probe defer while one is enabling SRIOV.
>>> It doesn't seem correct to cause unrelated VF's to defer the probe.

>> Can you please elaborate a bit why you find this approach to be
>> incorrect? basically, these nested VF probed are a bit headache
>> anyway, so we didn't find such global deferring to be problematic.

> What if a second PF starts to init and call pci_enable_sriov(), while the VFs
> from a previous PF probed call mlx4_init_slave()?
> It will increment pf_loading() and force those unreladed VFs to defer.

By "unreladed VFs" I assume you mean unrelated VFs that belong to the
1st VF, which is OK for them to probe, right? so yes, this is sort of
conservative approach that wait till all PFs are fully ready, and I
understand you don't like it, but still, I would be happy to know
what's wrong in doing so..

> You must have a per-PF value to block the underlying VFs, rather than a global
> one.
