From: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC 7/7] genetlink: Add allocation flag to genlmsg_reply()
Date: Wed,  6 Jul 2016 09:28:36 +0900
Message-ID: <1467764916-4983-8-git-send-email-masashi.honma@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467764916-4983-1-git-send-email-masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add allocation flag to genlmsg_reply() and remove netlink_unicast()
temporal functionality for stepwise modification.

Signed-off-by: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/block/drbd/drbd_nl.c          |  2 +-
 drivers/net/wireless/mac80211_hwsim.c |  2 +-
 include/net/genetlink.h               |  7 +++++--
 kernel/taskstats.c                    |  2 +-
 net/core/devlink.c                    | 12 ++++++------
 net/ieee802154/ieee802154.h           |  3 ++-
 net/ieee802154/netlink.c              |  5 +++--
 net/ieee802154/nl-mac.c               |  4 ++--
 net/ieee802154/nl-phy.c               |  6 +++---
 net/ieee802154/nl802154.c             |  4 ++--
 net/ipv4/fou.c                        |  2 +-
 net/ipv4/tcp_metrics.c                |  2 +-
 net/ipv6/ila/ila_xlat.c               |  2 +-
 net/irda/irnetlink.c                  |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c        |  2 +-
 net/netlabel/netlabel_cipso_v4.c      |  2 +-
 net/netlabel/netlabel_mgmt.c          |  4 ++--
 net/netlabel/netlabel_unlabeled.c     |  2 +-
 net/netlink/af_netlink.c              |  2 +-
 net/netlink/genetlink.c               |  2 +-
 net/nfc/netlink.c                     |  6 +++---
 net/openvswitch/datapath.c            |  6 +++---
 net/tipc/bearer.c                     |  4 ++--
 net/tipc/node.c                       |  2 +-
 net/wireless/nl80211.c                | 34 +++++++++++++++++-----------------
 25 files changed, 63 insertions(+), 58 deletions(-)

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 0bac9c8..3162608 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -100,7 +100,7 @@ static char *drbd_m_holder = "Hands off! this is DRBD's meta data device.";
 static void drbd_adm_send_reply(struct sk_buff *skb, struct genl_info *info)
 {
 	genlmsg_end(skb, genlmsg_data(nlmsg_data(nlmsg_hdr(skb))));
-	if (genlmsg_reply(skb, info))
+	if (genlmsg_reply(skb, info, GFP_KERNEL))
 		pr_err("error sending genl reply\n");
 }
 
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 5c7bf77..5319cd1 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -3160,7 +3160,7 @@ static int hwsim_get_radio_nl(struct sk_buff *msg, struct genl_info *info)
 			goto out_err;
 		}
 
-		genlmsg_reply(skb, info);
+		genlmsg_reply(skb, info, GFP_KERNEL);
 		break;
 	}
 
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 5f0f2ff..99c9c39 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -343,10 +343,13 @@ static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb,
  * genlmsg_reply - reply to a request
  * @skb: netlink message to be sent back
  * @info: receiver information
+ * @flags: allocation flags
  */
