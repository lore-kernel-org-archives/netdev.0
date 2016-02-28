From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 09/32] driver: component: Add support for empty match table
Date: Sun, 28 Feb 2016 17:41:17 +0100
Message-ID: <1456677700-23027-10-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44997 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758908AbcB1QnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:24 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before calling component_master_add_with_match(), matches should be
added using component_match_add() to the opaque match. How many
matches are added typically depends on the contents of the device
tree. It is not inconceivable that the number is zero, for example the
components are optional.

This results in calling component_master_add_with_match() passing a
NULL pointer for the match structure. The component infrastructure
does not like this. So handle the case by allocating a match with zero
entries.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/base/component.c | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/base/component.c b/drivers/base/component.c
index 89f5cf68d80a..36c4cf626fa8 100644
--- a/drivers/base/component.c
+++ b/drivers/base/component.c
@@ -237,6 +237,24 @@ static int component_match_realloc(struct device *dev,
 }
 
 /*
+ * Allocate a match array.
+ *
+ */
+static struct component_match *component_match_alloc(struct device *master)
+{
+	struct component_match *match;
+
+	match = devres_alloc(devm_component_match_release,
+				     sizeof(*match), GFP_KERNEL);
+	if (!match)
+		return ERR_PTR(-ENOMEM);
+
+	devres_add(master, match);
+
+	return match;
+}
+
+/*
  * Add a component to be matched, with a release function.
  *
  * The match array is first created or extended if necessary.
@@ -252,14 +270,9 @@ void component_match_add_release(struct device *master,
 		return;
 
 	if (!match) {
-		match = devres_alloc(devm_component_match_release,
-				     sizeof(*match), GFP_KERNEL);
-		if (!match) {
-			*matchptr = ERR_PTR(-ENOMEM);
+		match = component_match_alloc(master);
+		if (IS_ERR(match))
 			return;
-		}
-
-		devres_add(master, match);
 
 		*matchptr = match;
 	}
@@ -290,6 +303,12 @@ int component_master_add_with_match(struct device *dev,
 	struct master *master;
 	int ret;
 
+	if (!match) {
+		match = component_match_alloc(dev);
+		if (IS_ERR(match))
+			return PTR_ERR(match);
+	}
+
 	/* Reallocate the match array for its true size */
 	ret = component_match_realloc(dev, match, match->num);
 	if (ret)
-- 
2.7.0
