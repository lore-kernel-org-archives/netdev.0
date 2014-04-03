From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: match pci_device_id including dynids
Date: Thu, 3 Apr 2014 09:51:30 +0800
Message-ID: <20140403015130.GA6151@richard>
References: <1396326961-20395-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAErSpo4yj+31puKhnxJ9Dns4c-1cWoUxxQt+OTDQDCGuuksOAw@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAErSpo4yj+31puKhnxJ9Dns4c-1cWoUxxQt+OTDQDCGuuksOAw@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 02, 2014 at 12:28:46PM -0600, Bjorn Helgaas wrote:
>On Mon, Mar 31, 2014 at 10:36 PM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>> pci_device_id.driver_data to __mlx4_init_one during reset".
>>
>> pci_match_id() just match the static pci_device_id, which may return NULL if
>> someone binds the driver to a device manually using
>> /sys/bus/pci/drivers/.../new_id.
>>
>> This patch match pci_device_id with pci_match_device() to cover both dynids
>> and static id_table.
>>
>> Thanks to Bjorn finding this issue.
>
>I didn't actually find it; I just passed along an issue found by
>Coverity.  I usually include "Found by Coverity (CID 1194947)" in the
>changelog in case anybody is trying to manage those issues.
>
>> CC: Bjorn Helgaas <bhelgaas@google.com>
>> CC: Amir Vadai <amirv@mellanox.com>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Acked-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/main.c |    4 +++-
>>  drivers/pci/pci-driver.c                  |    3 ++-
>>  include/linux/pci.h                       |    2 ++
>>  3 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index aa54ef7..b0edb5c 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -2673,7 +2673,9 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>>         const struct pci_device_id *id;
>>         int ret;
>>
>> -       id = pci_match_id(mlx4_pci_table, pdev);
>> +       id = pci_match_device(pci_dev_driver(pdev), pdev);
>> +       BUG_ON(!id);
>
>This doesn't seem like the best solution to me, because it basically
>duplicates part of __pci_device_probe() in the driver.  And of course,
>I'd rather not export pci_match_device() if we can avoid it (I don't
>have a specific objection; just the general "don't export more than
>necessary" rule, and something with a single user always makes me look
>twice).

Agree, we should be careful to export a function.

>
>I looked at all the .error_detected() methods in the tree, and I think
>mlx4_pci_err_detected() is the only one that actually throws away the
>pci_drvdata().  Most drivers just do pci_disable_device() and some
>other housekeeping.  Can you do something similar?

Change mlx4_remove_one() to have just pci_disable_device() is a big decisioin.
I believe Or and Amir will have better ideas.

>
>The mlx4 approach of completely tearing down and rebuilding the device
>*is* sort of appealing because I'm a little dubious of assuming that
>any driver setup done before the reset is still valid afterwards.  But
>maybe you could at least hang onto the pci_device_id.driver_data
>value?  As far as the PCI core is concerned, it supplied that to the
>.probe() function, and nothing has changed since then, so there's no
>reason for a driver to request it again.

Hmm... so you suggest every driver better do what mlx4_core does? Clear/Reset
the device? This is reasonable to me, while one case comes into my mind --
SRIOV. For example this PF triggers an error and be reported the error. If we
tear down the PF, we should remove all the VFs too. This means once the PF
gets into an error, all the PF and VFs should be cleared/reset, no matter
whether the VFs are healthy or not. So there is no chance to isolate PF and
VFs. I guess this is not what we want to achieve for SRIOV. Is my
understanding correct?

Come back to the issue in this patch, one quick fix in my mind is after tear
down the device and release the driver_data, we build another one and save the
pci_dev_data in it again. Will send this version for comments.

>
>Bjorn
>
>>         ret = __mlx4_init_one(pdev, id->driver_data);
>>
>>         return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
>> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
>> index 25f0bc6..1ee26a1 100644
>> --- a/drivers/pci/pci-driver.c
>> +++ b/drivers/pci/pci-driver.c
>> @@ -225,7 +225,7 @@ const struct pci_device_id *pci_match_id(const struct pci_device_id *ids,
>>   * system is in its list of supported devices.  Returns the matching
>>   * pci_device_id structure or %NULL if there is no match.
>>   */
>> -static const struct pci_device_id *pci_match_device(struct pci_driver *drv,
>> +const struct pci_device_id *pci_match_device(struct pci_driver *drv,
>>                                                     struct pci_dev *dev)
>>  {
>>         struct pci_dynid *dynid;
>> @@ -1355,6 +1355,7 @@ postcore_initcall(pci_driver_init);
>>
>>  EXPORT_SYMBOL_GPL(pci_add_dynid);
>>  EXPORT_SYMBOL(pci_match_id);
>> +EXPORT_SYMBOL(pci_match_device);
>>  EXPORT_SYMBOL(__pci_register_driver);
>>  EXPORT_SYMBOL(pci_unregister_driver);
>>  EXPORT_SYMBOL(pci_dev_driver);
>> diff --git a/include/linux/pci.h b/include/linux/pci.h
>> index 44f6883..8ede1b5 100644
>> --- a/include/linux/pci.h
>> +++ b/include/linux/pci.h
>> @@ -1134,6 +1134,8 @@ int pci_add_dynid(struct pci_driver *drv,
>>                   unsigned long driver_data);
>>  const struct pci_device_id *pci_match_id(const struct pci_device_id *ids,
>>                                          struct pci_dev *dev);
>> +const struct pci_device_id *pci_match_device(struct pci_driver *drv,
>> +                                                   struct pci_dev *dev);
>>  int pci_scan_bridge(struct pci_bus *bus, struct pci_dev *dev, int max,
>>                     int pass);
>>
>> --
>> 1.7.9.5
>>

-- 
Richard Yang
Help you, Help me
