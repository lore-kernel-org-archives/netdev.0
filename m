From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net] mpls: handle device renames for per-device sysctls
Date: Thu, 11 Jun 2015 19:58:26 +0100
Message-ID: <1434049106-30407-1-git-send-email-rshearma@brocade.com>
References: <5579A371.90101@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:22858 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752293AbbFKS7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 14:59:00 -0400
In-Reply-To: <5579A371.90101@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a device is renamed and the original name is subsequently reused
for a new device, the following warning is generated:

sysctl duplicate entry: /net/mpls/conf/veth0//input
CPU: 3 PID: 1379 Comm: ip Not tainted 4.1.0-rc4+ #20
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
 0000000000000000 0000000000000000 ffffffff81566aaf 0000000000000000
 ffffffff81236279 ffff88002f7d7f00 0000000000000000 ffff88000db336d8
 ffff88000db33698 0000000000000005 ffff88002e046000 ffff8800168c9280
Call Trace:
 [<ffffffff81566aaf>] ? dump_stack+0x40/0x50
 [<ffffffff81236279>] ? __register_sysctl_table+0x289/0x5a0
 [<ffffffffa051a24f>] ? mpls_dev_notify+0x1ff/0x300 [mpls_router]
 [<ffffffff8108db7f>] ? notifier_call_chain+0x4f/0x70
 [<ffffffff81470e72>] ? register_netdevice+0x2b2/0x480
 [<ffffffffa0524748>] ? veth_newlink+0x178/0x2d3 [veth]
 [<ffffffff8147f84c>] ? rtnl_newlink+0x73c/0x8e0
 [<ffffffff8147f27a>] ? rtnl_newlink+0x16a/0x8e0
 [<ffffffff81459ff2>] ? __kmalloc_reserve.isra.30+0x32/0x90
 [<ffffffff8147ccfd>] ? rtnetlink_rcv_msg+0x8d/0x250
 [<ffffffff8145b027>] ? __alloc_skb+0x47/0x1f0
 [<ffffffff8149badb>] ? __netlink_lookup+0xab/0xe0
 [<ffffffff8147cc70>] ? rtnetlink_rcv+0x30/0x30
 [<ffffffff8149e7a0>] ? netlink_rcv_skb+0xb0/0xd0
 [<ffffffff8147cc64>] ? rtnetlink_rcv+0x24/0x30
 [<ffffffff8149df17>] ? netlink_unicast+0x107/0x1a0
 [<ffffffff8149e4be>] ? netlink_sendmsg+0x50e/0x630
 [<ffffffff8145209c>] ? sock_sendmsg+0x3c/0x50
 [<ffffffff81452beb>] ? ___sys_sendmsg+0x27b/0x290
 [<ffffffff811bd258>] ? mem_cgroup_try_charge+0x88/0x110
 [<ffffffff811bd5b6>] ? mem_cgroup_commit_charge+0x56/0xa0
 [<ffffffff811d7700>] ? do_filp_open+0x30/0xa0
 [<ffffffff8145336e>] ? __sys_sendmsg+0x3e/0x80
 [<ffffffff8156c3f2>] ? system_call_fastpath+0x16/0x75

Fix this by unregistering the previous sysctl table (registered for
the path containing the original device name) and re-registering the
table for the path containing the new device name.

Fixes: 37bde79979c3 ("mpls: Per-device enabling of packet input")
Reported-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index bff427f31924..1f93a5978f2a 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -564,6 +564,17 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 	case NETDEV_UNREGISTER:
 		mpls_ifdown(dev);
 		break;
+	case NETDEV_CHANGENAME:
+		mdev = mpls_dev_get(dev);
+		if (mdev) {
+			int err;
+
+			mpls_dev_sysctl_unregister(mdev);
+			err = mpls_dev_sysctl_register(dev, mdev);
+			if (err)
+				return notifier_from_errno(err);
+		}
+		break;
 	}
 	return NOTIFY_OK;
 }
-- 
2.1.4
