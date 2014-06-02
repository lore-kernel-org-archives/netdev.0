From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Mon, 2 Jun 2014 10:10:01 -0600
Message-ID: <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com> <20140602142947.GB28523@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:52127 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbaFBQKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 12:10:22 -0400
Received: by mail-ig0-f176.google.com with SMTP id hl10so3540114igb.3
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 09:10:21 -0700 (PDT)
In-Reply-To: <20140602142947.GB28523@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2014 at 8:29 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
> On Sun, Jun 01, 2014 at 01:49:43PM +0300, Or Gerlitz wrote:
>>From: Jack Morgenstein <jackm@dev.mellanox.co.il>
>>
>>Commit befdf89 did not take into account the case where the Host
>>driver is being unloaded. In this case, pci_get_drvdata for the VF
>
> In my mind, unloading PF's driver when there is alive VFs is not allowed.
> Quoted in driver code:
>
>         /* in SRIOV it is not allowed to unload the pf's
>          * driver while there are alive vf's */
>         if (mlx4_is_master(dev) && mlx4_how_many_lives_vf(dev))
>                 printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
>
> Actually, I don't understand this restriction clearly. Maybe my understanding
> of alive VF is not correct.
>
> And in your code, unload PF's driver would call pci_disable_sriov() which will
> destroy the VFs. While in your test, the VF's driver is still there?
>
>>remove_one call may return NULL, so that dereferencing the priv
>>struct results in a kernel oops.
>
> Sorry for my poor mind, I still can't understand this situation.
> Would you describe the situation more? You are unloading PF's driver in Host
> at first, and then try to release the VF's driver?
>
>>
>>The fix is to also test that the dev pointer returned by
>>pci_get_drvdata is non-NULL.
>>
>>Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")
>>Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
>>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>>---
>> drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>>index c187d74..a6ae089 100644
>>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>>@@ -2629,7 +2629,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
>>       int               pci_dev_data;
>>       int p;
>>
>>-      if (priv->removed)
>>+      if (!dev || priv->removed)
>>               return;
>
> This fix looks good to me.
>
> As I remembered, I had this check in my first version, but I removed the check
> on dev based on the suggestion from Bjorn. Since I agreed that there is no
> chance for dev to be NULL. Bjorn, seems we are not correct :(

Writing a driver is not an empirical process of trying things to see
what works.  You need to actively design a consistent structure so you
know why and when things are safe.  I object to gratuitous "dev ==
NULL" checks because often they are just a way of patching up a driver
design that isn't well thought-out.

As I wrote before:

  From the PCI core's perspective, after .probe() returns successfully,
  we can call any driver entry point and pass the pci_dev to it, and
  expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()
  sort of breaks that assumption because you clear out pci_drvdata().
  Right now, the only other entry point mlx4 really implements is
  mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
  is NULL.  But that's ... a hack, and you'll have to do the same
  if/when you implement suspend/resume/sriov_configure/etc.

Bjorn
