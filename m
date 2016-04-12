From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Re: Unhandled fault during system suspend in sky2_shutdown
Date: Tue, 12 Apr 2016 15:06:16 +0100
Message-ID: <570D00D8.7000008@arm.com>
References: <570BCFC5.4070208@arm.com> <20160411112430.2a03e296@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160411112430.2a03e296@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/04/16 19:24, Stephen Hemminger wrote:
> On Mon, 11 Apr 2016 17:24:37 +0100
> Sudeep Holla <sudeep.holla@arm.com> wrote:
>

[...]

>>
>> diff --git i/drivers/net/ethernet/marvell/sky2.c
>> w/drivers/net/ethernet/marvell/sky2.c
>> index ec0a22119e09..0ff0434e32fc 100644
>> --- i/drivers/net/ethernet/marvell/sky2.c
>> +++ w/drivers/net/ethernet/marvell/sky2.c
>> @@ -5220,6 +5220,13 @@ static SIMPLE_DEV_PM_OPS(sky2_pm_ops,
>> sky2_suspend, sky2_resume);
>>
>>    static void sky2_shutdown(struct pci_dev *pdev)
>>    {
>> +       struct sky2_hw *hw = pci_get_drvdata(pdev);
>> +       int i;
>> +
>> +       for (i = hw->ports - 1; i >= 0; --i) {
>> +               sky2_detach(hw->dev[i]);
>> +               unregister_netdev(hw->dev[i]);
>> +       }
>>           sky2_suspend(&pdev->dev);
>>           pci_wake_from_d3(pdev, device_may_wakeup(&pdev->dev));
>>           pci_set_power_state(pdev, PCI_D3hot);
>
> This is not the correct fix, the device is supposed to stay
> registered. The correct way to fix this would be to make get_stats
> ignore requests  for device when suspended.

Yes I agree it's not correct fix. But I tried ignoring it in get_stat32
but the crash just moves the bug elsewhere. IMO patching all the places
to check the suspended state might be bit heavy ?

E.g. with something like below the crash moves to sky2_get_eeprom_len
function.

sky2_get_eeprom_len+0x10/0x30
dev_ethtool+0x29c/0x1d78
dev_ioctl+0x31c/0x5a8
sock_ioctl+0x2ac/0x310
do_vfs_ioctl+0xa4/0x750
SyS_ioctl+0x8c/0xa0
el0_svc_naked+0x24/0x2

Sorry if I am missing something fundamental, I am bit new to net drivers

Regards,
Sudeep

-->8

diff --git i/drivers/net/ethernet/marvell/sky2.c 
w/drivers/net/ethernet/marvell/sky2.c
index ec0a22119e09..d4cfcd89e7e5 100644
--- i/drivers/net/ethernet/marvell/sky2.c
+++ w/drivers/net/ethernet/marvell/sky2.c
@@ -5175,6 +5175,7 @@ static int sky2_suspend(struct device *dev)
         }

         sky2_power_aux(hw);
+       hw->suspended = true;
         rtnl_unlock();

         return 0;
@@ -5198,6 +5199,7 @@ static int sky2_resume(struct device *dev)
         }

         rtnl_lock();
+       hw->suspended = false;
         sky2_reset(hw);
         sky2_all_up(hw);
         rtnl_unlock();
diff --git i/drivers/net/ethernet/marvell/sky2.h 
w/drivers/net/ethernet/marvell/sky2.h
index ec6dcd80152b..1386e5b635ff 100644
--- i/drivers/net/ethernet/marvell/sky2.h
+++ w/drivers/net/ethernet/marvell/sky2.h
@@ -2308,6 +2308,7 @@ struct sky2_hw {
         wait_queue_head_t    msi_wait;

         char                 irq_name[0];
+       bool                 suspended;
  };

  static inline int sky2_is_copper(const struct sky2_hw *hw)
@@ -2378,6 +2379,9 @@ static inline u32 get_stats32(struct sky2_hw *hw, 
unsigned port, unsigned reg)
  {
         u32 val;

+       if (hw->suspended)
+               return 0;
+
         do {
                 val = gma_read32(hw, port, reg);
         } while (gma_read32(hw, port, reg) != val);
