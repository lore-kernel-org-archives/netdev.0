From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't access
 comm channel before PF is ready
Date: Thu, 6 Mar 2014 22:19:48 +0200
Message-ID: <CAJZOPZLbmnaS_7mnOrMhp4ZrgehF+rgqnef0TEkJ3q8551OXDA@mail.gmail.com>
References: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
	<1394123297-7878-3-git-send-email-amirv@mellanox.com>
	<20140306.151254.914568962698409365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, Narendra_K@dell.com,
	Sreekanth_Reddy@dell.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:37210 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaCFUTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 15:19:48 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so3095554pbc.21
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 12:19:48 -0800 (PST)
In-Reply-To: <20140306.151254.914568962698409365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 6, 2014 at 10:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu,  6 Mar 2014 18:28:17 +0200
> > @@ -150,6 +150,8 @@ struct mlx4_port_config {
> >       struct pci_dev *pdev;
> >  };
> >
> > +static atomic_t pf_loading = ATOMIC_INIT(0);
> > +
> >  int mlx4_check_port_params(struct mlx4_dev *dev,
> >                          enum mlx4_port_type *port_type)
> >  {
> > @@ -1407,6 +1409,11 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
> >       u32 slave_read;
> >       u32 cmd_channel_ver;
> >
> > +     if (atomic_read(&pf_loading)) {
> > +             mlx4_warn(dev, "PF is not ready. Deferring probe\n");
> > +             return -EPROBE_DEFER;
> > +     }
> > +
>  ...
> > @@ -2319,7 +2326,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
> >
> >               if (num_vfs) {
> >                       mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", num_vfs);
> > +
> > +                     atomic_inc(&pf_loading);
> >                       err = pci_enable_sriov(pdev, num_vfs);
> > +                     atomic_dec(&pf_loading);
> > +
>
> This synchronization scheme doesn't look right to me at all.
> It's global, so VF's for _any_ PF will probe defer while one is enabling SRIOV.
> It doesn't seem correct to cause unrelated VF's to defer the probe.

Hi Dave,

Can you please elaborate a bit why you find this approach to be
incorrect? basically, these nested VF probed are a bit headache
anyway, so we didn't find such global deferring to be problematic.

Or.

> You have absolutely have to maintain this state at least on a per-PF level.
