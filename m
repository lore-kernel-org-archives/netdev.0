From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V3 02/11] net/mlx5_core: Add EQ renaming mechanism
Date: Tue, 12 May 2015 14:55:18 +0300
Message-ID: <CAPcc5Pijfg+799kG=gA-3w9RhsVnuOeRWYrX5qFh=SB6CABxGg@mail.gmail.com>
References: <1431250746-11941-1-git-send-email-amirv@mellanox.com>
	<1431250746-11941-3-git-send-email-amirv@mellanox.com>
	<20150511.134008.7539040783838247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:32848 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932468AbbELLzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 07:55:20 -0400
Received: by lbbzk7 with SMTP id zk7so3822949lbb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 04:55:18 -0700 (PDT)
In-Reply-To: <20150511.134008.7539040783838247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 8:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Sun, 10 May 2015 12:38:57 +0300
>
>> +int mlx5_rename_eq(struct mlx5_core_dev *dev, int eq_ix, char *name)
>> +{
>> +     struct mlx5_priv *priv = &dev->priv;
>> +     struct mlx5_eq_table *table = &priv->eq_table;
>> +     struct mlx5_eq *eq;
>> +     int err = -ENOENT;
>> +
>> +     spin_lock(&table->lock);
>> +     list_for_each_entry(eq, &table->comp_eqs_list, list) {
>> +             if (eq->index == eq_ix) {
>> +                     snprintf(priv->irq_info[eq_ix].name, MLX5_MAX_IRQ_NAME,
>> +                              "%s-%d", name, eq_ix);
>> +                     err = 0;
>> +                     break;
>> +             }
>> +     }
>> +     spin_unlock(&table->lock);
>> +
>> +     return err;
>> +}
>
> You have to be very careful with this.
>
> If you change these names after the request_irq() call(s), the new name string
> will not propagate to /proc/interrupts output etc.
>
> Looking at your later patches, this seems to be invoked very late in
> mlx5e_open_locked(), so I am concerned.
It is true. We call request_irq() when driver is loaded (and we don't
know yet if the ports types are Infiniband or Ethernet). Only later
on, we rename the name when interface is up and we know its name.

But, empirically /proc/interrupts is propagated with the new name
(according to latest net-next). Also, in the code, I don't see why
shouldn't it be updated. When calling request_irq(), name is not
copied, but irq_desc->action->name is pointing to it. This same
pointer is being used by show_interrupts() when /proc/interrupts is
queried.
So don't see why when modifying the string pointed by it, it wouldn't
shown on /proc/interrupts.

What did I miss?

Thanks,
Amir
