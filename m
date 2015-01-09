From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] net: unisys: adding unisys virtnic driver
Date: Fri, 9 Jan 2015 11:13:33 -0500
Message-ID: <20150109161333.GA723@hmsreliant.think-freely.org>
References: <1418842340-29894-1-git-send-email-earfvids@redhat.com>
Reply-To: nhorman@tuxdriver.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: earfvids@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36148 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbbAIQNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 11:13:41 -0500
Content-Disposition: inline
In-Reply-To: <1418842340-29894-1-git-send-email-earfvids@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>The purpose of this patch is to add Unisys virtual network driver
>into the network directory and also to start a discussion about
>the requirements needed.
>
>Signed-off-by: Erik Arfvidson <earfvids@redhat.com>
>---
> drivers/net/virtnic.c | 2475 +++++++++++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 2475 insertions(+)
> create mode 100644 drivers/net/virtnic.c

><driver mostly snipped>

>+
>+/*****************************************************/
>+/* Module init & exit functions                      */
>+/*****************************************************/
>+
>+static int __init
>+virtnic_mod_init(void)
>+{
>+	int error, i;
>+
>+	LOGINF("entering virtnic_mod_init");
>+	/* ASSERT RCVPOST_BUF_SIZE < 4K */
>+	if (RCVPOST_BUF_SIZE > PI_PAGE_SIZE) {
>+		LOGERR("**** FAILED RCVPOST_BUF_SIZE:%d larger than a page\n",
>+		       RCVPOST_BUF_SIZE);
>+		return -1;
>+	}
>+	/* ASSERT RCVPOST_BUF_SIZE is big enough to hold eth header */
>+	if (RCVPOST_BUF_SIZE < ETH_HEADER_SIZE) {
>+		LOGERR("**** FAILED RCVPOST_BUF_SIZE:%d is <
ETH_HEADER_SIZE:%d\n",
>+		       RCVPOST_BUF_SIZE, ETH_HEADER_SIZE);
>+		return -1;
>+	}
>+
>+	/* clear out array */
>+	for (i = 0; i < VIRTNICSOPENMAX; i++) {
>+		num_virtnic_open[i].netdev = NULL;
>+		num_virtnic_open[i].vnicinfo = NULL;
>+	}
>+	/* create workqueue for serverdown completion */
>+	virtnic_serverdown_workqueue =
>+	    create_singlethread_workqueue("virtnic_serverdown");
>+	if (virtnic_serverdown_workqueue == NULL) {
>+		LOGERR("**** FAILED virtnic_serverdown_workqueue creation\n");
>+		return -1;
>+	}
>+	/* create workqueue for tx timeout reset  */
>+	virtnic_timeout_reset_workqueue =
>+	    create_singlethread_workqueue("virtnic_timeout_reset");
>+	if (virtnic_timeout_reset_workqueue == NULL) {
>+		LOGERR
>+		    ("**** FAILED virtnic_timeout_reset_workqueue creation\n");
>+		return -1;
>+	}
>+	virtnic_debugfs_dir = debugfs_create_dir("virtnic", NULL);
>+	debugfs_create_file("info", S_IRUSR, virtnic_debugfs_dir,
>+			    NULL, &debugfs_info_fops);
>+	debugfs_create_file("enable_ints", S_IWUSR,
>+			    virtnic_debugfs_dir, NULL,
>+			    &debugfs_enable_ints_fops);
>+
>+	error = virtpci_register_driver(&virtnic_driver);
>+	if (error < 0) {

So, I've been trying to puzzle out what the architecture of this driver is.
>From what I've been able to gather:

1) The device this driver interfaces too is not a real device, but rather some
multipurpose chip that can expose network functions as well as several other
devices.

2) It's (the hardware's) device exposure is driven by some sideband interface
outside of the purview of the operating system

3) The virtpci driver that you have in the staging tree is responsible for
interfacing the root pci bridge to your hardware so that it (again your
hardware) can act like a pci bus to interface to these administratively plumbed
devices.

4) The net devices that this driver registers are typically meant (though not
required) to be used by guests via pci passthrough.

Is that all about correct?  Just trying to get a handle on what all is going on
here.

Operating under the assumption that the above is correct (please correct me if
I'm wrong), I've got a few comments.

A) This isn't going to be accepted until the bus driver that provides access to
the pci interface for this hardware is merged.  Without that bit, this driver
can't do anything.

B) Looking at the virtpci driver, it neds alot of cleanup before it has a hope
of going in.  On the upside though, I think most of the code that needs cleaning
up, really just needs removal.  90% of that file in staging isn't called by
anything that I can tell.  Thats not completely accrurate, in that you seem to
have a side band input path via virtpci_ctrlchan_func, which gets called from
the uisctrl library that appears to be used to create and manage devices, but it
all deadends there.  See uislib_client_inject_add_vhba or
uislib_client_inject_add_vnic for examples.  So I don't see a whole lot of need
for (at least not yet).  I presume that, if this stuff works, theres some other
method of plumbing devices on the hardware asside from the uislib in staging.
As such, you can remove it for now.  If thats not the case, then you have much
bigger problems, as I'm not sure how any of this works at all, since I don't see
a path for plumbing devices.

C) This isn't really a virtio driver, in the sense that virtio_net or veth is,
its more of an SRIOV device by another name, in that it drives real hardware, or
at least a virtual function on a real pci device.

I think, if you want to get it accepted, the fastest road forward would be to do
the following:

1) Gut virtpci.c.  Remove anything non-functional from it. That would separate
you from your uislib, and make virtpci both fairly standalone and reasonably
small.  That (I think) should make virtpci more amenable to mainline acceptance
if you repost it (I'll have to let the linux-pci list review that
more closely however).  If thats accepted it should allow the pci core to
properly probe devices belonging to the above virtnic driver

2) rework virtnic to register with the pci core, not the redundant
virtpci_driver_register api. There should be no need for that.  That will make
this a full fledged pci driver, which will be nice.  Perhaps also rename it
(unisys_vfnic or something more indicative of its nature, so as to separate it
from the virtio family of devices.  There may be other cleanups to do in the
driver as well (I've not looked at it in depth yet)

That should put you in a position where you have a functioning nic driver for
your hardware that you can either pass to a guest via pci passthrough, or use as
backing for a virtio_nic or veth device.  It will be much more lean, and
maintainable, and from there you can start adding management bits back in.

Regards
Neil
