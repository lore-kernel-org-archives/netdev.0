From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 2/2] net/sched: allow flower to match tunnel
 options
Date: Wed, 27 Sep 2017 14:52:06 +0200
Message-ID: <20170927125205.GA30000@vergenet.net>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
 <1506500194-17637-3-git-send-email-simon.horman@netronome.com>
 <20170927091005.GB1944@nanopsycho.orion>
 <20170927092732.GC25449@vergenet.net>
 <20170927110822.GD1944@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:56331 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752104AbdI0MwN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 08:52:13 -0400
Received: by mail-qk0-f174.google.com with SMTP id g128so13126395qke.13
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 05:52:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170927110822.GD1944@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 01:08:22PM +0200, Jiri Pirko wrote:
> Wed, Sep 27, 2017 at 11:27:33AM CEST, simon.horman@netronome.com wrote:
> >On Wed, Sep 27, 2017 at 11:10:05AM +0200, Jiri Pirko wrote:
> >> Wed, Sep 27, 2017 at 10:16:34AM CEST, simon.horman@netronome.com wrote:

...

> >> > enum flow_dissector_key_id {
> >> > 	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
> >> > 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
> >> >@@ -205,6 +217,7 @@ enum flow_dissector_key_id {
> >> > 	FLOW_DISSECTOR_KEY_MPLS, /* struct flow_dissector_key_mpls */
> >> > 	FLOW_DISSECTOR_KEY_TCP, /* struct flow_dissector_key_tcp */
> >> > 	FLOW_DISSECTOR_KEY_IP, /* struct flow_dissector_key_ip */
> >> >+	FLOW_DISSECTOR_KEY_ENC_OPTS, /* struct flow_dissector_key_enc_opts */
> >> 
> >> I don't see the actual dissection implementation. Where is it?
> >> Did you test the patchset?
> >
> >Yes, I did test it. But it is also possible something went astray along the
> >way and I will retest.
> >
> >I think that the code you are looking for is in
> >fl_classify() in this patch.
> 
> The dissection should be done in the flow_dissector. That's the whole
> point in having it generic. You should move it there.

Coming back to this after lunch, I believe what I have done in this patch
is consistent with handling of other enc fields, which are set in
fl_classify() rather than the dissector. In particular the ip_tunnel_info,
which is used by this patch, is already used in fl_classify().

Without this patch I see:


static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
                       struct tcf_result *res)
{
        ...
        struct ip_tunnel_info *info;

        ...

        info = skb_tunnel_info(skb);
        if (info) {
                struct ip_tunnel_key *key = &info->key;

                switch (ip_tunnel_info_af(info)) {
                case AF_INET:
                        skb_key.enc_control.addr_type =
                                FLOW_DISSECTOR_KEY_IPV4_ADDRS;
                        skb_key.enc_ipv4.src = key->u.ipv4.src;
                        skb_key.enc_ipv4.dst = key->u.ipv4.dst;
                        break;
                case AF_INET6:
                        skb_key.enc_control.addr_type =
                                FLOW_DISSECTOR_KEY_IPV6_ADDRS;
                        skb_key.enc_ipv6.src = key->u.ipv6.src;
                        skb_key.enc_ipv6.dst = key->u.ipv6.dst;
                        break;
                }

                skb_key.enc_key_id.keyid = tunnel_id_to_key32(key->tun_id);
                skb_key.enc_tp.src = key->tp_src;
                skb_key.enc_tp.dst = key->tp_dst;
        }

	...
}

This patch adds the following inside the if() clause above:

	if (info->options_len) {
		skb_key.enc_opts.len = info->options_len;
		ip_tunnel_info_opts_get(skb_key.enc_opts.data, info);
	}
