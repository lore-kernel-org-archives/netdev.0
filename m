From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 14/17] net: Allow the userns root to control vlans.
Date: Fri, 16 Nov 2012 05:03:09 -0800
Message-ID: <1353070992-5552-14-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Allow an unpriviled user who has created a user namespace, and then
created a network namespace to effectively use the new network
namespace, by reducing capable(CAP_NET_ADMIN) and
capable(CAP_NET_RAW) calls to be ns_capable(net->user_ns,
CAP_NET_ADMIN), or capable(net->user_ns, CAP_NET_RAW) calls.

Allow the vlan ioctls:
SET_VLAN_INGRESS_PRIORITY_CMD
SET_VLAN_EGRESS_PRIORITY_CMD
SET_VLAN_FLAG_CMD
SET_VLAN_NAME_TYPE_CMD
ADD_VLAN_CMD
DEL_VLAN_CMD

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/8021q/vlan.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ee07072..4734260 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -529,7 +529,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 	switch (args.cmd) {
 	case SET_VLAN_INGRESS_PRIORITY_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		vlan_dev_set_ingress_priority(dev,
 					      args.u.skb_priority,
@@ -539,7 +539,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case SET_VLAN_EGRESS_PRIORITY_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = vlan_dev_set_egress_priority(dev,
 						   args.u.skb_priority,
@@ -548,7 +548,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case SET_VLAN_FLAG_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = vlan_dev_change_flags(dev,
 					    args.vlan_qos ? args.u.flag : 0,
@@ -557,7 +557,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case SET_VLAN_NAME_TYPE_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		if ((args.u.name_type >= 0) &&
 		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
@@ -573,14 +573,14 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case ADD_VLAN_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = register_vlan_device(dev, args.u.VID);
 		break;
 
 	case DEL_VLAN_CMD:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		unregister_vlan_dev(dev, NULL);
 		err = 0;
-- 
1.7.5.4
