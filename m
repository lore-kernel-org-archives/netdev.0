From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 14 May 2013 08:19:02 -0700
Message-ID: <CAE9FiQWiHBvB4Q6Kc+S1jrgr_WO=DEk7pmE_UNc2eFQKpE+-_g@mail.gmail.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
	<1368498506-25857-7-git-send-email-yinghai@kernel.org>
	<CF9D1877D81D214CB0CA0669EFAE020C25AB3277@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Perla, Sathya" <Sathya.Perla@emulex.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C25AB3277@CMEXMB1.ad.emulex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 14, 2013 at 2:46 AM, Perla, Sathya <Sathya.Perla@emulex.com> wrote:
>
>> -----Original Message-----
>> From: linux-pci-owner@vger.kernel.org [mailto:linux-pci-
>> owner@vger.kernel.org] On Behalf Of Yinghai Lu
>>
>> Found kernel try to load mlx4 drivers for VFs before PF's is really loaded
>> when the drivers are built-in, and kernel command line include
>> probe_vfs=63, num_vfs=63.
>>
>> It turns that it also happen for hotadd path even drivers are compiled as
>> modules and if they loaded. Esp some VF share the same driver with PF.
>>
>> calling path:
>>       device driver probe
>>               ==> pci_enable_sriov
>>                       ==> virtfn_add
>>                               ==> pci_dev_add
>>                               ==> pci_bus_device_add
>> when pci_bus_device_add is called, the VF's driver will be attached.
>> and at that time PF's driver does not finish yet.
>>
>> Need to move out pci_bus_device_add from virtfn_add and call it later. Fix
>> the problem for two path, 1. hotadd path: use device_schedule_callback.
>> 2. for booting path, use initcall to call that for all VF's.
>>
>
> ...
>>
>> Index: linux-2.6/drivers/net/ethernet/emulex/benet/be_main.c
>> ==========================================================
>> =========
>> --- linux-2.6.orig/drivers/net/ethernet/emulex/benet/be_main.c
>> +++ linux-2.6/drivers/net/ethernet/emulex/benet/be_main.c
>> @@ -4119,6 +4119,7 @@ static int lancer_recover_func(struct be
>>       if (status)
>>               goto err;
>>
>> +     pci_bus_add_device_vfs(adapter->pdev);
>>       if (netif_running(adapter->netdev)) {
>>               status = be_open(adapter->netdev);
>>               if (status)
>> @@ -4335,6 +4336,8 @@ static int be_probe(struct pci_dev *pdev
>>       dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
>>                func_name(adapter), mc_name(adapter), port_name);
>>
>> +     pci_bus_add_device_vfs(pdev);
>> +
>>       return 0;
>>
>>  unsetup:
>> @@ -4406,6 +4409,7 @@ static int be_resume(struct pci_dev *pde
>>               rtnl_unlock();
>>       }
>>
>> +     pci_bus_add_device_vfs(adapter->pdev);
>>       schedule_delayed_work(&adapter->func_recovery_work,
>>                             msecs_to_jiffies(1000));
>>       netif_device_attach(netdev);
>
> I fixed this issue in be2net with the following patch (commit b4c1df93)
> http://marc.info/?l=linux-netdev&m=136801459808765&w=2

We should fix that in generic way.

BTW, Can you please implement sriov_configure like
intel igb, ixgbe
qlogic: qlcnic
...

driver really should not call pci_enable_sriov in probe path.

Yinghai
