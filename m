From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 7/8] dcbnl: Add implementations of dcbnl
	setapp/getapp commands
Date: Mon, 31 Aug 2009 15:33:40 -0700
Message-ID: <20090831223340.30995.21328.stgit@localhost.localdomain>
References: <20090831223110.30995.61162.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:55495 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751995AbZHaWeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:34:37 -0400
In-Reply-To: <20090831223110.30995.61162.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Implements the dcbnl netlink setapp/getapp pair. When a setapp/getapp
is received, dcbnl would just pass on to dcbnl_rtnl_op.setapp/getapp
that are supposed to be implemented by the low level drivers.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/dcb/dcbnl.c |  122 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 122 insertions(+), 0 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 4046468..e0879bf 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -544,6 +544,120 @@ static int dcbnl_setpfcstate(struct net_device *netdev, struct nlattr **tb,
 	return ret;
 }
 
+static int dcbnl_getapp(struct net_device *netdev, struct nlattr **tb,
+                        u32 pid, u32 seq, u16 flags)
+{
+	struct sk_buff *dcbnl_skb;
+	struct nlmsghdr *nlh;
+	struct dcbmsg *dcb;
+	struct nlattr *app_nest;
+	struct nlattr *app_tb[DCB_APP_ATTR_MAX + 1];
+	u16 id;
+	u8 up, idtype;
+	int ret = -EINVAL;
+
+	if (!tb[DCB_ATTR_APP] || !netdev->dcbnl_ops->getapp)
+		goto out;
+
+	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
+	                       dcbnl_app_nest);
+	if (ret)
+		goto out;
+
+	ret = -EINVAL;
+	/* all must be non-null */
+	if ((!app_tb[DCB_APP_ATTR_IDTYPE]) ||
+	    (!app_tb[DCB_APP_ATTR_ID]))
+		goto out;
+
+	/* either by eth type or by socket number */
+	idtype = nla_get_u8(app_tb[DCB_APP_ATTR_IDTYPE]);
+	if ((idtype != DCB_APP_IDTYPE_ETHTYPE) &&
+	    (idtype != DCB_APP_IDTYPE_PORTNUM))
+		goto out;
+
+	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
+	up = netdev->dcbnl_ops->getapp(netdev, idtype, id);
+
+	/* send this back */
+	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!dcbnl_skb)
+		goto out;
+
+	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, RTM_GETDCB, sizeof(*dcb), flags);
+	dcb = NLMSG_DATA(nlh);
+	dcb->dcb_family = AF_UNSPEC;
+	dcb->cmd = DCB_CMD_GAPP;
+
+	app_nest = nla_nest_start(dcbnl_skb, DCB_ATTR_APP);
+	ret = nla_put_u8(dcbnl_skb, DCB_APP_ATTR_IDTYPE, idtype);
+	if (ret)
+		goto out_cancel;
+
+	ret = nla_put_u16(dcbnl_skb, DCB_APP_ATTR_ID, id);
+	if (ret)
+		goto out_cancel;
+
+	ret = nla_put_u8(dcbnl_skb, DCB_APP_ATTR_PRIORITY, up);
+	if (ret)
+		goto out_cancel;
+
+	nla_nest_end(dcbnl_skb, app_nest);
+	nlmsg_end(dcbnl_skb, nlh);
+
+	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
+	if (ret)
+		goto nlmsg_failure;
+
+	goto out;
+
+out_cancel:
+	nla_nest_cancel(dcbnl_skb, app_nest);
+nlmsg_failure:
+	kfree_skb(dcbnl_skb);
+out:
+	return ret;
+}
+
+static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
+                        u32 pid, u32 seq, u16 flags)
+{
+	int ret = -EINVAL;
+	u16 id;
+	u8 up, idtype;
+	struct nlattr *app_tb[DCB_APP_ATTR_MAX + 1];
+
+	if (!tb[DCB_ATTR_APP] || !netdev->dcbnl_ops->setapp)
+		goto out;
+
+	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
+	                       dcbnl_app_nest);
+	if (ret)
+		goto out;
+
+	ret = -EINVAL;
+	/* all must be non-null */
+	if ((!app_tb[DCB_APP_ATTR_IDTYPE]) ||
+	    (!app_tb[DCB_APP_ATTR_ID]) ||
+	    (!app_tb[DCB_APP_ATTR_PRIORITY]))
+		goto out;
+
+	/* either by eth type or by socket number */
+	idtype = nla_get_u8(app_tb[DCB_APP_ATTR_IDTYPE]);
+	if ((idtype != DCB_APP_IDTYPE_ETHTYPE) &&
+	    (idtype != DCB_APP_IDTYPE_PORTNUM))
+		goto out;
+
+	id = nla_get_u16(app_tb[DCB_APP_ATTR_ID]);
+	up = nla_get_u8(app_tb[DCB_APP_ATTR_PRIORITY]);
+
+	ret = dcbnl_reply(netdev->dcbnl_ops->setapp(netdev, idtype, id, up),
+	                  RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
+	                  pid, seq, flags);
+out:
+	return ret;
+}
+
 static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlattr **tb,
                              u32 pid, u32 seq, u16 flags, int dir)
 {
@@ -1101,6 +1215,14 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		ret = dcbnl_bcn_setcfg(netdev, tb, pid, nlh->nlmsg_seq,
 		                       nlh->nlmsg_flags);
 		goto out;
+	case DCB_CMD_GAPP:
+		ret = dcbnl_getapp(netdev, tb, pid, nlh->nlmsg_seq,
+		                   nlh->nlmsg_flags);
+		goto out;
+	case DCB_CMD_SAPP:
+		ret = dcbnl_setapp(netdev, tb, pid, nlh->nlmsg_seq,
+		                   nlh->nlmsg_flags);
+		goto out;
 	default:
 		goto errout;
 	}

