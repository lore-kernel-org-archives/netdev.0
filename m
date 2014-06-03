From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Tue, 3 Jun 2014 10:00:01 +0800
Message-ID: <20140603020001.GA4903@richard>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
 <20140602142947.GB28523@richard>
 <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:33239 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbaFCCAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 22:00:09 -0400
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 3 Jun 2014 07:30:06 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 38A6E394003E
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 07:30:05 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5320HDR9503148
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2014 07:30:17 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s53202TW021338
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2014 07:30:04 +0530
Content-Disposition: inline
In-Reply-To: <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2014 at 10:10:01AM -0600, Bjorn Helgaas wrote:
>On Mon, Jun 2, 2014 at 8:29 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>> On Sun, Jun 01, 2014 at 01:49:43PM +0300, Or Gerlitz wrote:
>>>From: Jack Morgenstein <jackm@dev.mellanox.co.il>
>>>
>>>Commit befdf89 did not take into account the case where the Host
>>>driver is being unloaded. In this case, pci_get_drvdata for the VF
>>
>> In my mind, unloading PF's driver when there is alive VFs is not allowed.
>> Quoted in driver code:
>>
>>         /* in SRIOV it is not allowed to unload the pf's
>>          * driver while there are alive vf's */
>>         if (mlx4_is_master(dev) && mlx4_how_many_lives_vf(dev))
>>                 printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
>>
>> Actually, I don't understand this restriction clearly. Maybe my understanding
>> of alive VF is not correct.
>>
>> And in your code, unload PF's driver would call pci_disable_sriov() which will
>> destroy the VFs. While in your test, the VF's driver is still there?
>>
>>>remove_one call may return NULL, so that dereferencing the priv
>>>struct results in a kernel oops.
>>
>> Sorry for my poor mind, I still can't understand this situation.
>> Would you describe the situation more? You are unloading PF's driver in Host
>> at first, and then try to release the VF's driver?
>>
>>>
>>>The fix is to also test that the dev pointer returned by
>>>pci_get_drvdata is non-NULL.
>>>
>>>Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")
>>>Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>>>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>>>---
>>> drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>>>index c187d74..a6ae089 100644
>>>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>>>@@ -2629,7 +2629,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
>>>       int               pci_dev_data;
>>>       int p;
>>>
>>>-      if (priv->removed)
>>>+      if (!dev || priv->removed)
>>>               return;
>>
>> This fix looks good to me.
>>
>> As I remembered, I had this check in my first version, but I removed the check
>> on dev based on the suggestion from Bjorn. Since I agreed that there is no
>> chance for dev to be NULL. Bjorn, seems we are not correct :(
>
>Writing a driver is not an empirical process of trying things to see
>what works.  You need to actively design a consistent structure so you
>know why and when things are safe.  I object to gratuitous "dev ==
>NULL" checks because often they are just a way of patching up a driver
>design that isn't well thought-out.
>
>As I wrote before:
>
>  From the PCI core's perspective, after .probe() returns successfully,
>  we can call any driver entry point and pass the pci_dev to it, and
>  expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()
>  sort of breaks that assumption because you clear out pci_drvdata().
>  Right now, the only other entry point mlx4 really implements is
>  mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
>  is NULL.  But that's ... a hack, and you'll have to do the same
>  if/when you implement suspend/resume/sriov_configure/etc.

Thanks for your kindness. After re-reading it, I understand it more, it is not
only related to the Mellanox driver, but also the whole picture about how to
write a driver.

1. We should make the driver entry save, after .probe() returns successfully.
2. If there is an exception and a hack to test the pci_drvdata(), we need to
   have this hack in suspend/resum/etc.

Now back to the current mlx4 driver, mlx4_remove_one() is called by .shutdown
and .remove. In my mind, these two hook is invoked by rmmod or reboot. By
doing so, it is trying to comply with rule 1, make sure the pci_drvdata() is
valid, after .probe() succeed.

Then I am curious about in which case the driver break this rule. 

Following is my suggestion:
1. To comply with rule 1, it would be better to fix this point instead of add
   a hack.
2. Or to comply with rule 2, the driver needs to check pci_drvdata() in every
   driver's entry instead of just in one driver entry. For example,
   mlx4_pci_slot_reset() need this check too.

Bjorn, thanks again, hope my understanding this time is correct :-)

>
>Bjorn

-- 
Richard Yang
Help you, Help me
