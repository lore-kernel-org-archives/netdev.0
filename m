From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 12:31:08 -0400
Message-ID: <20160920163108.GP8920@oracle.com>
References: <20160920142700.GJ8920@oracle.com>
 <20160920181114.0ac7cfa0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26156 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754586AbcITQbb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:31:31 -0400
Content-Disposition: inline
In-Reply-To: <20160920181114.0ac7cfa0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/20/16 18:11), Jiri Benc wrote:
> > The vxlan header is at offset (14 + 20 + 8) into the packet,
> > so the vxh is not aligned in vxlan_build_skb. Use [get/put]_unaligned
> > functions to modify flags and vni field in the vxh.
> 
> How did you calculate that? IP header should be aligned to 4 bytes, UDP
> header is 8 bytes, thus VXLAN header is also aligned to 4 bytes.

The vxlan header is after the ethernet header (14 bytes),
IP header (20 bytes, assuming no options) and udp header (8 bytes).
Post the skb_reserve adjustments (see computations in in mld_newpack(),
for example), this triggers an unaligned access on sparc.

> If you went this way, it would be better to make two local variables
> for vx_flags and vx_vni, store to them and do a single put_unaligned
> after the condition. That way, you would have two less put_unaligned and
> no get_unaligned in the remote csum case.

Ok, that is certainly possible.

> And the code would be
> cleaner. And you're missing vx_flags being accessed in
> vxlan_build_gbp_hdr.

Sure, and there's also potential unaligned access in vxlan_build_gpe_hdr.

But as I was telling Tom, this problem is much deeper than this fix, and 
I dont have the facility, at the moment, to test out every one of these
code paths. We would have to fix these, one at a time, in subsequent
patches. This one just fixes the top-level basic code paths.

> But I think this is not needed at all, see above.
> 
>  Jiri
