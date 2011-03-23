From: Feng Gao <kernel.goter@gmail.com>
Subject: [PATCH] ip_fragment:kernel may panic when replay big packet with RST flag
Date: Wed, 23 Mar 2011 18:49:10 +0800
Message-ID: <AANLkTikoSxVd3kTggsCGpjXz-5CFuVNxjnpuZNgWd3eV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43639 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab1CWKtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 06:49:11 -0400
Received: by yxs7 with SMTP id 7so3268517yxs.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 03:49:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone:

PC(A)-linux(B)-PC(C)
computer(linux B) with two net interface,eth0 and eth1.
PC(A) send syn to PC(C)  though linux B.
then PC(C) replay a big packet  with RST flag(use tcpsic or other tools).

This RST packet(1480) come in from eth0(mtu 1500) and go out from
eth1(mtu 700), so this RST packet should fragment.

BUT in tcp_packet func: if the connection has no reply packet,and
receive the RST packet.ip_conntrack should  destroy.
  if (!test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
                /* If only reply is a RST, we can consider ourselves not to
                   have an established connection: this is a fairly common
                   problem case, so we can delete the conntrack
                   immediately.  --RR */
                if (th->rst) {
                        nf_ct_kill_acct(ct, ctinfo, skb);
                        return NF_ACCEPT;
                }
        }

BUT the skb->nfct is not set NULL in func nf_ct_kill_acct.
so when this RST packet goto ip_fragment,ip_fragment call nf_copy, in
__nf_copy func
the fragment skb->nfct point to the destory mem.
dst->nfct = src->nfct;
nf_conntrack_get(src->nfct);

SO finally.kfree_skb call destroy_conntrack again. this may result in
LINUX B kernel panic.


here is the patch,sorry ,i dont know how to use diff to generate patch.
:-D

/* This func for ip_fragment deal with RST packet */
static inline void nf_copy_rst(struct sk_buff *dst, const struct sk_buff *src)
{
#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 nf_conntrack_put(dst->nfct);
 nf_conntrack_put_reasm(dst->nfct_reasm);
#endif
#ifdef CONFIG_BRIDGE_NETFILTER
 nf_bridge_put(dst->nf_bridge);
 dst->nf_bridge  = src->nf_bridge;
 nf_bridge_get(src->nf_bridge);
#endif
}

static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
{
 to->pkt_type = from->pkt_type;
 to->priority = from->priority;
 to->protocol = from->protocol;
 dst_release(to->dst);
 to->dst = dst_clone(from->dst);
 to->dev = from->dev;
 to->mark = from->mark;
 /* Copy the flags to each fragment. */
 IPCB(to)->flags = IPCB(from)->flags;
#ifdef CONFIG_NET_SCHED
 to->tc_index = from->tc_index;
#endif
 struct tcphdr *th = (struct tcphdr *)((char *)iph + (iph->ihl << 2));
 if(iph->protocol == IPPROTO_TCP && th->rst){
  /*RST packet*/
  nf_copy_rst(to, from);
 }else{
  /*Other packet*/
  nf_copy(to, from);
 }
#if defined(CONFIG_NETFILTER_XT_
TARGET_TRACE) || \
    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
 to->nf_trace = from->nf_trace;
#endif
#if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 to->ipvs_property = from->ipvs_property;
#endif
 skb_copy_secmark(to, from);
}
