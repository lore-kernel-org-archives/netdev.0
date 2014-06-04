From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Wed, 4 Jun 2014 17:50:23 +0800
Message-ID: <20140604095023.GA5674@richard>
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
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:46397 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbaFDJud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 05:50:33 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 4 Jun 2014 19:50:31 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 886782CE8050
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 19:50:27 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s549YUBo12189924
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2014 19:34:31 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s549oQ0j019514
	for <netdev@vger.kernel.org>; Wed, 4 Jun 2014 19:50:26 +1000
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

Hi, Or,

I did some tests with your steps to reproduce the case. Below is my analysis:

I did "rmmod mlx4_core" and "kexec" after probe the Mellanox driver. Below is
the log from two steps respectively.

[root@tian-lp1 ywywyang]# rmmod mlx4_core 
[  534.159740] mlx4_core 0003:05:00.1: mlx4_remove_one: called
[  534.161272] mlx4_core 0003:05:00.0: Received reset from slave:1
[  534.161509] mlx4_core 0003:05:00.0: mlx4_remove_one: called
[  534.170823] mlx4_core 0003:05:00.0: Disabling SR-IOV

[root@tian-lp1 ywywyang]# kexec -e 
[  669.089322] kvm: exiting hardware virtualization
[  669.091746] mlx4_core 0003:05:00.1: mlx4_remove_one: called
[  669.326754] mlx4_core 0003:05:00.0: Received reset from slave:1
[  674.488417] lpfc 0006:01:00.4: 2:2885 Port Status Event: port status reg 0x81000000, port smphr reg 0xc000, error 1=0x9f000001, error 2=0xa9fa47fd
[  675.618578] mlx4_core 0003:05:00.0: mlx4_remove_one: called
[  675.691278] mlx4_en 0003:05:00.0: removed PHC
[  675.700414] mlx4_core 0003:05:00.0: Disabling SR-IOV
[  675.700630] mlx4_core 0003:05:00.1: mlx4_remove_one: called
[  675.700701] Unable to handle kernel paging request for data at address 0x00000370
[  675.700769] Faulting instruction address: 0xd00000001a13fb88
[  675.700826] Oops: Kernel access of bad area, sig: 11 [#1]
[---]

During rmmod, the driver works fine, and in kexec there is oops message. The
kexec is almost the same as reboot. We see the driver for pci device 
0003:05:00.1 has been "removed" twice and at the second time the driver
triggers an error.

rmmod and kexec calls different driver entry, rmmod -> .remove and
kexec->shutdown. I think this is the reason why there is an oops message
during reboot. In .shutdown, the driver will not be detached. While in case
there is VFs, both .shutdown and .remove will be invoked on VF.

Did a quick glance at the e1000e driver, the .shutdown and .remove behaves
differently. So maybe at .shutdown, it needs some different handling than
.remove. Well adding a check at .remove is a quick fix for this case.

This is my draft analysis for your reference, hope it is correct and help you
to some extend.

Have a good day :-)

-- 
Richard Yang
Help you, Help me
