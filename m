From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: match pci_device_id including dynids
Date: Fri, 4 Apr 2014 22:20:17 +0800
Message-ID: <20140404142017.GB5969@richard>
References: <1396326961-20395-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAErSpo4yj+31puKhnxJ9Dns4c-1cWoUxxQt+OTDQDCGuuksOAw@mail.gmail.com>
 <20140403015130.GA6151@richard>
 <CAErSpo749gfvcJmwjCw6c6H07S9cvaX2kz4jw1AwUZzbDN6Afw@mail.gmail.com>
 <20140403065432.GA18045@richard>
 <20140403211254.GA21931@google.com>
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
In-Reply-To: <20140403211254.GA21931@google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 03, 2014 at 03:12:54PM -0600, Bjorn Helgaas wrote:
>On Thu, Apr 03, 2014 at 02:54:32PM +0800, Wei Yang wrote:
>> Here is another one based on your comment, which split mlx4_remove_one into
>> two and named a helper __mlx4_remove_one(). mlx4_pci_err_detected() will just
>> call __mlx4_remove_one(), which will not release drvdata.
>> 
>> BTW, this is not tested, just want to make sure my understanding is correct.
>
>A couple minor comments below, but in general, yes, this is what I was
>thinking.
>
>> From 84a5a9df0604cbea9b70c74b0709258841637946 Mon Sep 17 00:00:00 2001
>> From: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Date: Mon, 31 Mar 2014 11:34:57 +0800
>> Subject: [PATCH] net/mlx4_core: match pci_device_id including dynids
>> 
>> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
>> pci_device_id.driver_data to __mlx4_init_one during reset".
>> 
>> pci_match_id() just match the static pci_device_id, which may return NULL if
>> someone binds the driver to a device manually using
>> /sys/bus/pci/drivers/.../new_id.
>> 
>> This patch wrap up a helper function __mlx4_remove_one() which does the tear
>> down function but preserve the drv_data. Functions like
>> mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
>> releasing drvdata.
>> 
>> CC: Bjorn Helgaas <bhelgaas@google.com>
>> CC: Amir Vadai <amirv@mellanox.com>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Acked-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/main.c |  149 ++++++++++++++++-------------
>>  1 file changed, 80 insertions(+), 69 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index aa54ef7..fd1f288 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -2268,7 +2268,12 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
>>  	/* Allow large DMA segments, up to the firmware limit of 1 GB */
>>  	dma_set_max_seg_size(&pdev->dev, 1024 * 1024 * 1024);
>>  
>> -	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
>> +	dev = pci_get_drvdata(pdev);
>> +	if (!dev)
>> +		priv = kzalloc(sizeof(*priv), GFP_KERNEL);
>> +	else
>> +		priv = mlx4_priv(dev);
>
>Why don't you move the priv kzalloc into mlx4_init_one()?  Then it would be
>symmetric -- you alloc and call pci_set_drvdata() in mlx4_init_one(), and
>you call pci_set_drvdata(NULL) and free it in mlx4_remove_one().  And you
>wouldn't need the test here.
>

Agree, this looks more consistent.

Will write a formal version and send to mail list after verification.

-- 
Richard Yang
Help you, Help me
