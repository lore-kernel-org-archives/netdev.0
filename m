From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH] rose_dev: fix memcpy-bug in rose_set_mac_address
Date: Wed, 28 Mar 2012 10:47:43 +0200
Message-ID: <4F72D02F.6090907@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54241 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab2C1Irw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 04:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>> This patch fixes a small bug in rose_set_mac_address. If the current and new
>> MAC addresses match, then nothing needs to be done. However memcpy was used
>> instead of memcmp for comparison.
>>
>> The patch is against the latest net-tree.
>>
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>
> You're breaking this code, not fixing it.
>
> If you don't keep the memcpy, then the calls right below which setup
> the loopback node will use the previous device address not the new
> one being configured.

David, thanks for your feedback! So here's a small rework of the patch:

If both addresses equal, nothing needs to be done. If the device is down,
then we simply copy the new address to dev->dev_addr. If the device is up,
then we add another loopback device with the new address, and if that does
not fail, we remove the loopback device with the old address. And only
then, we update the dev->dev_addr.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/rose/rose_dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rose/rose_dev.c b/net/rose/rose_dev.c
index 178ff4f..2679507 100644
--- a/net/rose/rose_dev.c
+++ b/net/rose/rose_dev.c
@@ -96,11 +96,11 @@ static int rose_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *sa = addr;
 	int err;
 
-	if (!memcpy(dev->dev_addr, sa->sa_data, dev->addr_len))
+	if (!memcmp(dev->dev_addr, sa->sa_data, dev->addr_len))
 		return 0;
 
 	if (dev->flags & IFF_UP) {
-		err = rose_add_loopback_node((rose_address *)dev->dev_addr);
+		err = rose_add_loopback_node((rose_address *)sa->sa_data);
 		if (err)
 			return err;
 