-static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info)
+static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info,
+				gfp_t flags)
 {
-	return genlmsg_unicast(genl_info_net(info), skb, info->snd_portid, 0);
+	return genlmsg_unicast(genl_info_net(info), skb, info->snd_portid,
+			       flags);
 }
 
 /**
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index ecfcaff..894d0da 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -114,7 +114,7 @@ static int send_reply(struct sk_buff *skb, struct genl_info *info)
 
 	genlmsg_end(skb, reply);
 
-	return genlmsg_reply(skb, info);
+	return genlmsg_reply(skb, info, GFP_KERNEL);
 }
 
 /*
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 933e8d4..61a1c8a 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -501,7 +501,7 @@ static int devlink_nl_cmd_get_doit(struct sk_buff *skb, struct genl_info *info)
 		return err;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int devlink_nl_cmd_get_dumpit(struct sk_buff *msg,
@@ -554,7 +554,7 @@ static int devlink_nl_cmd_port_get_doit(struct sk_buff *skb,
 		return err;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int devlink_nl_cmd_port_get_dumpit(struct sk_buff *msg,
@@ -736,7 +736,7 @@ static int devlink_nl_cmd_sb_get_doit(struct sk_buff *skb,
 		return err;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int devlink_nl_cmd_sb_get_dumpit(struct sk_buff *msg,
@@ -843,7 +843,7 @@ static int devlink_nl_cmd_sb_pool_get_doit(struct sk_buff *skb,
 		return err;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int __sb_pool_get_dumpit(struct sk_buff *msg, int start, int *p_idx,
@@ -1030,7 +1030,7 @@ static int devlink_nl_cmd_sb_port_pool_get_doit(struct sk_buff *skb,
 		return err;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int __sb_port_pool_get_dumpit(struct sk_buff *msg, int start, int *p_idx,
@@ -1233,7 +1233,7 @@ static int devlink_nl_cmd_sb_tc_pool_bind_get_doit(struct sk_buff *skb,
 		return err;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int __sb_tc_pool_bind_get_dumpit(struct sk_buff *msg,
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index a5d7515..76f81be 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -40,7 +40,8 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req);
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group);
 struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 					int flags, u8 req);
-int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info);
+int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info,
+			gfp_t flags);
 
 extern struct genl_family nl802154_family;
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index c8133c0..9a8779b 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -87,14 +87,15 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 	return msg;
 }
 
-int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
+int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info,
+			gfp_t flags)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(msg);
 	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, flags);
 }
 
 static const struct genl_ops ieee8021154_ops[] = {
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index d3cbb32..17b5797 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -435,7 +435,7 @@ int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info)
 
 	dev_put(dev);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 out_free:
 	nlmsg_free(msg);
 out_dev:
@@ -692,7 +692,7 @@ int ieee802154_llsec_getparams(struct sk_buff *skb, struct genl_info *info)
 
 	dev_put(dev);
 
-	return ieee802154_nl_reply(msg, info);
+	return ieee802154_nl_reply(msg, info, GFP_KERNEL);
 out_free:
 	nlmsg_free(msg);
 out_dev:
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 77d7301..4862fbe 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -110,7 +110,7 @@ int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info)
 
 	wpan_phy_put(phy);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 out_free:
 	nlmsg_free(msg);
 out_dev:
@@ -255,7 +255,7 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 
 	wpan_phy_put(phy);
 
-	return ieee802154_nl_reply(msg, info);
+	return ieee802154_nl_reply(msg, info, GFP_ATOMIC);
 
 dev_unregister:
 	rtnl_lock(); /* del_iface must be called with RTNL lock */
@@ -336,7 +336,7 @@ int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info)
 		goto nla_put_failure;
 	wpan_phy_put(phy);
 
