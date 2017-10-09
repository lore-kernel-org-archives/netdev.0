From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v11] openvswitch: enable NSH support
Date: Mon, 9 Oct 2017 16:05:29 +0800
Message-ID: <20171009080528.GA52767@localhost.localdomain>
References: <1506668610-18505-1-git-send-email-yi.y.yang@intel.com>
	<20171002211308.03424ed6@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171002211308.03424ed6@griffin>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2017 at 03:13:08AM +0800, Jiri Benc wrote:
> On Fri, 29 Sep 2017 15:03:30 +0800, Yi Yang wrote:
> > --- a/include/net/nsh.h
> > +++ b/include/net/nsh.h
> > @@ -304,4 +304,7 @@ static inline void nsh_set_flags_ttl_len(struct nshhdr *nsh, u8 flags,
> >  			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
> >  }
> >  
> > +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *nh);
> 
> [...]
> > +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *src_nsh_hdr)
> 
> This is minor but since this patch will need a respin anyway, please
> name the variables in the forward declaration and here the same.

Sorry for late reply, I was taking vacation from Oct. 1 to Oct. 8. I will
change "nh" and "src_nsh_hdr" to "pushed_nsh" because there is
another nh inside of skb_push_nsh.

> 
> > +int skb_pop_nsh(struct sk_buff *skb)
> > +{
> > +	int err;
> > +	struct nshhdr *nsh_hdr = (struct nshhdr *)(skb->data);
> 
> Bad name of the variable, clashes with the nsh_hdr function. I pointed
> that out already.

Sorry for missing this, I just did change in one .c file, forgot to do
the same thing in other .c files.

> 
> > +	size_t length;
> > +	__be16 inner_proto;
> > +
> > +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> > +				       sizeof(struct nshhdr));
> 
> You assume that the skb starts at the NSH header, thus the
> skb_network_offset is completely unnecessary and introduces just
> another assumption on the caller. Also, the sizeof(struct nshhdr) is
> wrong: there's no guarantee that the header is not smaller or larger
> than that.
> 
> More importantly though, why do you need skb_ensure_writable? You don't
> write into the header. pkskb_may_pull is enough.
> 
> 	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
> 		return -ENOMEM;
> 	length = nsh_hdr_len(nsh_hdr);
> 	if (!pskb_may_pull(skb, length))
> 		return -ENOMEM;
> 

Thank you for pointing out this, your version is the best one.

> > +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> > +		   const struct nlattr *a)
> > +{
> > +	struct nshhdr *nh;
> > +	int err;
> > +	u8 flags;
> > +	u8 ttl;
> > +	int i;
> > +
> > +	struct ovs_key_nsh key;
> > +	struct ovs_key_nsh mask;
> > +
> > +	err = nsh_key_from_nlattr(a, &key, &mask);
> > +	if (err)
> > +		return err;
> > +
> > +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> > +				       sizeof(struct nshhdr));
> 
> I missed this before: this is wrong, too. You need to use the real
> header size, not sizeof(struct nshhdr). It should be computable from
> the flow key.

It will be better to use code you provided above.

