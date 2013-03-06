From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] net: docs: document multiqueue tuntap API
Date: Wed,  6 Mar 2013 11:05:23 +0800
Message-ID: <1362539123-24863-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, hkchu@google.com, Jason Wang <jasowang@redhat.com>
To: maxk@qti.qualcomm.com, rob@landley.net, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217Ab3CFDO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 22:14:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 Documentation/networking/tuntap.txt |   77 +++++++++++++++++++++++++++++++++++
 1 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/tuntap.txt b/Documentation/networking/tuntap.txt
index c0aab98..97423f5 100644
--- a/Documentation/networking/tuntap.txt
+++ b/Documentation/networking/tuntap.txt
@@ -105,6 +105,83 @@ Copyright (C) 1999-2000 Maxim Krasnyansky <max_mk@yahoo.com>
      Proto [2 bytes]
      Raw protocol(IP, IPv6, etc) frame.
 
+  3.3 Multiqueue tuntap interface:
+
+  From version 3.8, Linux supports multiqueue tuntap which can uses multiple
+  file descriptors (queues) to parallelize packets sending or receiving. The
+  device allocation is the same as before, and if user wants to create multiple
+  queues, TUNSETIFF with the same device name must be called many times with
+  IFF_MULTI_QUEUE flag.
+
+  char *dev should be the name of the device, queues is the number of queues to
+  be created, fds is used to store and return the file descriptors (queues)
+  created to the caller. Each file descriptor were served as the interface of a
+  queue which could be accessed by userspace.
+
+  #include <linux/if.h>
+  #include <linux/if_tun.h>
+
+  int tun_alloc_mq(char *dev, int queues, int *fds)
+  {
+  	struct ifreq ifr;
+  	int fd, err, i;
+
+  	if (!dev)
+  		return -1;
+
+  	memset(&ifr, 0, sizeof(ifr));
+  	/* Flags: IFF_TUN   - TUN device (no Ethernet headers)
+  	 *        IFF_TAP   - TAP device
+  	 *
+  	 *        IFF_NO_PI - Do not provide packet information
+  	 *        IFF_MULTI_QUEUE - Create a multiqueue devices
+  	 */
+  	ifr.ifr_flags = IFF_TAP | IFF_NO_PI | IFF_MULTI_QUEUE;
+  	strcpy(ifr.ifr_name, dev);
+
+  	for (i = 0; i < queues; i++) {
+  		if ((fd = open("/dev/net/tun", O_RDWR)) < 0)
+  			goto err;
+  		err = ioctl(fd, TUNSETIFF, (void *)&ifr);
+  		if (err) {
+  			close(fd);
+  			goto err;
+  		}
+  		fds[i] = fd;
+  	}
+
+  	return 0;
+  err:
+  	for (--i; i >= 0; i--)
+  		close(fds[i]);
+  	return err;
+  }
+
+  A new ioctl(TUNSETQUEUE) were introduced to enable or disable a queue. When
+  calling it with IFF_DETACH_QUEUE flag, the queue were disabled. And when
+  calling it with IFF_ATTACH_QUEUE flag, the queue were enabled. The queue were
+  enabled by default after it was created through TUNSETIFF.
+
+  fd is the file descriptor (queue) that we want to enable or disable, when
+  enable is true we enable it, otherwise we disable it
+
+  #include <linux/if.h>
+  #include <linux/if_tun.h>
+
+  int tun_set_queue(int fd, int enable)
+  {
+  	struct ifreq ifr;
+
+  	memset(&ifr, 0, sizeof(ifr));
+
+  	if (enable)
+  		ifr.ifr_flags = IFF_ATTACH_QUEUE;
+  	else
+  		ifr.ifr_flags = IFF_DETACH_QUEUE;
+
+  	return ioctl(fd, TUNSETQUEUE, (void *)&ifr);
+  }
+
 Universal TUN/TAP device driver Frequently Asked Question.
    
 1. What platforms are supported by TUN/TAP driver ?
-- 
1.7.1