-	return ieee802154_nl_reply(msg, info);
+	return ieee802154_nl_reply(msg, info, GFP_ATOMIC);
 
 nla_put_failure:
 	nlmsg_free(msg);
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 116187b..8d58da3 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -681,7 +681,7 @@ static int nl802154_get_wpan_phy(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static inline u64 wpan_dev_id(struct wpan_dev *wpan_dev)
@@ -918,7 +918,7 @@ static int nl802154_get_interface(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int nl802154_new_interface(struct sk_buff *skb, struct genl_info *info)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 321d57f..2bf8342 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -780,7 +780,7 @@ static int fou_nl_cmd_get_port(struct sk_buff *skb, struct genl_info *info)
 	if (ret < 0)
 		goto out_free;
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 out_free:
 	nlmsg_free(msg);
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index b617826..cb624c1 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1024,7 +1024,7 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto out_free;
 
 	genlmsg_end(msg, reply);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 nla_put_failure:
 	ret = -EMSGSIZE;
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index e6eca5f..2e008bf3 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -467,7 +467,7 @@ static int ila_nl_cmd_get_mapping(struct sk_buff *skb, struct genl_info *info)
 	if (ret < 0)
 		goto out_free;
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 out_free:
 	nlmsg_free(msg);
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index e15c40e..ffa5b5c 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -116,7 +116,7 @@ static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  err_out:
 	nlmsg_free(msg);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b..cccf673 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3760,7 +3760,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	genlmsg_end(msg, reply);
-	ret = genlmsg_reply(msg, info);
+	ret = genlmsg_reply(msg, info, GFP_KERNEL);
 	goto out;
 
 nla_put_failure:
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 7fd1104..c2b6fb5 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -590,7 +590,7 @@ list_start:
 	rcu_read_unlock();
 
 	genlmsg_end(ans_skb, data);
-	return genlmsg_reply(ans_skb, info);
+	return genlmsg_reply(ans_skb, info, GFP_KERNEL);
 
 list_retry:
 	/* XXX - this limit is a guesstimate */
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 13f777f..23099ee 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -577,7 +577,7 @@ static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
 		goto listdef_failure;
 
 	genlmsg_end(ans_skb, data);
-	return genlmsg_reply(ans_skb, info);
+	return genlmsg_reply(ans_skb, info, GFP_KERNEL);
 
 listdef_failure_lock:
 	rcu_read_unlock();
@@ -688,7 +688,7 @@ static int netlbl_mgmt_version(struct sk_buff *skb, struct genl_info *info)
 		goto version_failure;
 
 	genlmsg_end(ans_skb, data);
-	return genlmsg_reply(ans_skb, info);
+	return genlmsg_reply(ans_skb, info, GFP_KERNEL);
 
 version_failure:
 	kfree_skb(ans_skb);
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 9eaa9a1..bbe1337 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -874,7 +874,7 @@ static int netlbl_unlabel_list(struct sk_buff *skb, struct genl_info *info)
 		goto list_failure;
 
 	genlmsg_end(ans_skb, data);
-	return genlmsg_reply(ans_skb, info);
+	return genlmsg_reply(ans_skb, info, GFP_KERNEL);
 
 list_failure:
 	kfree_skb(ans_skb);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index acc1ee6..980cc86 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1227,7 +1227,7 @@ int netlink_unicast(struct sock *ssk, struct sk_buff *skb, u32 portid,
 	int err;
 	long timeo;
 
-	skb = netlink_trim(skb, allocation ? allocation : gfp_any());
+	skb = netlink_trim(skb, allocation);
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a09132a..1552380 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -933,7 +933,7 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(msg))
 		return PTR_ERR(msg);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int genl_ctrl_event(int event, struct genl_family *family,
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index ea023b3..052a5d1 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -772,7 +772,7 @@ static int nfc_genl_get_device(struct sk_buff *skb, struct genl_info *info)
 
 	nfc_put_device(dev);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 out_free:
 	nlmsg_free(msg);
@@ -1056,7 +1056,7 @@ exit:
 		return rc;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int nfc_genl_llc_set_params(struct sk_buff *skb, struct genl_info *info)
@@ -1653,7 +1653,7 @@ int nfc_vendor_cmd_reply(struct sk_buff *skb)
 	}
 
 	genlmsg_end(skb, hdr);
-	return genlmsg_reply(skb, dev->cur_cmd_info);
+	return genlmsg_reply(skb, dev->cur_cmd_info, gfp_any());
 }
 EXPORT_SYMBOL(nfc_vendor_cmd_reply);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 374e0ec..44a3cbc 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1274,7 +1274,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_unlock();
-	return genlmsg_reply(reply, info);
+	return genlmsg_reply(reply, info, GFP_KERNEL);
 unlock:
 	ovs_unlock();
 	return err;
@@ -1760,7 +1760,7 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	BUG_ON(err < 0);
 	ovs_unlock();
 
-	return genlmsg_reply(reply, info);
+	return genlmsg_reply(reply, info, GFP_KERNEL);
 
 err_unlock_free:
 	ovs_unlock();
@@ -2163,7 +2163,7 @@ static int ovs_vport_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	BUG_ON(err < 0);
 	rcu_read_unlock();
 
-	return genlmsg_reply(reply, info);
+	return genlmsg_reply(reply, info, GFP_KERNEL);
 
 exit_unlock_free:
 	rcu_read_unlock();
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 8584cc4..f00d355 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -763,7 +763,7 @@ int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	rtnl_unlock();
 
-	return genlmsg_reply(rep, info);
+	return genlmsg_reply(rep, info, GFP_KERNEL);
 err_out:
 	rtnl_unlock();
 	nlmsg_free(rep);
@@ -1022,7 +1022,7 @@ int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	rtnl_unlock();
 
-	return genlmsg_reply(rep, info);
+	return genlmsg_reply(rep, info, GFP_KERNEL);
 err_out:
 	rtnl_unlock();
 	nlmsg_free(rep);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index a3fc0a3..a86f21c 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1774,7 +1774,7 @@ int tipc_nl_node_get_link(struct sk_buff *skb, struct genl_info *info)
 		}
 	}
 
