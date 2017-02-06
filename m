From: David Laight <David.Laight@ACULAB.COM>
Subject: Disabling msix interrupts
Date: Mon, 6 Feb 2017 15:33:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027C936@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:62160 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753710AbdBFPeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:34:02 -0500
Received: from 1calIk-00049c-UD by out6b.electric.net with emc1-ok (Exim 4.87)
        (envelope-from <David.Laight@ACULAB.COM>)
        id 1calIk-0004Dw-VS
        for netdev@vger.kernel.org; Mon, 06 Feb 2017 07:33:58 -0800
Received: from [213.249.233.130] (helo=AcuExch.aculab.com)
        by out6b.electric.net with esmtps (TLSv1:AES128-SHA:128)
        (Exim 4.87)
        (envelope-from <David.Laight@ACULAB.COM>)
        id 1calIk-00049c-UD
        for netdev@vger.kernel.org; Mon, 06 Feb 2017 07:33:58 -0800
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev probably isn't the right list for this, but I suspect people
reading it understand what happens.

I'm fairly sure that an msix interrupt can get raised after
the kernel thinks it has masked it.

When an msix interrupt is disabled I think msi_set_mask_bit()
(in drivers/pci/msi.c) is called to write a '1' to the card's
hardware MSIX mask register (the last 32bit word of the entry).
This function carefully reads back the mask register to flush
the write through the pcie bus.
Except it doesn't, it reads the 'address_lo' register instead! [1]

While this will stop the hardware raising any more interrupts,
it could easily be in the process of raising one.
ie have read the mask, found it zero, read the address and
data, and be in the process of issuing the pcie write.

The pcie write (to disable the interrupt) and readback are seen
by the hardware as (more or less) back to back transfers, so can
both easily overtake the request to raise the interrupt.
The pcie bus is also allowed to make a read completion tlp
overtake a write tlp.
Add in any host-side delays in raising the hardware interrupt
itself, and an interrupt could happen well after it was masked.

More worrying would be any code that tries to change the address
and data associated with an interrupt.
You'd need moderate guard times after the disable and before the
enable to ensure the hardware didn't raise an interrupt with
a mismatch of the old and new values.

[1] Maybe I'll look at the order those cycles actually arrive in.

	David
