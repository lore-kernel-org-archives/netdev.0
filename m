From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v4 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Fri, 16 May 2014 10:30:24 -0700
Message-ID: <CAKh23FnAJZ-fa06WtCjJ+Of3_cDPypb+kgFFbWMy2-twjQhuPg@mail.gmail.com>
References: <1399326447-2329-1-git-send-email-isubramanian@apm.com>
	<1399326447-2329-5-git-send-email-isubramanian@apm.com>
	<1400258705.21547.217.camel@deneb.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"jcm@redhat.com" <jcm@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	patches <patches@apm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Keyur Chudgar <kchudgar@apm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Ravi Patel <rapatel@apm.com>
To: Mark Salter <msalter@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:37198 "HELO
	exprod5og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757721AbaEPRa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:30:27 -0400
Received: by mail-lb0-f181.google.com with SMTP id u14so2150432lbd.40
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:30:25 -0700 (PDT)
In-Reply-To: <1400258705.21547.217.camel@deneb.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 9:45 AM, Mark Salter <msalter@redhat.com> wrote:
> On Mon, 2014-05-05 at 14:47 -0700, Iyappan Subramanian wrote:
>> +static int xgene_enet_probe(struct platform_device *pdev)
>> +{
>> +       struct net_device *ndev;
>> +       struct xgene_enet_pdata *pdata;
>> +       struct device *dev = &pdev->dev;
>> +       struct napi_struct *napi;
>> +       int ret = 0;
>> +
>> +       ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
>> +       if (!ndev)
>> +               return -ENOMEM;
>> +
>> +       pdata = netdev_priv(ndev);
>> +
>> +       pdata->pdev = pdev;
>> +       pdata->ndev = ndev;
>> +       SET_NETDEV_DEV(ndev, dev);
>> +       platform_set_drvdata(pdev, pdata);
>> +       ndev->netdev_ops = &xgene_ndev_ops;
>> +       ndev->features |= NETIF_F_IP_CSUM;
>> +       ndev->features |= NETIF_F_GSO;
>> +       ndev->features |= NETIF_F_GRO;
>> +
>
> You're missing:
>
>          spin_lock_init(&pdata->stats_lock);

I really appreciate the help.  This fixed the crash.

>
> Lockdep (if enabled) complains:
>
>  xgene_enet_probe: 852
>  INFO: trying to register non-static key.
>  the code is fine but needs lockdep annotation.
>  turning off the locking correctness validator.
>  CPU: 4 PID: 1 Comm: swapper/0 Not tainted 3.15.0-rc4+ #13
>  Call trace:
>  [<ffffffc000087ef4>] dump_backtrace+0x0/0x16c
>  [<ffffffc000088070>] show_stack+0x10/0x1c
>  [<ffffffc000766b04>] dump_stack+0x88/0xb8
>  [<ffffffc00010243c>] __lock_acquire+0x1914/0x1ce0
>  [<ffffffc000102fa0>] lock_acquire+0x9c/0x1d0
>  [<ffffffc00076d418>] _raw_spin_lock+0x40/0x58
>  [<ffffffc0004fced0>] xgene_enet_get_stats+0x34/0x140
>  [<ffffffc0005fd7dc>] dev_get_stats+0x90/0xbc
>  [<ffffffc00061736c>] rtnl_fill_ifinfo+0x388/0x8e4
>  [<ffffffc000617938>] rtmsg_ifinfo+0x70/0x10c
>  [<ffffffc000609e98>] register_netdevice+0x370/0x400
>  [<ffffffc000609f3c>] register_netdev+0x14/0x2c
>  [<ffffffc0004fd7ec>] xgene_enet_probe+0x1cc/0x618
>  [<ffffffc0004a1928>] platform_drv_probe+0x28/0x80
>  [<ffffffc00049fc38>] driver_probe_device+0x98/0x3ac
>  [<ffffffc0004a0040>] __driver_attach+0xa0/0xa8
>  [<ffffffc00049dd78>] bus_for_each_dev+0x54/0x98
>  [<ffffffc00049f65c>] driver_attach+0x1c/0x28
>  [<ffffffc00049f234>] bus_add_driver+0x164/0x240
>  [<ffffffc0004a06b8>] driver_register+0x64/0x130
>  [<ffffffc0004a187c>] __platform_driver_register+0x5c/0x68
>  [<ffffffc000c08e14>] xgene_enet_driver_init+0x14/0x20
>  [<ffffffc000081418>] do_one_initcall+0xc4/0x154
>  [<ffffffc000bd2a74>] kernel_init_freeable+0x204/0x2a8
>  [<ffffffc00075e8a0>] kernel_init+0xc/0xd4
>
>> +       ret = xgene_enet_get_resources(pdata);
>> +       if (ret)
>> +               goto err;
>> +
>> +       ret = register_netdev(ndev);
>
>
