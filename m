From: Danny Feng <dfeng@redhat.com>
Subject: Re: [PATCH] e1000e: fix use of
	pci_enable_pcie_error_reporting
Date: Thu, 13 Aug 2009 12:29:39 +0800
Message-ID: <4A8396B3.6090609@redhat.com>
References: <1249637774-32419-1-git-send-email-dfeng@redhat.com>
	<20090812.204621.87530668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090812.204621.87530668.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 08/13/2009 11:46 AM, David Miller wrote:
> From: Xiaotian Feng<dfeng@redhat.com>
> Date: Fri,  7 Aug 2009 17:36:14 +0800
>
>> commit 111b9dc5 introduces pcie aer support for e1000e, but it is not
>> reasonable to disable it in e1000_remove but enable it in e1000_resume.
>> This patch enables aer support in e1000_probe.
>>
>> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>
> In moving this block of code, you've corrupted the indentation,
> making it more indented than it should be.
>
> In any event, I expect the Intel folks to pick this up.
Yes, I agree.... but each time I resume from suspend or rmmod e1000e, 
there's a warning message like "pci_enable_pcie_error_reporting failed 
0xfffffffb". Since some devices may not support aer, why not silence 
this kind of warning?

modprobe e1000e everything is as usual, but then rmmod e1000e, we'll see 
"pci_disable_pcie_error_reporting failed 0xfffffffb", it is so weird...
>
>> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
>> index 63415bb..e2f0304 100644
>> --- a/drivers/net/e1000e/netdev.c
>> +++ b/drivers/net/e1000e/netdev.c
>> @@ -4670,14 +4670,6 @@ static int e1000_resume(struct pci_dev *pdev)
>>   		return err;
>>   	}
>>
>> -	/* AER (Advanced Error Reporting) hooks */
>> -	err = pci_enable_pcie_error_reporting(pdev);
>> -	if (err) {
>> -		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
>> -		                    "0x%x\n", err);
>> -		/* non-fatal, continue */
>> -	}
>> -
>>   	pci_set_master(pdev);
>>
>>   	pci_enable_wake(pdev, PCI_D3hot, 0);
>> @@ -4990,6 +4982,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>>   	if (err)
>>   		goto err_pci_reg;
>>
>> +        /* AER (Advanced Error Reporting) hooks */
>> +        err = pci_enable_pcie_error_reporting(pdev);
>> +        if (err) {
>> +                dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
>> +                                    "0x%x\n", err);
>> +                /* non-fatal, continue */
>> +        }
>> +
>>   	pci_set_master(pdev);
>>   	/* PCI config space info */
>>   	err = pci_save_state(pdev);
>> -- 
>> 1.6.2.5
>>


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
