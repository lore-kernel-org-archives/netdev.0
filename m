From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 9758] New: net_device refcnt bug when NFQUEUEing
 bridged packets
Date: Wed, 16 Jan 2008 05:54:13 +0100
Message-ID: <478D8DF5.7080901@trash.net>
References: <bug-9758-10286@http.bugzilla.kernel.org/> <20080115155655.d1a24eaf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020902030108020702040900"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: jckn@gmx.net,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080115155655.d1a24eaf.akpm@linux-foundation.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020902030108020702040900
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> On Tue, 15 Jan 2008 15:28:31 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=9758
>>
>> The bug is probably around since the combination bridge+NFQUEUE is possible,
>> and does not depend on distro or environment:
>>
>> Packets that are to be sent out over a bridge device are skb_clone()d in
>> br_loop() before traversing the appropriate (FORWARD/OUTPUT) NF chain.
>> The copies made by skb_clone() share their nf_bridge metadata with the
>> original, which is no problem usually.
>> If however one or more packets of a br_loop() run end up in a NFQUEUE,
>> their shared nf_bridge metadata causes trouble when they are about to be
>> reinjected: nf_reinject() decrements the net_device refcounts that were
>> previously upped when queueing the packet in __nf_queue(), but as
>> skb->nf_bridge->physoutdev points to the same device for all these
>> packets, most (if not all) of them will affect the wrong refcnt.
>>
>> (I originally encountered the bug on a Xen host because the hypervisor
>> refused to shutdown a virtual device with non-zero refcount... but it is
>> perfectly reproducible with a standard kernel, too, although it was a
>> bit more tedious to create a test scenario, involving a couple of UMLs.)
>>
>> I'd suggest to make a real copy of the nf_bridge member in br_loop() if
>> CONFIG_BRIDGE_NETFILTER is defined, remedying the entanglement. I'd go ahead
>> and create a patch, but I'm unsure as to where that logic should be
>> implemented.


Very nice catch, that explains quite a few bug reports about
refcnt leaks. Your patch looks correct and performs the copying
in the logically correct place, it would be nicer to keep this
crap limited to bridge netfilter however.

What should work is to perform the copying in br_netfilter.c
at the spots where phsyoutdev is assigned. As an optimization
we should be able to avoid the copying in most cases by
checking that the bridge info has a refcount above 1.

Could you test whether this patch also fixes the problem?



--------------020902030108020702040900
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 0e884fe..9759bd7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -142,6 +142,22 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
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
@@ -637,6 +653,11 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
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
@@ -718,6 +739,11 @@ static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff *skb,
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

--------------020902030108020702040900--