-	return genlmsg_reply(msg.skb, info);
+	return genlmsg_reply(msg.skb, info, GFP_KERNEL);
 }
 
 int tipc_nl_node_reset_link_stats(struct sk_buff *skb, struct genl_info *info)
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e608937..d8e1984 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1948,7 +1948,7 @@ static int nl80211_get_wiphy(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static const struct nla_policy txq_params_policy[NL80211_TXQ_ATTR_MAX + 1] = {
@@ -2574,7 +2574,7 @@ static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static const struct nla_policy mntr_flags_policy[NL80211_MNTR_FLAG_MAX + 1] = {
@@ -2833,7 +2833,7 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 	}
 
 out:
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
@@ -3007,7 +3007,7 @@ static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  nla_put_failure:
 	err = -ENOBUFS;
@@ -4050,7 +4050,7 @@ static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 int cfg80211_check_station_change(struct wiphy *wiphy,
@@ -4852,7 +4852,7 @@ static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int nl80211_set_mpath(struct sk_buff *skb, struct genl_info *info)
@@ -4957,7 +4957,7 @@ static int nl80211_get_mpp(struct sk_buff *skb, struct genl_info *info)
 		return -ENOBUFS;
 	}
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 }
 
 static int nl80211_dump_mpp(struct sk_buff *skb,
@@ -5234,7 +5234,7 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 		goto nla_put_failure;
 	nla_nest_end(msg, pinfoattr);
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -5672,7 +5672,7 @@ static int nl80211_get_reg_do(struct sk_buff *skb, struct genl_info *info)
 	rcu_read_unlock();
 
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 nla_put_failure_rcu:
 	rcu_read_unlock();
@@ -8485,7 +8485,7 @@ static int nl80211_remain_on_channel(struct sk_buff *skb,
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  nla_put_failure:
 	err = -ENOBUFS;
@@ -8897,7 +8897,7 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 			goto nla_put_failure;
 
 		genlmsg_end(msg, hdr);
-		return genlmsg_reply(msg, info);
+		return genlmsg_reply(msg, info, GFP_KERNEL);
 	}
 
 	return 0;
@@ -9007,7 +9007,7 @@ static int nl80211_get_power_save(struct sk_buff *skb, struct genl_info *info)
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  nla_put_failure:
 	err = -ENOBUFS;
@@ -9428,7 +9428,7 @@ static int nl80211_get_wowlan(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -9892,7 +9892,7 @@ static int nl80211_get_coalesce(struct sk_buff *skb, struct genl_info *info)
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
 nla_put_failure:
 	nlmsg_free(msg);
@@ -10185,7 +10185,7 @@ static int nl80211_probe_client(struct sk_buff *skb,
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  nla_put_failure:
 	err = -ENOBUFS;
@@ -10292,7 +10292,7 @@ static int nl80211_get_protocol_features(struct sk_buff *skb,
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	return genlmsg_reply(msg, info);
+	return genlmsg_reply(msg, info, GFP_KERNEL);
 
  nla_put_failure:
 	kfree_skb(msg);
@@ -10672,7 +10672,7 @@ int cfg80211_vendor_cmd_reply(struct sk_buff *skb)
 
 	nla_nest_end(skb, data);
 	genlmsg_end(skb, hdr);
-	return genlmsg_reply(skb, rdev->cur_cmd_info);
+	return genlmsg_reply(skb, rdev->cur_cmd_info, gfp_any());
 }
 EXPORT_SYMBOL_GPL(cfg80211_vendor_cmd_reply);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
