From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net ax25: Reorder ax25_exit to remove races.
Date: Wed, 18 Apr 2012 19:11:23 -0700
Message-ID: <m1hawgjws4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While reviewing the sysctl code in ax25 I spotted races in ax25_exit
where it is possible to receive notifications and packets after already
freeing up some of the data structures needed to process those
notifications and updates.

Call unregister_netdevice_notifier early so that the rest of the cleanup
code does not need to deal with network devices.  This takes advantage
of my recent enhancement to unregister_netdevice_notifier to send
unregister notifications of all network devices that are current
registered.

Move the unregistration for packet types, socket types and protocol
types before we cleanup any of the ax25 data structures to remove the
possibilities of other races.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ax25/af_ax25.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 0906c19..9d9a6a3 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -2011,16 +2011,17 @@ static void __exit ax25_exit(void)
 	proc_net_remove(&init_net, "ax25_route");
 	proc_net_remove(&init_net, "ax25");
 	proc_net_remove(&init_net, "ax25_calls");
-	ax25_rt_free();
-	ax25_uid_free();
-	ax25_dev_free();
 
-	ax25_unregister_sysctl();
 	unregister_netdevice_notifier(&ax25_dev_notifier);
+	ax25_unregister_sysctl();
 
 	dev_remove_pack(&ax25_packet_type);
 
 	sock_unregister(PF_AX25);
 	proto_unregister(&ax25_proto);
+
+	ax25_rt_free();
+	ax25_uid_free();
+	ax25_dev_free();
 }
 module_exit(ax25_exit);
-- 
1.7.2.5

