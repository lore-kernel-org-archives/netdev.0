From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 1/8] genl: Add genlmsg_new_unicast() for
	unicast message allocation
Date: Thu, 21 Nov 2013 19:13:32 +0100
Message-ID: <6211632cd6702e312a2911edc9c5225978f81e8b.1385057355.git.tgraf@suug.ch>
References: <cover.1385057355.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1385057355.git.tgraf-G/eBtMaohhA@public.gmane.org>
In-Reply-To: <cover.1385057355.git.tgraf-G/eBtMaohhA@public.gmane.org>
References: <cover.1385057355.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Allocates a new sk_buff large enough to cover the specified payload
plus required Netlink headers. Will check receiving socket for
memory mapped i/o capability and use it if enabled. Will fall back
to non-mapped skb if message size exceeds the frame size of the ring.

Signed-of-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Reviewed-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/net/genetlink.h |  4 ++++
 net/netlink/genetlink.c | 21 +++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index ace4abf..1d50c6f 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -73,6 +73,7 @@ struct genl_family {
  * @attrs: netlink attributes
  * @_net: network namespace
  * @user_ptr: user pointers
+ * @dst_sk: destination socket
  */
 struct genl_info {
 	u32			snd_seq;
@@ -85,6 +86,7 @@ struct genl_info {
 	struct net *		_net;
 #endif
 	void *			user_ptr[2];
+	struct sock *		dst_sk;
 };
 
 static inline struct net *genl_info_net(struct genl_info *info)
@@ -177,6 +179,8 @@ void genl_notify(struct genl_family *family,
 		 struct sk_buff *skb, struct net *net, u32 portid,
 		 u32 group, struct nlmsghdr *nlh, gfp_t flags);
 
+struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
+				    gfp_t flags);
 void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 		  struct genl_family *family, int flags, u8 cmd);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 7dbc4f7..51bdc12 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -454,6 +454,26 @@ int genl_unregister_family(struct genl_family *family)
 EXPORT_SYMBOL(genl_unregister_family);
 
 /**
+ * genlmsg_new_unicast - Allocate generic netlink message for unicast
+ * @payload: size of the message payload
+ * @info: information on destination
+ * @flags: the type of memory to allocate
+ *
+ * Allocates a new sk_buff large enough to cover the specified payload
+ * plus required Netlink headers. Will check receiving socket for
+ * memory mapped i/o capability and use it if enabled. Will fall back
+ * to non-mapped skb if message size exceeds the frame size of the ring.
+ */
+struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
+				    gfp_t flags)
+{
+	size_t len = nlmsg_total_size(genlmsg_total_size(payload));
+
+	return netlink_alloc_skb(info->dst_sk, len, info->snd_portid, flags);
+}
+EXPORT_SYMBOL_GPL(genlmsg_new_unicast);
+
+/**
  * genlmsg_put - Add generic netlink header to netlink message
  * @skb: socket buffer holding the message
  * @portid: netlink portid the message is addressed to
@@ -593,6 +613,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = attrbuf;
+	info.dst_sk = skb->sk;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
-- 
1.8.3.1
