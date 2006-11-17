From: paul.moore@hp.com
Subject: [PATCH 06/13] NetLabel: add tag verification when adding new CIPSOv4 DOI definitions
Date: Fri, 17 Nov 2006 17:38:48 -0500
Message-ID: <20061117224334.423545000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:53145 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755990AbWKQWng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:36 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_add_verification
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Currently the CIPSOv4 engine does not do any sort of checking when a new DOI
definition is added.  The tags are still verified but only as a side effect of
normal NetLabel operation (packet processing, socket labeling, etc.) which
would cause application errors due to the faulty configuration.  This patch
adds tag checking when new DOI definition are added allowing us to catch these
configuration problems when they happen.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+)

Index: net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6.20_netlabel-base-work.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6.20_netlabel-base-work/net/ipv4/cipso_ipv4.c
@@ -448,8 +448,22 @@ static struct cipso_v4_doi *cipso_v4_doi
  */
 int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
 {
+	u32 iter;
+
 	if (doi_def == NULL || doi_def->doi == CIPSO_V4_DOI_UNKNOWN)
 		return -EINVAL;
+	for (iter = 0; iter < CIPSO_V4_TAG_MAXCNT; iter++) {
+		switch (doi_def->tags[iter]) {
+		case CIPSO_V4_TAG_RBITMAP:
+			break;
+		case CIPSO_V4_TAG_INVALID:
+			if (iter == 0)
+				return -EINVAL;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
 
 	doi_def->valid = 1;
 	INIT_RCU_HEAD(&doi_def->rcu);

--
paul moore
linux security @ hp
