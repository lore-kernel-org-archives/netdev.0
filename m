From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: act_mirred: Fix bogus header when redirecting from VLAN
Date: Thu, 16 Apr 2015 19:40:30 -0700
Message-ID: <20150417024029.GA6718@Alexeis-MacBook-Pro.local>
References: <20150417010216.GA22415@gondor.apana.org.au>
 <20150417013401.GA4335@Alexeis-MacBook-Pro.local>
 <20150417021501.GB22835@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33478 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbDQCkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 22:40:33 -0400
Received: by paboj16 with SMTP id oj16so110053423pab.0
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 19:40:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150417021501.GB22835@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 10:15:01AM +0800, Herbert Xu wrote:
> > seems the cleaner fix will be to push skb->mac_len instead?
> 
> No skb->mac_len is the same as skb2->dev->hard_header_len.

hmm. please help me understand the problem then.
In the commit log you mentioned that your vlan dev and ifb
have unequal hard header length. I think that can only happen if
your master dev used to create vlan, didn't have vlan offload,
so vlandev->hhl = 18 and ifb->hhl = 14. Then when tagged packet
arrives on master device we call skb_vlan_untag() and
skb->mac_len becomes 14, then vlan_do_receive() will do
another_round, ingress qdisc will trigger and act_mirred
eventually will be called. So existing act_mirred will be pushing
18 bytes, whereas only 14 bytes are valid and the lowest 4 have junk.
By 'fixing it' using ifb's 14 byte the patch is only masking the
problem, no?
