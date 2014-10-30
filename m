From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 4/4] rtnl: allow to create device with
	IFLA_LINK_NETNSID set
Date: Thu, 30 Oct 2014 16:25:28 +0100
Message-ID: <1414682728-4532-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
	<1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1414682728-4532-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

This patch adds the ability to create a netdevice in a specified netns and
then move it into the final netns. In fact, it allows to have a symetry between
get and set rtnl messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 net/core/rtnetlink.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1b9329512496..57959a85ed2c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1211,6 +1211,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
+	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1983,7 +1984,7 @@ replay:
 		struct nlattr *slave_attr[m_ops ? m_ops->slave_maxtype + 1 : 0];
 		struct nlattr **data = NULL;
 		struct nlattr **slave_data = NULL;
-		struct net *dest_net;
+		struct net *dest_net, *link_net = NULL;
 
 		if (ops) {
 			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
@@ -2089,7 +2090,18 @@ replay:
 		if (IS_ERR(dest_net))
 			return PTR_ERR(dest_net);
 
-		dev = rtnl_create_link(dest_net, ifname, name_assign_type, ops, tb);
+		if (tb[IFLA_LINK_NETNSID]) {
+			int id = nla_get_s32(tb[IFLA_LINK_NETNSID]);
+
+			link_net = get_net_ns_by_id(dest_net, id);
+			if (link_net == NULL) {
+				err =  -EINVAL;
+				goto out;
+			}
+		}
+
+		dev = rtnl_create_link(link_net ? : dest_net, ifname,
+				       name_assign_type, ops, tb);
 		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
 			goto out;
@@ -2117,9 +2129,16 @@ replay:
 			}
 		}
 		err = rtnl_configure_link(dev, ifm);
-		if (err < 0)
+		if (err < 0) {
 			unregister_netdevice(dev);
+			goto out;
+		}
+
+		if (link_net)
+			err = dev_change_net_namespace(dev, dest_net, ifname);
 out:
+		if (link_net)
+			put_net(link_net);
 		put_net(dest_net);
 		return err;
 	}
-- 
2.1.0
