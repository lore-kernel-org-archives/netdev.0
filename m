From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v6 16/16] netlabel: Add configuration support for local
	labeling
Date: Tue, 16 Sep 2008 08:57:37 -0400
Message-ID: <20080916125737.17132.50669.stgit@flek.lan>
References: <20080916124722.17132.38741.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:34721 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbYIPM5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 08:57:45 -0400
In-Reply-To: <20080916124722.17132.38741.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the necessary NetLabel support for the new CIPSO mapping,
CIPSO_V4_MAP_LOCAL, which allows full LSM label/context support.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/netlabel.h           |    3 ++-
 net/netlabel/netlabel_cipso_v4.c |   41 ++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_cipso_v4.h |    6 ++++--
 net/netlabel/netlabel_kapi.c     |    3 +++
 4 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index d56517a..17c442a 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -72,7 +72,8 @@ struct cipso_v4_doi;
 /* NetLabel NETLINK protocol version
  *  1: initial version
  *  2: added static labels for unlabeled connections
- *  3: network selectors added to the NetLabel/LSM domain mapping
+ *  3: network selectors added to the NetLabel/LSM domain mapping and the
+ *     CIPSO_V4_MAP_LOCAL CIPSO mapping was added
  */
 #define NETLBL_PROTO_VERSION            3
 
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index a6dc5d1..aa87568 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -365,6 +365,43 @@ add_pass_failure:
 }
 
 /**
+ * netlbl_cipsov4_add_local - Adds a CIPSO V4 DOI definition
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Create a new CIPSO_V4_MAP_LOCAL DOI definition based on the given ADD
+ * message and add it to the CIPSO V4 engine.  Return zero on success and
+ * non-zero on error.
+ *
+ */
+static int netlbl_cipsov4_add_local(struct genl_info *info)
+{
+	int ret_val;
+	struct cipso_v4_doi *doi_def = NULL;
+
+	if (!info->attrs[NLBL_CIPSOV4_A_TAGLST])
+		return -EINVAL;
+
+	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
+	if (doi_def == NULL)
+		return -ENOMEM;
+	doi_def->type = CIPSO_V4_MAP_LOCAL;
+
+	ret_val = netlbl_cipsov4_add_common(info, doi_def);
+	if (ret_val != 0)
+		goto add_local_failure;
+
+	ret_val = cipso_v4_doi_add(doi_def);
+	if (ret_val != 0)
+		goto add_local_failure;
+	return 0;
+
+add_local_failure:
+	cipso_v4_doi_free(doi_def);
+	return ret_val;
+}
+
+/**
  * netlbl_cipsov4_add - Handle an ADD message
  * @skb: the NETLINK buffer
  * @info: the Generic NETLINK info block
@@ -401,6 +438,10 @@ static int netlbl_cipsov4_add(struct sk_buff *skb, struct genl_info *info)
 		type_str = "pass";
 		ret_val = netlbl_cipsov4_add_pass(info);
 		break;
+	case CIPSO_V4_MAP_LOCAL:
+		type_str = "local";
+		ret_val = netlbl_cipsov4_add_local(info);
+		break;
 	}
 	if (ret_val == 0)
 		atomic_inc(&netlabel_mgmt_protocount);
diff --git a/net/netlabel/netlabel_cipso_v4.h b/net/netlabel/netlabel_cipso_v4.h
index fb3957f..c8a4079 100644
--- a/net/netlabel/netlabel_cipso_v4.h
+++ b/net/netlabel/netlabel_cipso_v4.h
@@ -50,7 +50,8 @@
  *     NLBL_CIPSOV4_A_MLSLVLLST
  *     NLBL_CIPSOV4_A_MLSCATLST
  *
- *   If using CIPSO_V4_MAP_PASS no additional attributes are required.
+ *   If using CIPSO_V4_MAP_PASS or CIPSO_V4_MAP_LOCAL no additional attributes
+ *   are required.
  *
  * o REMOVE:
  *   Sent by an application to remove a specific DOI mapping table from the
@@ -81,7 +82,8 @@
  *     NLBL_CIPSOV4_A_MLSLVLLST
  *     NLBL_CIPSOV4_A_MLSCATLST
  *
- *   If using CIPSO_V4_MAP_PASS no additional attributes are required.
+ *   If using CIPSO_V4_MAP_PASS or CIPSO_V4_MAP_LOCAL no additional attributes
+ *   are required.
  *
  * o LISTALL:
  *   This message is sent by an application to list the valid DOIs on the
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index 8435b15..b32eceb 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -163,6 +163,9 @@ cfg_cipsov4_add_map_return:
 		case CIPSO_V4_MAP_PASS:
 			type_str = "pass";
 			break;
+		case CIPSO_V4_MAP_LOCAL:
+			type_str = "local";
+			break;
 		default:
 			type_str = "(unknown)";
 		}

