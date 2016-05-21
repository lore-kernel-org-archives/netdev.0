From: Baozeng Ding <sploving1@gmail.com>
Subject: [PATCH] net/tipc: fix potential null pointer dereference in several
 tipc netlink compat functions
Date: Sun, 22 May 2016 00:22:48 +0800
Message-ID: <6eb20dd0-0241-71d5-ee9e-0001db0301ba@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com, ying.xue@windriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33744 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbcEUQW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 12:22:57 -0400
Received: by mail-pa0-f68.google.com with SMTP id f8so1879174pag.0
        for <netdev@vger.kernel.org>; Sat, 21 May 2016 09:22:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before calling the nla_parse_nested funciton, its third argument should be
checked to make sure it is not null. This patch fixes several potential
null pointer dereference vulnerability in the tipc netlink functions.

Signed-off-by: Baozeng Ding <sploving1@gmail.com>
---
  net/tipc/netlink_compat.c | 111 
++++++++++++++++++++++++++++++++++++++--------
  1 file changed, 93 insertions(+), 18 deletions(-)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 4dfc5c1..959e989 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -345,10 +345,16 @@ static int tipc_nl_compat_doit(struct 
tipc_nl_compat_cmd_doit *cmd,
  static int tipc_nl_compat_bearer_dump(struct tipc_nl_compat_msg *msg,
                        struct nlattr **attrs)
  {
+    int err;
      struct nlattr *bearer[TIPC_NLA_BEARER_MAX + 1];

-    nla_parse_nested(bearer, TIPC_NLA_BEARER_MAX, attrs[TIPC_NLA_BEARER],
-             NULL);
+    if (!attrs[TIPC_NLA_BEARER])
+        return -EINVAL;
+
+    err = nla_parse_nested(bearer, TIPC_NLA_BEARER_MAX,
+                   attrs[TIPC_NLA_BEARER], NULL);
+    if (err)
+        return err;

      return tipc_add_tlv(msg->rep, TIPC_TLV_BEARER_NAME,
                  nla_data(bearer[TIPC_NLA_BEARER_NAME]),
@@ -456,18 +462,35 @@ static void __fill_bc_link_stat(struct 
tipc_nl_compat_msg *msg,
  static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
                       struct nlattr **attrs)
  {
+    int err;
      char *name;
      struct nlattr *link[TIPC_NLA_LINK_MAX + 1];
      struct nlattr *prop[TIPC_NLA_PROP_MAX + 1];
      struct nlattr *stats[TIPC_NLA_STATS_MAX + 1];

-    nla_parse_nested(link, TIPC_NLA_LINK_MAX, attrs[TIPC_NLA_LINK], NULL);
+    if (!attrs[TIPC_NLA_LINK])
+        return -EINVAL;

-    nla_parse_nested(prop, TIPC_NLA_PROP_MAX, link[TIPC_NLA_LINK_PROP],
-             NULL);
+    err = nla_parse_nested(link, TIPC_NLA_LINK_MAX,
+                   attrs[TIPC_NLA_LINK], NULL);
+    if (err)
+        return err;
+
+    if (!link[TIPC_NLA_LINK_PROP])
+        return -EINVAL;

-    nla_parse_nested(stats, TIPC_NLA_STATS_MAX, link[TIPC_NLA_LINK_STATS],
-             NULL);
+    err = nla_parse_nested(prop, TIPC_NLA_PROP_MAX,
+                   link[TIPC_NLA_LINK_PROP], NULL);
+    if (err)
+        return err;
+
+    if (!link[TIPC_NLA_LINK_STATS])
+        return -EINVAL;
+
+    err = nla_parse_nested(stats, TIPC_NLA_STATS_MAX,
+                   link[TIPC_NLA_LINK_STATS], NULL);
+    if (err)
+        return err;

      name = (char *)TLV_DATA(msg->req);
      if (strcmp(name, nla_data(link[TIPC_NLA_LINK_NAME])) != 0)
@@ -567,10 +590,17 @@ static int tipc_nl_compat_link_stat_dump(struct 
tipc_nl_compat_msg *msg,
  static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
                      struct nlattr **attrs)
  {
+    int err;
      struct nlattr *link[TIPC_NLA_LINK_MAX + 1];
      struct tipc_link_info link_info;

-    nla_parse_nested(link, TIPC_NLA_LINK_MAX, attrs[TIPC_NLA_LINK], NULL);
+    if (!attrs[TIPC_NLA_LINK])
+        return -EINVAL;
+
+    err = nla_parse_nested(link, TIPC_NLA_LINK_MAX,
+                   attrs[TIPC_NLA_LINK], NULL);
+    if (err)
+        return err;

      link_info.dest = nla_get_flag(link[TIPC_NLA_LINK_DEST]);
      link_info.up = htonl(nla_get_flag(link[TIPC_NLA_LINK_UP]));
@@ -751,6 +781,7 @@ static int 
tipc_nl_compat_name_table_dump_header(struct tipc_nl_compat_msg *msg)
  static int tipc_nl_compat_name_table_dump(struct tipc_nl_compat_msg *msg,
                        struct nlattr **attrs)
  {
+    int err;
      char port_str[27];
      struct tipc_name_table_query *ntq;
      struct nlattr *nt[TIPC_NLA_NAME_TABLE_MAX + 1];
@@ -759,11 +790,21 @@ static int tipc_nl_compat_name_table_dump(struct 
tipc_nl_compat_msg *msg,
      static const char * const scope_str[] = {"", " zone", " cluster",
                           " node"};

-    nla_parse_nested(nt, TIPC_NLA_NAME_TABLE_MAX,
-             attrs[TIPC_NLA_NAME_TABLE], NULL);
+    if (!attrs[TIPC_NLA_NAME_TABLE])
+        return -EINVAL;

-    nla_parse_nested(publ, TIPC_NLA_PUBL_MAX, nt[TIPC_NLA_NAME_TABLE_PUBL],
-             NULL);
+    err = nla_parse_nested(nt, TIPC_NLA_NAME_TABLE_MAX,
+                   attrs[TIPC_NLA_NAME_TABLE], NULL);
+    if (err)
+        return err;
+
+    if (!attrs[TIPC_NLA_NAME_TABLE])
+        return -EINVAL;
+
+    err = nla_parse_nested(publ, TIPC_NLA_PUBL_MAX,
+                   nt[TIPC_NLA_NAME_TABLE_PUBL], NULL);
+    if (err)
+        return err;

      ntq = (struct tipc_name_table_query *)TLV_DATA(msg->req);

@@ -813,10 +854,17 @@ out:
  static int __tipc_nl_compat_publ_dump(struct tipc_nl_compat_msg *msg,
                        struct nlattr **attrs)
  {
+    int err;
      u32 type, lower, upper;
      struct nlattr *publ[TIPC_NLA_PUBL_MAX + 1];

-    nla_parse_nested(publ, TIPC_NLA_PUBL_MAX, attrs[TIPC_NLA_PUBL], NULL);
+    if (!attrs[TIPC_NLA_PUBL])
+        return -EINVAL;
+
+    err = nla_parse_nested(publ, TIPC_NLA_PUBL_MAX,
+                   attrs[TIPC_NLA_PUBL], NULL);
+    if (err)
+        return err;

      type = nla_get_u32(publ[TIPC_NLA_PUBL_TYPE]);
      lower = nla_get_u32(publ[TIPC_NLA_PUBL_LOWER]);
@@ -876,7 +924,13 @@ static int tipc_nl_compat_sk_dump(struct 
tipc_nl_compat_msg *msg,
      u32 sock_ref;
      struct nlattr *sock[TIPC_NLA_SOCK_MAX + 1];

-    nla_parse_nested(sock, TIPC_NLA_SOCK_MAX, attrs[TIPC_NLA_SOCK], NULL);
+    if (!attrs[TIPC_NLA_SOCK])
+        return -EINVAL;
+
+    err = nla_parse_nested(sock, TIPC_NLA_SOCK_MAX,
+                   attrs[TIPC_NLA_SOCK], NULL);
+    if (err)
+        return err;

      sock_ref = nla_get_u32(sock[TIPC_NLA_SOCK_REF]);
      tipc_tlv_sprintf(msg->rep, "%u:", sock_ref);
@@ -916,10 +970,16 @@ static int tipc_nl_compat_sk_dump(struct 
tipc_nl_compat_msg *msg,
  static int tipc_nl_compat_media_dump(struct tipc_nl_compat_msg *msg,
                       struct nlattr **attrs)
  {
+    int err;
      struct nlattr *media[TIPC_NLA_MEDIA_MAX + 1];

-    nla_parse_nested(media, TIPC_NLA_MEDIA_MAX, attrs[TIPC_NLA_MEDIA],
-             NULL);
+    if (!attrs[TIPC_NLA_MEDIA])
+        return -EINVAL;
+
+    err = nla_parse_nested(media, TIPC_NLA_MEDIA_MAX, 
attrs[TIPC_NLA_MEDIA],
+                   NULL);
+    if (err)
+        return err;

      return tipc_add_tlv(msg->rep, TIPC_TLV_MEDIA_NAME,
                  nla_data(media[TIPC_NLA_MEDIA_NAME]),
@@ -929,10 +989,17 @@ static int tipc_nl_compat_media_dump(struct 
tipc_nl_compat_msg *msg,
  static int tipc_nl_compat_node_dump(struct tipc_nl_compat_msg *msg,
                      struct nlattr **attrs)
  {
+    int err;
      struct tipc_node_info node_info;
      struct nlattr *node[TIPC_NLA_NODE_MAX + 1];

-    nla_parse_nested(node, TIPC_NLA_NODE_MAX, attrs[TIPC_NLA_NODE], NULL);
+    if (!attrs[TIPC_NLA_NODE])
+        return -EINVAL;
+
+    err = nla_parse_nested(node, TIPC_NLA_NODE_MAX,
+                   attrs[TIPC_NLA_NODE], NULL);
+    if (err)
+        return err;

      node_info.addr = htonl(nla_get_u32(node[TIPC_NLA_NODE_ADDR]));
      node_info.up = htonl(nla_get_flag(node[TIPC_NLA_NODE_UP]));
@@ -969,10 +1036,18 @@ static int tipc_nl_compat_net_set(struct 
tipc_nl_compat_cmd_doit *cmd,
  static int tipc_nl_compat_net_dump(struct tipc_nl_compat_msg *msg,
                     struct nlattr **attrs)
  {
+    int err;
      __be32 id;
      struct nlattr *net[TIPC_NLA_NET_MAX + 1];

-    nla_parse_nested(net, TIPC_NLA_NET_MAX, attrs[TIPC_NLA_NET], NULL);
+    if (!attrs[TIPC_NLA_NET])
+        return -EINVAL;
+
+    err = nla_parse_nested(net, TIPC_NLA_NET_MAX,
+                   attrs[TIPC_NLA_NET], NULL);
+    if (err)
+        return err;
+
      id = htonl(nla_get_u32(net[TIPC_NLA_NET_ID]));

      return tipc_add_tlv(msg->rep, TIPC_TLV_UNSIGNED, &id, sizeof(id));
-- 
2.7.4
