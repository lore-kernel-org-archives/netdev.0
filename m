From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 5/7] openvswitch: Add original direction
 conntrack tuple to sw_flow_key.
Date: Mon, 6 Feb 2017 23:15:14 -0800
Message-ID: <CAPWQB7Hhm+dVqaOxU-56wV6MmDJw70716ir7cUAnxNnWs_a1LA@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-5-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:45766 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGHPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:15:40 -0500
Received: from mfilter32-d.gandi.net (mfilter32-d.gandi.net [217.70.178.163])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 4B6711720A3
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 08:15:38 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter32-d.gandi.net (mfilter32-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 5HylPUl4rrDU for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 08:15:36 +0100 (CET)
Received: from mail-qt0-f169.google.com (mail-qt0-f169.google.com [209.85.216.169])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 237C1172093
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 08:15:35 +0100 (CET)
Received: by mail-qt0-f169.google.com with SMTP id v23so126993418qtb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:15:35 -0800 (PST)
In-Reply-To: <1486084206-109903-5-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
> Add the fields of the conntrack original direction 5-tuple to struct
> sw_flow_key.  The new fields are initially zeroed, and are populated
> whenever a conntrack action is executed and either finds or generates
> a conntrack entry.  This means that these fields exist for all packets
> were not rejected by conntrack as untrackable.
>
> The original tuple fields in the sw_flow_key are filled from the
> original direction tuple of the conntrack entry relating to the
> current packet, or from the original direction tuple of the master
> conntrack entry, if the current conntrack entry has a master.
> Generally, expected connections of connections having an assigned
> helper (e.g., FTP), have a master conntrack entry.
>
> The main purpose of the new conntrack original tuple fields is to
> allow matching on them for policy decision purposes, with the premise
> that the admissibility of tracked connections reply packets (as well
> as original direction packets), and both direction packets of any
> related connections may be based on ACL rules applying to the master
> connection's original direction 5-tuple.  This also makes it easier to
> make policy decisions when the actual packet headers might have been
> transformed by NAT, as the original direction 5-tuple represents the
> packet headers before any such transformation.
>
> When using the original direction 5-tuple the admissibility of return
> and/or related packets need not be based on the mere existence of a
> conntrack entry, allowing separation of admission policy from the
> established conntrack state.  While existence of a conntrack entry is
> required for admission of the return or related packets, policy
> changes can render connections that were initially admitted to be
> rejected or dropped afterwards.  If the admission of the return and
> related packets was based on mere conntrack state (e.g., connection
> being in an established state), a policy change that would make the
> connection rejected or dropped would need to find and delete all
> conntrack entries affected by such a change.  When using the original
> direction 5-tuple matching the affected conntrack entries can be
> allowed to time out instead, as the established state of the
> connection would not need to be the basis for packet admission any
> more.
>
> It should be noted that the directionality of related connections may
> be the same or different than that of the master connection, and
> neither the original direction 5-tuple nor the conntrack state bits
> carry this information.  If needed, the directionality of the master
> connection can be stored in master's conntrack mark or labels, which
> are automatically inherited by the expected related connections.
>
> The fact that neither ARP not ND packets are trackable by conntrack
> allows mutual exclusion between ARP/ND and the new conntrack original
> tuple fields.  Hence, the IP addresses are overlaid in union with ARP
> and ND fields.  This allows the sw_flow_key to not grow much due to
> this patch, but it also means that we must be careful to never use the
> new key fields with ARP or ND packets.  ARP is easy to distinguish and
> keep mutually exclusive based on the ethernet type, but ND being an
> ICMPv6 protocol requires a bit more attention.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---

OK, maybe we need to do something a bit more to handle the NATed
related connections to address the problem in patch 1.

<snip>

> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 738a4fa..1afe153 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -155,6 +155,59 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
>         key->ct.zone = zone->id;
>         key->ct.mark = ovs_ct_get_mark(ct);
>         ovs_ct_get_labels(ct, &key->ct.labels);
> +
> +       /* Use the master if we have one. */
> +       if (ct && ct->master)
> +               ct = ct->master;

Perhaps:

if (!ct || sw_flow_key_is_nd(key) || !is_ip_any(key->eth.type)) {
    /* zero everything */
    return;
}

One of the things this helps us to avoid is having a comment in the
middle of an if statement.

Then afterwards,
if (ct->master)
    ct = ct->master;

> +
> +       key->ct.orig_proto = 0;
> +       key->ct.orig_tp.src = 0;
> +       key->ct.orig_tp.dst = 0;
> +       if (key->eth.type == htons(ETH_P_IP)) {
> +               /* IP version must match. */
> +               if (ct && nf_ct_l3num(ct) == NFPROTO_IPV4) {

I don't quite understand how we could end up with a connection NFPROTO
that is mismatched with an IP version that we should handle here, but
if there are some legitimite cases perhaps we can pick them up and
handle them in the early exit condition above?

We can probably share a few more lines between IPv4 and IPv6 here.

> @@ -208,24 +261,54 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
>         ovs_ct_update_key(skb, NULL, key, false, false);
>  }
>
> -int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
> +#define IN6_ADDR_INITIALIZER(ADDR) \
> +       { (ADDR).s6_addr32[0], (ADDR).s6_addr32[1], \
> +         (ADDR).s6_addr32[2], (ADDR).s6_addr32[3] }

scripts/checkpatch.pl asks:

CHECK: Macro argument reuse 'ADDR' - possible side-effects?
#704: FILE: net/openvswitch/conntrack.c:264:
+#define IN6_ADDR_INITIALIZER(ADDR) \
+       { (ADDR).s6_addr32[0], (ADDR).s6_addr32[1], \
+         (ADDR).s6_addr32[2], (ADDR).s6_addr32[3] }

I'm guessing it just doesn't like your use of the name 'ADDR'.

> +       if (swkey->eth.type == htons(ETH_P_IP) && swkey->ct.orig_proto) {
> +               struct ovs_key_ct_tuple_ipv4 orig = {
> +                       output->ipv4.ct_orig.src,
> +                       output->ipv4.ct_orig.dst,
> +                       output->ct.orig_tp.src,
> +                       output->ct.orig_tp.dst,
> +                       output->ct.orig_proto,
> +               };
> +               if (nla_put(skb, OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4, sizeof(orig),
> +                           &orig))
> +                       return -EMSGSIZE;
> +       } else if (swkey->eth.type == htons(ETH_P_IPV6) &&
> +                  swkey->ct.orig_proto) {
> +               struct ovs_key_ct_tuple_ipv6 orig = {
> +                       IN6_ADDR_INITIALIZER(output->ipv6.ct_orig.src),
> +                       IN6_ADDR_INITIALIZER(output->ipv6.ct_orig.dst),
> +                       output->ct.orig_tp.src,
> +                       output->ct.orig_tp.dst,
> +                       output->ct.orig_proto,
> +               };
> +               if (nla_put(skb, OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6, sizeof(orig),
> +                           &orig))
> +                       return -EMSGSIZE;
> +       }

swkey->ct.orig_proto check is common across both conditions, maybe
check that first then nest the other logic within?

> +
>         return 0;
>  }
>
> diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
> index 8f6230b..8573ab3 100644
> --- a/net/openvswitch/conntrack.h
> +++ b/net/openvswitch/conntrack.h
> @@ -32,7 +32,8 @@ int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
>                    const struct ovs_conntrack_info *);
>
>  void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
> -int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
> +int ovs_ct_put_key(const struct sw_flow_key *swkey,
> +                  const struct sw_flow_key *output, struct sk_buff *skb);
>  void ovs_ct_free_action(const struct nlattr *a);
>
>  #define CT_SUPPORTED_MASK (OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED | \
> @@ -79,9 +80,17 @@ static inline void ovs_ct_fill_key(const struct sk_buff *skb,
>         key->ct.zone = 0;
>         key->ct.mark = 0;
>         memset(&key->ct.labels, 0, sizeof(key->ct.labels));
> +       key->ct.orig_proto = 0;
> +       key->ct.orig_tp.src = 0;
> +       key->ct.orig_tp.dst = 0;
> +       if (key->eth.type == htons(ETH_P_IP))
> +               memset(&key->ipv4.ct_orig, 0, sizeof(key->ipv4.ct_orig));
> +       else if (key->eth.type == htons(ETH_P_IPV6) && !sw_flow_key_is_nd(key))
> +               memset(&key->ipv6.ct_orig, 0, sizeof(key->ipv6.ct_orig));

If we only ever use these fields based on key->ct.orig_proto being
nonzero, then we m

<snip>

> +static inline bool sw_flow_key_is_nd(const struct sw_flow_key *key)
> +{
> +       return key->eth.type == htons(ETH_P_IPV6) &&
> +               key->ip.proto == NEXTHDR_ICMP &&
> +               key->tp.dst == 0 &&
> +               (key->tp.src == ntohs(NDISC_NEIGHBOUR_SOLICITATION) ||
> +                key->tp.src == ntohs(NDISC_NEIGHBOUR_ADVERTISEMENT));

Sparse complains:

net/openvswitch/flow.h:163:33: warning: cast to restricted __be16
net/openvswitch/flow.h:163:25: warning: restricted __be16 degrades to integer
net/openvswitch/flow.h:164:33: warning: cast to restricted __be16
net/openvswitch/flow.h:164:25: warning: restricted __be16 degrades to integer

> @@ -161,8 +163,11 @@ static bool match_validate(const struct sw_flow_match *match,
>
>         if (match->key->eth.type == htons(ETH_P_IP)) {
>                 key_expected |= 1 << OVS_KEY_ATTR_IPV4;
> -               if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
> +               if (match->mask &&
> +                   (match->mask->key.eth.type == htons(0xffff))) {

Minor nit, can probably drop the parentheses and keep this to one line?

> @@ -1430,6 +1476,10 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
>                         goto free_newmask;
>         }
>
> +       /* This also checks that conntrack original direction metadata exists
> +        * only for packets for which it makes sense.  Otherwise the key may be
> +        * corrupted due to overlapping key fields.
> +        */
>         if (!match_validate(match, key_attrs, mask_attrs, log))
>                 err = -EINVAL;
>

I believe that this is already explained in the relevant portion of
match_validate(), not sure it's worth highlighting that particular
piece of validation above a call to such a general function.
