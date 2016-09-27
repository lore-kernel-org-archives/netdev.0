From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 17:18:04 +0300
Message-ID: <20160927171804.5288347d@pixies>
References: <20160927.015606.437705429903770747.davem@davemloft.net>
        <20160927110711.12555f4e@pixies>
        <57EA4C66.8070907@iogearbox.net>
        <20160927.094441.1957543068015677016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: David Miller <davem@davemloft.net>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36444 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932624AbcI0OSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:18:10 -0400
Received: by mail-wm0-f45.google.com with SMTP id w84so178756565wmg.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 07:18:09 -0700 (PDT)
In-Reply-To: <20160927.094441.1957543068015677016.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Sep 2016 09:44:41 -0400 (EDT), davem@davemloft.net wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Tue, 27 Sep 2016 12:39:34 +0200
> 
> > Any reason why dev_forward_skb() is not preferred over direct
> > netif_receive_skb() you're using? It would, for example, implicitly
> > assure that pkt_type is always PACKET_HOST, etc.
> 
> dev_forward_skb() will pull the ethernet header.
> 
> And since a direct call to netif_receive_skb() will not, one of these
> two choices won't work properly.

In the patch, I'm issuing a skb_pull_rcsum() prior the netif_receive_skb,
snip:

+	/* If action's target direction differs than filter's direction,
+	 * and devices expect a mac header on xmit, then mac push/pull is
+	 * needed.
+	 */
+	if (at != tcf_mirred_act_direction(m->tcfm_eaction) &&
+	    m->tcfm_mac_header_xmit) {
+		if (at & AT_EGRESS) {
+			/* caught at egress, act ingress: pull mac */
+			mac_len = skb_network_header(skb) - skb_mac_header(skb);
+			skb_pull_rcsum(skb2, mac_len);

Existing *egress* mir/red already supported pairing two non-eth devices.
Therefore I allow it for the new *ingress* mir/red as well.

Now, following this premise, the skb_pull_rcsum() shown above is executed
for devices whose xmit is mac_header based.

I've tested both ARPHRD_ETHER devices and some non ARPHRD_ETHER devices.

(an *existing* symmetric skb_push_rcsum() is invoked if packet is caught at
 ingress and redirected for egress on a mac_header xmit device)

This was the reason for picking netif_receive_skb() over dev_forward_skb().

Regards,
Shmulik
