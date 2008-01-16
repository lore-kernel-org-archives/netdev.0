From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 9758] New: net_device refcnt bug when NFQUEUEing
 bridged packets
Date: Wed, 16 Jan 2008 05:59:21 +0100
Message-ID: <478D8F29.5040703@trash.net>
References: <bug-9758-10286@http.bugzilla.kernel.org/> <20080115155655.d1a24eaf.akpm@linux-foundation.org> <478D8DF5.7080901@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030900000204070809060202"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: jckn@gmx.net,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <478D8DF5.7080901@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030900000204070809060202
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Very nice catch, that explains quite a few bug reports about
> refcnt leaks. Your patch looks correct and performs the copying
> in the logically correct place, it would be nicer to keep this
> crap limited to bridge netfilter however.
> 
> What should work is to perform the copying in br_netfilter.c
> at the spots where phsyoutdev is assigned. As an optimization
> we should be able to avoid the copying in most cases by
> checking that the bridge info has a refcount above 1.
> 
> Could you test whether this patch also fixes the problem?


That patch had a bug, we need to set the refcount of the
new bridge info to 1 after performing the copy.


--------------030900000204070809060202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 0e884fe..141f069 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -142,6 +142,23 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 	return skb->nf_bridge;
 }
 
+static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+
+	if (atomic_read(&nf_bridge->use) > 1) {
+		struct nf_bridge_info *tmp = nf_bridge_alloc(skb);
+
+		if (tmp) {
+			memcpy(tmp, nf_bridge, sizeof(struct nf_bridge_info));
+			atomic_set(&tmp->use, 1);
+			nf_bridge_put(nf_bridge);
+		}
+		nf_bridge = tmp;
+	}
+	return nf_bridge;
+}
+
 static inline void nf_bridge_push_encap_header(struct sk_buff *skb)
 {
 	unsigned int len = nf_bridge_encap_header_len(skb);
@@ -637,6 +654,11 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	if (!skb->nf_bridge)
 		return NF_ACCEPT;
 
+	/* Need exclusive nf_bridge_info since we might have multiple
+	 * different physoutdevs. */
+	if (!nf_bridge_unshare(skb))
+		return NF_DROP;
+
 	parent = bridge_parent(out);
 	if (!parent)
 		return NF_DROP;
@@ -718,6 +740,11 @@ static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff *skb,
 	if (!skb->nf_bridge)
 		return NF_ACCEPT;
 
+	/* Need exclusive nf_bridge_info since we might have multiple
+	 * different physoutdevs. */
+	if (!nf_bridge_unshare(skb))
+		return NF_DROP;
+
 	nf_bridge = skb->nf_bridge;
 	if (!(nf_bridge->mask & BRNF_BRIDGED_DNAT))
 		return NF_ACCEPT;

--------------030900000204070809060202--
