From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v2 net] net: skbuff: skb_vlan_push: Fix wrong unwinding
 of skb->data after __vlan_insert_tag call
Date: Wed, 28 Sep 2016 20:42:35 +0300
Message-ID: <20160928204235.36371ce8@halley>
References: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>
        <57EB9BE0.4080903@iogearbox.net>
        <20160928145644.662ecc04@pixies>
        <57EBD71A.90104@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35436 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcI1Rmm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:42:42 -0400
Received: by mail-wm0-f50.google.com with SMTP id l132so248817334wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 10:42:42 -0700 (PDT)
In-Reply-To: <57EBD71A.90104@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2016 16:43:38 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:
> Couldn't we end up with 1) for the act_vlan case when we'd have the
> offset-adjusted skb_vlan_push() fix from here, where we'd then redirect
> to ingress where skb_vlan_pop() would be called? If I'm not missing
> something, skb_vlan_push() would then point to the data location of 1)
> and with your other proposed direct netif_receive_skb() patch, no
> further skb->data adjustments would be done, right?

Right. Then skb_vlan_pop() should expect either (1) or (2).

> Another potential issue (but unrelated to this fix here) I just noticed
> is, whether act_vlan might have the same problem as we fixed in 8065694e6519
> ("bpf: fix checksum for vlan push/pop helper"). So potentially, we could
> end up fixing CHECKSUM_COMPLETE wrongly on ingress, since these 14 bytes
> are already pulled out of the sum at that point.
> 
> > Should we adjust "offset" back, only if resulting offset is >=14 ?  
> 
> If also the checksum one might end up as an issue, maybe it's just best
> to go through the pain and do the push/pull for data plus csum, so both
> skb_vlan_*() functions see the frame starting from mac header temporarily?

Although not related to this specific fix, I see 2 ways addressing the
rcsum problem:

1. Per your suggestion, skb_vlan_*() to expect 'data' at mac_header
   That would simplify things; for this suggested 'data unwind' fix as well

2. Within skb_vlan_*(), deduct (according to initial offset) whether
   we're already "pulled out" of the rcsum, and not invoke the
   skb_postpull/push_rcsum update.

Will meditate some more.

Thanks
Shmulik
