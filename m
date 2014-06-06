From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Fri, 6 Jun 2014 10:52:00 +0800
Message-ID: <20140606025200.GA6981@richard>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
 <20140602142947.GB28523@richard>
 <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
 <CAJZOPZK94-hZfBtpjFMEd5m1STRxbs-wTYsKB5SoC=zES5XfPg@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:35677 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbaFFCwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 22:52:09 -0400
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 6 Jun 2014 12:52:07 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B93AC2BB0047
	for <netdev@vger.kernel.org>; Fri,  6 Jun 2014 12:52:05 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s562U8di3408236
	for <netdev@vger.kernel.org>; Fri, 6 Jun 2014 12:30:09 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s562q2px029169
	for <netdev@vger.kernel.org>; Fri, 6 Jun 2014 12:52:03 +1000
Content-Disposition: inline
In-Reply-To: <CAJZOPZK94-hZfBtpjFMEd5m1STRxbs-wTYsKB5SoC=zES5XfPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2014 at 11:15:43AM +0300, Or Gerlitz wrote:
>On Mon, Jun 2, 2014 at 7:10 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
>> Writing a driver is not an empirical process of trying things to see
>> what works.  You need to actively design a consistent structure so you
>> know why and when things are safe.  I object to gratuitous "dev ==
>> NULL" checks because often they are just a way of patching up a driver
>> design that isn't well thought-out.
>
>Bjorn, 1st and most -- Agreed.
>
>Next, to be precise, the use case of rebooting the host while the
>driver was loaded in SRIOV mode and NO VFs probed to VMs worked before
>commit befdf89 and is now broken.
>
>Reading further your response, I understand that the code was probably
>using a sort of hackish branching to make that to happen, and you
>suggest we re-write that section properly so it can serve well when
>(hopefully soon) implemenet
>sriov_configure and possibly also suspend/resume, point taken.
>
>Dave, as for this patch, again, the regression of inability to reboot
>the host node
>while the driver is loaded exists in the latest upstream code as of
>befdf89 / 3.15-rc1
>
>Now, taking into account that 3.15 is after rc8 and the IL devel team
>has a holiday this week, I don't see us coming in time with a more
>deeper fix for 3.15, so maybe you can eventaully go and merge this one
>liner for 3.15?
>
>Or.
>

Hi, Or,

After understanding the root cause of this error, I come up with another kind
of fix to this case. Verification has been done on my machine, it looks good
to me. If your team could verify this, it would be better :-)

Hope you like it, and any problem please let me know :-)

>From 3dec04518a3a373c2d2cf2c4088fd5bbf36b4b7b Mon Sep 17 00:00:00 2001
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Fri, 6 Jun 2014 10:16:45 +0800
Subject: [PATCH] net/mlx4_core: keep only one driver entry release mlx4_priv

After commit befdf89(net/mlx4_core: Preserve pci_dev_data after
__mlx4_remove_one()), there would be two driver entry which will try to
release mlx4_priv, .shutdown and .remove. This will leads to a concequence that
the mlx4_prive will be released twice in some case and trigger an oops "Oops:
Kernel access of bad area".

One case for this error is doing reboot or kexec when VFs are enabled. During
reboot or kexec, .shutdown will be called. When VFs are shutdown at first and
then PF, PF will trigger VFs' .remove since VFs still have driver attached.

This patch resolve this case by keeping only one driver entry to release the
mlx4_priv.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
CC: Or Gerlitz <ogerlitz@mellanox.com>
CC: Jack Morgenstein <jackm@dev.mellanox.co.il>
CC: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7cf9dad..70a1356 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2799,7 +2799,7 @@ static struct pci_driver mlx4_driver = {
 	.name		= DRV_NAME,
 	.id_table	= mlx4_pci_table,
 	.probe		= mlx4_init_one,
-	.shutdown	= mlx4_remove_one,
+	.shutdown	= __mlx4_remove_one,
 	.remove		= mlx4_remove_one,
 	.err_handler    = &mlx4_err_handler,
 };
-- 
1.7.9.5


-- 
Richard Yang
Help you, Help me
