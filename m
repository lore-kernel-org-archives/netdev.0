From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] net/mlx4_core: match pci_device_id including dynids
Date: Wed, 2 Apr 2014 21:11:18 -0600
Message-ID: <CAErSpo749gfvcJmwjCw6c6H07S9cvaX2kz4jw1AwUZzbDN6Afw@mail.gmail.com>
References: <1396326961-20395-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAErSpo4yj+31puKhnxJ9Dns4c-1cWoUxxQt+OTDQDCGuuksOAw@mail.gmail.com> <20140403015130.GA6151@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:48840 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932843AbaDCDLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 23:11:39 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so1230205ieb.14
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 20:11:39 -0700 (PDT)
In-Reply-To: <20140403015130.GA6151@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 2, 2014 at 7:51 PM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
> On Wed, Apr 02, 2014 at 12:28:46PM -0600, Bjorn Helgaas wrote:

>>I looked at all the .error_detected() methods in the tree, and I think
>>mlx4_pci_err_detected() is the only one that actually throws away the
>>pci_drvdata().  Most drivers just do pci_disable_device() and some
>>other housekeeping.  Can you do something similar?
>
> Change mlx4_remove_one() to have just pci_disable_device() is a big decisioin.
> I believe Or and Amir will have better ideas.

Oh, I totally agree that you shouldn't make such a radical change just
for this issue.  What I meant was that maybe there's a relatively
simple way for you to hang on to the pci_drvdata() or at least the
pci_device_id.driver_data value.

BUT just on general principles, you should at least look at the other
drivers and use the same model unless you need something different.  I
doubt there's anything so special about mlx4 that it needs a totally
different approach.  But again, this is a broad comment, not a
suggestion for how to solve this particular issue.

>>The mlx4 approach of completely tearing down and rebuilding the device
>>*is* sort of appealing because I'm a little dubious of assuming that
>>any driver setup done before the reset is still valid afterwards.  But
>>maybe you could at least hang onto the pci_device_id.driver_data
>>value?  As far as the PCI core is concerned, it supplied that to the
>>.probe() function, and nothing has changed since then, so there's no
>>reason for a driver to request it again.
>
> Hmm... so you suggest every driver better do what mlx4_core does? Clear/Reset
> the device? This is reasonable to me, while one case comes into my mind --
> SRIOV. For example this PF triggers an error and be reported the error. If we
> tear down the PF, we should remove all the VFs too. This means once the PF
> gets into an error, all the PF and VFs should be cleared/reset, no matter
> whether the VFs are healthy or not. So there is no chance to isolate PF and
> VFs. I guess this is not what we want to achieve for SRIOV. Is my
> understanding correct?

No, I'm not suggesting that everybody do what mlx4 does.  I'm just
saying that I can see why mlx4 was designed that way.

>From the PCI core's perspective, after .probe() returns successfully,
we can call any driver entry point and pass the pci_dev to it, and
expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()
sort of breaks that assumption because you clear out pci_drvdata().
Right now, the only other entry point mlx4 really implements is
mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
is NULL.  But that's ... a hack, and you'll have to do the same
if/when you implement suspend/resume/sriov_configure/etc.

So doing the whole tear-down in mlx4_pci_err_detected() doesn't seem
like a great design to me.  But mlx4_remove_one() probably could be
refactored to move the bulk of its code into a helper, and then you
could have both mlx4_remove_one() and mlx4_pci_err_detected() call
that helper.  Clearing pci_set_drvdata() could be done only in
mlx4_remove_one(), so it could be preserved in
mlx4_pci_err_detected().

Bjorn
