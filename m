From: Jim Baxter <jim_baxter@mentor.com>
Subject: [RFC V1 0/1] Reduce cdc_ncm memory use when kernel memory low
Date: Tue, 16 May 2017 18:41:19 +0100
Message-ID: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jim_baxter@mentor.com>
To: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please review this patch


Problem
-------

We are using an ARM embedded platform and require 16KiB NTB's to allow for fast
data transfer. Unfortunately we have found that there are times after
running the kernel for a while and transferring a lot of data over the CDC-NCM
connection that it can become harder to find 16KiB pages of memory for
allocation.
This results in a disconnection of the NCM Gadget attached to the host platform.

We are running with reduced buffers to not cross over into the 32KiB page
boundary by setting the buffer sizes to:
tx_max=16000
rx_max=16000


Analysis
--------

We identified through investigation that the lack of 16KiB pages would be short
lived as the kernel would compact the buddy list soon after the failure which 
results in pages being available within seconds.

Solution
--------

In order to avoid disconnections I implemented a patch that will attempt to
use a 2048 Byte minimum size NTB if the allocation of the maximum size NTB
fails.
This allows the connection to limp along until the memory has been recovered
which was usually between 1 and 4 NTBS on our heavy traffic system.


Jim Baxter (1):
  net: cdc_ncm: Reduce memory use when kernel memory low

 drivers/net/usb/cdc_ncm.c   | 39 +++++++++++++++++++++++++++------------
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 28 insertions(+), 12 deletions(-)

-- 
1.9.1
