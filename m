From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 0/2] hv_netvsc: linearize SKBs bigger than MAX_PAGE_BUFFER_COUNT-2 pages
Date: Wed,  8 Apr 2015 17:54:04 +0200
Message-ID: <1428508446-18423-1-git-send-email-vkuznets@redhat.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series fixes the same issue which was fixed in Xen with commit
97a6d1bb2b658ac85ed88205ccd1ab809899884d ("xen-netfront: Fix handling packets on
compound pages with skb_linearize").

It is relatively easy to create a packet which is small in size but occupies
more than 30 (MAX_PAGE_BUFFER_COUNT-2) pages. Here is a kernel-mode reproducer
which tries sending a packet with only 34 bytes of payload (but on 34 pages)
and fails:

#include <linux/module.h>
#include <linux/init.h>
#include <linux/net.h>
#include <linux/in.h>
#include <net/sock.h>

static int __init sendfb_init(void)
{
	struct socket *sock;
	int i, ret;
	struct sockaddr_in in4_addr = { 0 };
	struct page *pages[17];
	unsigned long flags;

	ret = sock_create_kern(AF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
	if (ret) {
		pr_err("failed to create socket: %d!\n", ret);
		return ret;
	}

	in4_addr.sin_family = AF_INET;
	/* www.google.com, 74.125.133.99 */
	in4_addr.sin_addr.s_addr = cpu_to_be32(0x4a7d8563);
	in4_addr.sin_port = cpu_to_be16(80);

	ret = sock->ops->connect(sock, (struct sockaddr *)&in4_addr, sizeof(in4_addr), 0);
	if (ret) {
		pr_err("failed to connect: %d!\n", ret);
		return ret;
	}

	/* We can send up to 17 frags */
	flags = MSG_MORE;
	for (i = 0; i < 17; i++) {
		if (i == 16)
			flags = MSG_EOR;
		pages[i] = alloc_pages(GFP_KERNEL | __GFP_COMP, 1);
		if (!pages[i]) {
			pr_err("out of memory!");
			goto free_pages;
		}
		sock->ops->sendpage(sock, pages[i], PAGE_SIZE -1, 2, flags);
	}

free_pages:
	for (; i > 0; i--)
		__free_pages(pages[i - 1], 1);

	printk("sendfb_init: test done\n");
        return -1;
}

module_init(sendfb_init);

MODULE_LICENSE("GPL");

A try to load such module results in multiple
'kernel: hv_netvsc vmbus_15 eth0: Packet too big: 100' messages as all retries
fail as well. It should also be possible to trigger the issue from userspace, I
expect e.g. NFS under heavy load to get stuck sometimes.

Vitaly Kuznetsov (2):
  hv_netvsc: use single existing drop path in netvsc_start_xmit
  hv_netvsc: try linearizing big SKBs before dropping them

 drivers/net/hyperv/netvsc_drv.c | 39 ++++++++++++++++++++++++++-------------
 1 file changed, 26 insertions(+), 13 deletions(-)

-- 
1.9.3
