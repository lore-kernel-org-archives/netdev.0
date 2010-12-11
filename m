From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [PATCH 2/7] vxge: fix crash of VF when unloading PF
Date: Fri, 10 Dec 2010 17:35:00 -0800
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EF8AF79FC@FRE1EXCH02.hq.exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
 <1292025782-16372-2-git-send-email-jon.mason@exar.com>
 <20101211010441.GI4040@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Chris Wright <chrisw@sous-sol.org>, Jon Mason <Jon.Mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:32741 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752482Ab0LKBfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 20:35:02 -0500
In-Reply-To: <20101211010441.GI4040@sequoia.sous-sol.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +
> >  /**
> >   * vxge_probe
> >   * @pdev : structure containing the PCI related information of the
> device.
> > @@ -4370,14 +4384,13 @@ vxge_probe(struct pci_dev *pdev, const struct
> pci_device_id *pre)
> >             num_vfs = vxge_get_num_vfs(function_mode) - 1;
> >
> >     /* Enable SRIOV mode, if firmware has SRIOV support and if it is a
> PF */
> > -   if (is_sriov(function_mode) && (max_config_dev > 1) &&
> > -           (ll_config->intr_type != INTA) &&
> > -           (is_privileged == VXGE_HW_OK)) {
> > -           ret = pci_enable_sriov(pdev, ((max_config_dev - 1) < num_vfs)
> > -                   ? (max_config_dev - 1) : num_vfs);
> > +   if (is_sriov(function_mode) && !is_sriov_initialized(pdev) &&
> > +      (ll_config->intr_type != INTA)) {
> > +           ret = pci_enable_sriov(pdev, num_vfs);
>
> This fundamentally changes the way VF's are allocated.  Now you cannot
> specifiy the number of vfs to allocate with max_config_dev module
> parameter.
The X3100 supports 11 different pci function modes where the user has the ability to choose the number of functions for each mode. This is more efficient usage of the hardware as the resources are carved out equally for the functions. By configuring the max_config_dev less than num_vfs, there's unnecessary wastage of resources.

>
> >             if (ret)
> >                     vxge_debug_ll_config(VXGE_ERR,
> >                             "Failed in enabling SRIOV mode: %d\n", ret);
> > +                   /* No need to fail out, as an error here is non-fatal */
> >     }
> >
> >     /*
> > @@ -4673,8 +4686,6 @@ static void __devexit vxge_remove(struct pci_dev
> *pdev)
> >
> >     iounmap(vdev->bar0);
> >
> > -   pci_disable_sriov(pdev);
> > -
>
> And you can never disable sriov.
If the device's pci function mode is changed, a power cycle is required in which case the functions are re-enumerated.

>
> This doesn't look like the right behaviour.
When the driver is loaded for the X3100 in SRIOV mode, it will be working in that mode even after it is unloaded and reloaded. As mentioned earlier, a change in the function mode requires and power cycle of the system.

The SRIOV feature is shipping in many distros and we need this fix back ported to prevent a possible crash when the PF is unloaded while the VFs are running in the guest OS in pass through mode.

If you have a better or simpler solution, that may take longer to implement, I would suggest that this solution be accepted in the interim.

Thanks,
Ram

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