> 
> > +		case OVS_ACTION_ATTR_PUSH_NSH: {
> > +			u8 buffer[NSH_HDR_MAX_LEN];
> > +			struct nshhdr *nh = (struct nshhdr *)buffer;
> > +
> > +			nsh_hdr_from_nlattr(nla_data(a), nh,
> > +					    NSH_HDR_MAX_LEN);
> > +			err = push_nsh(skb, key, (const struct nshhdr *)nh);
> 
> Is the cast to const really needed? It looks suspicious. If you added it
> because a compiler complained, it's even more suspicious.

You're right, it is ok after I remove "(const struct nshhdr *)".

> 
> > +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> > +{
> > +	struct nshhdr *nh;
> > +	unsigned int nh_ofs = skb_network_offset(skb);
> > +	u8 version, length;
> > +	int err;
> > +
> > +	err = check_header(skb, nh_ofs + NSH_BASE_HDR_LEN);
> > +	if (unlikely(err))
> > +		return err;
> > +
> > +	nh = nsh_hdr(skb);
> > +	version = nsh_get_ver(nh);
> > +	length = nsh_hdr_len(nh);
> > +
> > +	if (version != 0)
> > +		return -EINVAL;
> > +
> > +	err = check_header(skb, nh_ofs + length);
> > +	if (unlikely(err))
> > +		return err;
> > +
> > +	nh = (struct nshhdr *)skb_network_header(skb);
> 
> I really really really hate this. This is the third time I'm telling
> you to use the nsh_hdr function. Every time, you change only part of
> the places. And this one I even explicitly pointed out in the previous
> review.
> 
> I'm not supposed to look at my previous review to verify that you
> addressed everything. That's your responsibility. Yet I need to do it
> because every time, some of my comments remain unaddressed.

Sorry, it is a missing change, accumulated comments overwhelmed this.

> 
> > +int nsh_hdr_from_nlattr(const struct nlattr *attr,
> > +			struct nshhdr *nh, size_t size)
> > +{
> > +	struct nlattr *a;
> > +	int rem;
> > +	u8 flags = 0;
> > +	u8 ttl = 0;
> > +	int mdlen = 0;
> > +
> > +	/* validate_nsh has check this, so we needn't do duplicate check here
> > +	 */
> > +	nla_for_each_nested(a, attr, rem) {
> > +		int type = nla_type(a);
> > +
> > +		switch (type) {
> > +		case OVS_NSH_KEY_ATTR_BASE: {
> > +			const struct ovs_nsh_key_base *base = nla_data(a);
> > +
> > +			flags = base->flags;
> > +			ttl = base->ttl;
> > +			nh->np = base->np;
> > +			nh->mdtype = base->mdtype;
> > +			nh->path_hdr = base->path_hdr;
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD1: {
> > +			const struct ovs_nsh_key_md1 *md1 = nla_data(a);
> > +
> > +			mdlen = nla_len(a);
> > +			memcpy(&nh->md1, md1, mdlen);
> > +			break;
> 
> Looks better. Why not simplify it even more?
> 
> 		case OVS_NSH_KEY_ATTR_MD1:
> 			mdlen = nla_len(a);
> 			memcpy(&nh->md1, nla_data(a), mdlen);
> 			break;
> 
> It's still perfectly readable this way and there's no need for the
> braces.

> 
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD2: {
> > +			const struct u8 *md2 = nla_data(a);
> > +
> > +			mdlen = nla_len(a);
> > +			memcpy(&nh->md2, md2, mdlen);
> 
> And here, too.

Yes, the code you provided is better.

> 
> > +int nsh_key_from_nlattr(const struct nlattr *attr,
> > +			struct ovs_key_nsh *nsh, struct ovs_key_nsh *nsh_mask)
> > +{
> > +	struct nlattr *a;
> > +	int rem;
> > +
> > +	/* validate_nsh has check this, so we needn't do duplicate check here
> > +	 */
> > +	nla_for_each_nested(a, attr, rem) {
> > +		int type = nla_type(a);
> > +
> > +		switch (type) {
> > +		case OVS_NSH_KEY_ATTR_BASE: {
> > +			const struct ovs_nsh_key_base *base = nla_data(a);
> > +			const struct ovs_nsh_key_base *base_mask = base + 1;
> > +
> > +			nsh->base = *base;
> > +			nsh_mask->base = *base_mask;
> > +			break;
> > +		}
> > +		case OVS_NSH_KEY_ATTR_MD1: {
> > +			const struct ovs_nsh_key_md1 *md1 =
> > +				(struct ovs_nsh_key_md1 *)nla_data(a);
> 
> I'm speechless.
> 
> Yes, I don't like the line above. For a reason that I already pointed
> out.
> 
> I expected more of this version.

Sorry, these are also missing changes, I remember I did global change
about this comment, it is my bad.

Here is incremental patch against v11, I'll send out v12 if you haven't
more comments about this.

diff -u b/include/net/nsh.h b/include/net/nsh.h
--- b/include/net/nsh.h
+++ b/include/net/nsh.h
@@ -304,7 +304,7 @@
 			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
 }
 
-int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *nh);
+int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *pushed_nh);
 int skb_pop_nsh(struct sk_buff *skb);
 
 #endif /* __NET_NSH_H */
diff -u b/net/nsh/nsh.c b/net/nsh/nsh.c
--- b/net/nsh/nsh.c
+++ b/net/nsh/nsh.c
@@ -14,10 +14,10 @@
 #include <net/nsh.h>
 #include <net/tun_proto.h>
 
-int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *src_nsh_hdr)
+int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *pushed_nh)
 {
-	struct nshhdr *nsh_hdr;
-	size_t length = nsh_hdr_len(src_nsh_hdr);
+	struct nshhdr *nh;
+	size_t length = nsh_hdr_len(pushed_nh);
 	u8 next_proto;
 
 	if (skb->mac_len) {
@@ -33,9 +33,9 @@
 		return -ENOMEM;
 
 	skb_push(skb, length);
-	nsh_hdr = (struct nshhdr *)(skb->data);
-	memcpy(nsh_hdr, src_nsh_hdr, length);
-	nsh_hdr->np = next_proto;
+	nh = (struct nshhdr *)(skb->data);
+	memcpy(nh, pushed_nh, length);
+	nh->np = next_proto;
 
 	skb->protocol = htons(ETH_P_NSH);
 	skb_reset_mac_header(skb);
@@ -48,21 +48,23 @@
 
 int skb_pop_nsh(struct sk_buff *skb)
 {
-	int err;
-	struct nshhdr *nsh_hdr = (struct nshhdr *)(skb->data);
+	struct nshhdr *nh;
 	size_t length;
 	__be16 inner_proto;
 
-	err = skb_ensure_writable(skb, skb_network_offset(skb) +
-				       sizeof(struct nshhdr));
-	if (unlikely(err))
-		return err;
+	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
+		return -ENOMEM;
+	nh = (struct nshhdr *)(skb->data);
+	length = nsh_hdr_len(nh);
+	if (!pskb_may_pull(skb, length))
+		return -ENOMEM;
 
-	inner_proto = tun_p_to_eth_p(nsh_hdr->np);
+	nh = (struct nshhdr *)(skb->data);
+	inner_proto = tun_p_to_eth_p(nh->np);
 	if (!inner_proto)
 		return -EAFNOSUPPORT;
 
-	length = nsh_hdr_len(nsh_hdr);
+	length = nsh_hdr_len(nh);
 	skb_pull(skb, length);
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
diff -u b/net/openvswitch/actions.c b/net/openvswitch/actions.c
--- b/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -644,6 +644,7 @@
 		   const struct nlattr *a)
 {
 	struct nshhdr *nh;
+	size_t length;
 	int err;
 	u8 flags;
 	u8 ttl;
@@ -656,13 +657,22 @@
 	if (err)
 		return err;
 
+	/* Make sure the NSH base header is there */
 	err = skb_ensure_writable(skb, skb_network_offset(skb) +
-				       sizeof(struct nshhdr));
+				       NSH_BASE_HDR_LEN);
 	if (unlikely(err))
 		return err;
 
 	nh = nsh_hdr(skb);
+	length = nsh_hdr_len(nh);
 
+	/* Make sure the whole NSH header is there */
+	err = skb_ensure_writable(skb, skb_network_offset(skb) +
+				       length);
+	if (unlikely(err))
+		return err;
+
+	nh = nsh_hdr(skb);
 	flags = nsh_get_flags(nh);
 	flags = OVS_MASKED(flags, key.base.flags, mask.base.flags);
 	flow_key->nsh.base.flags = flags;
@@ -1312,7 +1322,7 @@
 
 			nsh_hdr_from_nlattr(nla_data(a), nh,
 					    NSH_HDR_MAX_LEN);
-			err = push_nsh(skb, key, (const struct nshhdr *)nh);
+			err = push_nsh(skb, key, nh);
 			break;
 		}
 
diff -u b/net/openvswitch/flow.c b/net/openvswitch/flow.c
--- b/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -513,7 +513,7 @@
 	if (unlikely(err))
 		return err;
 
-	nh = (struct nshhdr *)skb_network_header(skb);
+	nh = nsh_hdr(skb);
 	key->nsh.base.flags = nsh_get_flags(nh);
 	key->nsh.base.ttl = nsh_get_ttl(nh);
 	key->nsh.base.mdtype = nh->mdtype;
diff -u b/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
--- b/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1233,20 +1233,16 @@
 			nh->path_hdr = base->path_hdr;
 			break;
 		}
-		case OVS_NSH_KEY_ATTR_MD1: {
-			const struct ovs_nsh_key_md1 *md1 = nla_data(a);
-
+		case OVS_NSH_KEY_ATTR_MD1:
 			mdlen = nla_len(a);
-			memcpy(&nh->md1, md1, mdlen);
+			memcpy(&nh->md1, nla_data(a), mdlen);
 			break;
-		}
-		case OVS_NSH_KEY_ATTR_MD2: {
-			const struct u8 *md2 = nla_data(a);
 
+		case OVS_NSH_KEY_ATTR_MD2:
 			mdlen = nla_len(a);
-			memcpy(&nh->md2, md2, mdlen);
+			memcpy(&nh->md2, nla_data(a), mdlen);
 			break;
-		}
+
 		default:
 			return -EINVAL;
 		}
@@ -1280,8 +1276,7 @@
 			break;
 		}
 		case OVS_NSH_KEY_ATTR_MD1: {
-			const struct ovs_nsh_key_md1 *md1 =
-				(struct ovs_nsh_key_md1 *)nla_data(a);
+			const struct ovs_nsh_key_md1 *md1 = nla_data(a);
 			const struct ovs_nsh_key_md1 *md1_mask = md1 + 1;
 
 			memcpy(nsh->context, md1->context, sizeof(*md1));
@@ -1339,8 +1334,7 @@
 
 		switch (type) {
 		case OVS_NSH_KEY_ATTR_BASE: {
-			const struct ovs_nsh_key_base *base =
-				(struct ovs_nsh_key_base *)nla_data(a);
+			const struct ovs_nsh_key_base *base = nla_data(a);
 
 			has_base = true;
 			mdtype = base->mdtype;
@@ -1357,8 +1351,7 @@
 			break;
 		}
 		case OVS_NSH_KEY_ATTR_MD1: {
-			const struct ovs_nsh_key_md1 *md1 =
-				(struct ovs_nsh_key_md1 *)nla_data(a);
+			const struct ovs_nsh_key_md1 *md1 = nla_data(a);
 
 			has_md1 = true;
 			for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++)
