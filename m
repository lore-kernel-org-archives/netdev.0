From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Huge static buffer in liquidio
Date: Sat, 24 Sep 2016 22:02:40 +0200
Message-ID: <CAK1hOcMSL0PvgfAygr54_X4tob5c4m8_AkOrF+whzf2ZEHRrdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dave Miller <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35996 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965331AbcIXUDC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 16:03:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I would like to discuss this commit:

commit d3d7e6c65f75de18ced10a98595a847f9f95f0ce
Author: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date:   Tue Jun 21 22:53:07 2016 -0700

    liquidio: Firmware image download

    This patch has firmware image related changes for: firmware
    release upon failure, support latest firmware version and
    firmware download in 4MB chunks.


Here is a part of it:


+u8 fbuf[4 * 1024 * 1024];
         ^^^^^^^^^^^^^^^ what?????????? [also, why it is not static?]
+
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
                             size_t size)
 {
        int ret = 0;
-       u8 *p;
-       u8 *buffer;
+       u8 *p = fbuf;


Don't you think that using 4 megabytes of static buffer
*just for the firmware upload* is not a good practice?

Further down the patch it's obvious that the buffer is not even
needed, because the firmware is already in memory, the "data"
and "size" parameters of this function point to it.

The meat of the change of the FW download is this (deleted
some debug messages code):

-       buffer = kmemdup(data, size, GFP_KERNEL);
-       if (!buffer)
-               return -ENOMEM;
-
-       p = buffer + sizeof(struct octeon_firmware_file_header);
+       data += sizeof(struct octeon_firmware_file_header);

        /* load all images */
        for (i = 0; i < be32_to_cpu(h->num_images); i++) {
                load_addr = be64_to_cpu(h->desc[i].addr);
                image_len = be32_to_cpu(h->desc[i].len);

-               /* download the image */
-               octeon_pci_write_core_mem(oct, load_addr, p, image_len);
+               /* Write in 4MB chunks*/
+               rem = image_len;

-               p += image_len;
+               while (rem) {
+                       if (rem < (4 * 1024 * 1024))
+                               size = rem;
+                       else
+                               size = 4 * 1024 * 1024;
+
+                       memcpy(p, data, size);
+
+                       /* download the image */
+                       octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
+
+                       data += size;
+                       rem -= (u32)size;
+                       load_addr += size;
+               }
        }
+       dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
+                h->bootcmd);

        /* Invoke the bootcmd */
        ret = octeon_console_send_cmd(oct, h->bootcmd, 50);

-done_downloading:
-       kfree(buffer);


octeon_pci_write_core_mem() takes spinlock around copy op,
I take this was the reason for this change: reduce
IRQ-disabled time.

Do you actually need an intermediate fbuf[] buffer here?
(IOW: can't you just write data to PCI from memory area pointed
by "data" ptr?)

If there is indeed a reason for intermediate buffer,
why did you drop the approach of having a temporary kmalloc'ed
buffer and switches to a static (and *huge*) buffer?

In my opinion, 4 Mbyte buffer is an overkill in any case.
A buffer of ~4..16 Kbyte one would work just fine - it's not like
you need to squeeze last 0.5% of speed when you upload firmware.
