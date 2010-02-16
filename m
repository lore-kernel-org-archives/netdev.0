From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 62/62: CONFIG_COMPAT: allow delta to exceed 32767
Date: Tue, 16 Feb 2010 15:56:44 +0100 (MET)
Message-ID: <20100216145641.2796.7827.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 3e5e524ffb5fcf2447eb5dd9f8e54ad22dd9baa7
Author: Florian Westphal <fwestphal@astaro.com>
Date:   Mon Feb 15 18:17:10 2010 +0100

    netfilter: CONFIG_COMPAT: allow delta to exceed 32767
    
    with 32 bit userland and 64 bit kernels, it is unlikely but possible
    that insertion of new rules fails even tough there are only about 2000
    iptables rules.
    
    This happens because the compat delta is using a short int.
    Easily reproducible via "iptables -m limit" ; after about 2050
    rules inserting new ones fails with -ELOOP.
    
    Note that compat_delta included 2 bytes of padding on x86_64, so
    structure size remains the same.
    
    Signed-off-by: Florian Westphal <fw@strlen.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index c61758f..a18119f 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -588,7 +588,7 @@ extern void xt_compat_unlock(u_int8_t af);
 
 extern int xt_compat_add_offset(u_int8_t af, unsigned int offset, short delta);
 extern void xt_compat_flush_offsets(u_int8_t af);
-extern short xt_compat_calc_jump(u_int8_t af, unsigned int offset);
+extern int xt_compat_calc_jump(u_int8_t af, unsigned int offset);
 
 extern int xt_compat_match_offset(const struct xt_match *match);
 extern int xt_compat_match_from_user(struct xt_entry_match *m,
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 69c5628..0a12ced 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -39,7 +39,7 @@ MODULE_DESCRIPTION("{ip,ip6,arp,eb}_tables backend module");
 struct compat_delta {
 	struct compat_delta *next;
 	unsigned int offset;
-	short delta;
+	int delta;
 };
 
 struct xt_af {
@@ -439,10 +439,10 @@ void xt_compat_flush_offsets(u_int8_t af)
 }
 EXPORT_SYMBOL_GPL(xt_compat_flush_offsets);
 
-short xt_compat_calc_jump(u_int8_t af, unsigned int offset)
+int xt_compat_calc_jump(u_int8_t af, unsigned int offset)
 {
 	struct compat_delta *tmp;
-	short delta;
+	int delta;
 
 	for (tmp = xt[af].compat_offsets, delta = 0; tmp; tmp = tmp->next)
 		if (tmp->offset < offset)
