From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/2] bonding: Manage /proc/net/bonding/ entries from the
	netdev events
Date: Mon, 09 Jul 2012 13:51:45 -0700
Message-ID: <87y5ms3bfi.fsf_-_@xmission.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
	<20120705220749.GA11255@mail.hallyn.com> <87ehopu3e5.fsf@xmission.com>
	<20120706170538.GA31679@mail.hallyn.com> <87fw94g1kq.fsf@xmission.com>
	<20120706194741.GA22113@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120706194741.GA22113-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 6 Jul 2012 19:47:41 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


It was recently reported that moving a bonding device between network
namespaces causes warnings from /proc.  It turns out after the move we
were trying to add and to remove the /proc/net/bonding entries from the
wrong network namespace.

Move the bonding /proc registration code into the NETDEV_REGISTER and
NETDEV_UNREGISTER events where the proc registration and unregistration
will always happen at the right time.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/bonding/bond_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ee8cf9..50de0fe 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3226,6 +3226,12 @@ static int bond_master_netdev_event(unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGENAME:
 		return bond_event_changename(event_bond);
+	case NETDEV_UNREGISTER:
+		bond_remove_proc_entry(event_bond);
+		break;
+	case NETDEV_REGISTER:
+		bond_create_proc_entry(event_bond);
+		break;
 	default:
 		break;
 	}
@@ -4410,8 +4416,6 @@ static void bond_uninit(struct net_device *bond_dev)
 
 	bond_work_cancel_all(bond);
 
-	bond_remove_proc_entry(bond);
-
 	bond_debug_unregister(bond);
 
 	__hw_addr_flush(&bond->mc_list);
@@ -4813,7 +4817,6 @@ static int bond_init(struct net_device *bond_dev)
 
 	bond_set_lockdep_class(bond_dev);
 
-	bond_create_proc_entry(bond);
 	list_add_tail(&bond->bond_list, &bn->dev_list);
 
 	bond_prepare_sysfs_group(bond);
-- 
1.7.5.4
