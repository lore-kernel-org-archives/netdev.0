From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 2/4] ieee80211: removal of unneeded checks
Date: Mon, 14 Feb 2005 00:25:59 +0100
Message-ID: <20050213232559.GA2898@electric-eye.fr.zoreil.com>
References: <420FBAD3.3020909@pobox.com> <20050213232421.GB2060@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>,
        Randy Dunlap <rddunlap@osdl.org>,
        James Ketrenos <jketreno@linux.intel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050213232421.GB2060@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove several checks before free/undo.

It turns out that crypto_free_tfm() did not need to be issued
in ieee80211_ccmp_init() nor in prism2_wep_init().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN net/ieee80211/ieee80211_crypt_ccmp.c~80211-010 net/ieee80211/ieee80211_crypt_ccmp.c
--- a/net/ieee80211/ieee80211_crypt_ccmp.c~80211-010	2005-02-13 23:39:29.137921826 +0100
+++ b/net/ieee80211/ieee80211_crypt_ccmp.c	2005-02-13 23:39:59.957874980 +0100
@@ -81,7 +81,7 @@ static void * ieee80211_ccmp_init(int ke
 
 	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
 	if (priv == NULL)
-		goto fail;
+		goto out;
 	memset(priv, 0, sizeof(*priv));
 	priv->key_idx = key_idx;
 
@@ -89,19 +89,11 @@ static void * ieee80211_ccmp_init(int ke
 	if (priv->tfm == NULL) {
 		printk(KERN_DEBUG "ieee80211_crypt_ccmp: could not allocate "
 		       "crypto API aes\n");
-		goto fail;
-	}
-
-	return priv;
-
-fail:
-	if (priv) {
-		if (priv->tfm)
-			crypto_free_tfm(priv->tfm);
 		kfree(priv);
+		priv = NULL;
 	}
-
-	return NULL;
+out:
+	return priv;
 }
 
 
diff -puN net/ieee80211/ieee80211_crypt_tkip.c~80211-010 net/ieee80211/ieee80211_crypt_tkip.c
--- a/net/ieee80211/ieee80211_crypt_tkip.c~80211-010	2005-02-13 23:39:29.140921334 +0100
+++ b/net/ieee80211/ieee80211_crypt_tkip.c	2005-02-14 00:10:37.681957335 +0100
@@ -67,37 +67,35 @@ static void * ieee80211_tkip_init(int ke
 	struct ieee80211_tkip_data *priv;
 
 	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
-	if (priv == NULL)
-		goto fail;
-	memset(priv, 0, sizeof(*priv));
-	priv->key_idx = key_idx;
-
-	priv->tfm_arc4 = crypto_alloc_tfm("arc4", 0);
-	if (priv->tfm_arc4 == NULL) {
-		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
-		       "crypto API arc4\n");
-		goto fail;
-	}
-
-	priv->tfm_michael = crypto_alloc_tfm("michael_mic", 0);
-	if (priv->tfm_michael == NULL) {
-		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
-		       "crypto API michael_mic\n");
-		goto fail;
-	}
-
-	return priv;
-
-fail:
 	if (priv) {
-		if (priv->tfm_michael)
-			crypto_free_tfm(priv->tfm_michael);
-		if (priv->tfm_arc4)
-			crypto_free_tfm(priv->tfm_arc4);
-		kfree(priv);
+		struct {
+			struct crypto_tfm **tfm;
+			char *name;
+		} tab[] = {
+			{ &priv->tfm_arc4,	"arc4" },
+			{ &priv->tfm_michael,	"michael_mic" },
+			{ NULL,			NULL }
+		}, *p;
+
+		memset(priv, 0, sizeof(*priv));
+		priv->key_idx = key_idx;
+
+		for (p = tab; p->name; p++) {
+			*p->tfm = crypto_alloc_tfm(p->name, 0);
+			if (!*p->tfm) {
+				printk(KERN_DEBUG "ieee80211_crypt_tkip: "
+				       "could not allocate crypto API %s\n",
+				       p->name);
+				while (p-- != tab)
+					crypto_free_tfm(*p->tfm);
+				kfree(priv);
+				priv = NULL;
+				break;
+			}
+		}
 	}
 
-	return NULL;
+	return priv;
 }
 
 
diff -puN net/ieee80211/ieee80211_crypt_wep.c~80211-010 net/ieee80211/ieee80211_crypt_wep.c
--- a/net/ieee80211/ieee80211_crypt_wep.c~80211-010	2005-02-13 23:39:29.143920843 +0100
+++ b/net/ieee80211/ieee80211_crypt_wep.c	2005-02-13 23:39:29.148920025 +0100
@@ -45,30 +45,24 @@ static void * prism2_wep_init(int keyidx
 	struct prism2_wep_data *priv;
 
 	priv = kmalloc(sizeof(*priv), GFP_ATOMIC);
-	if (priv == NULL)
-		goto fail;
+	if (!priv)
+		goto out;
 	memset(priv, 0, sizeof(*priv));
 	priv->key_idx = keyidx;
 
 	priv->tfm = crypto_alloc_tfm("arc4", 0);
-	if (priv->tfm == NULL) {
+	if (!priv->tfm) {
 		printk(KERN_DEBUG "ieee80211_crypt_wep: could not allocate "
 		       "crypto API arc4\n");
-		goto fail;
+		kfree(priv);
+		priv = NULL;
+		goto out;
 	}
 
 	/* start WEP IV from a random value */
 	get_random_bytes(&priv->iv, 4);
-
+out:
 	return priv;
-
-fail:
-	if (priv) {
-		if (priv->tfm)
-			crypto_free_tfm(priv->tfm);
-		kfree(priv);
-	}
-	return NULL;
 }
 
 

_
