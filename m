From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: using verifier to ensure a BPF program uses certain metadata?
Date: Tue, 17 Oct 2017 15:58:08 -0700
Message-ID: <20171017225806.b5xubolkyocfgnjc@ast-mbp>
References: <1508139524.10607.25.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:51712 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932782AbdJQW6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 18:58:11 -0400
Content-Disposition: inline
In-Reply-To: <1508139524.10607.25.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 09:38:44AM +0200, Johannes Berg wrote:
> Hi,
> 
> As we discussed in April already (it's really been that long...), I'd
> wanted to allow using BPF to filter wireless monitor frames, to enable
> new use cases and higher performance in monitoring. I have some code,
> at
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git/log/?h=bpf

bpf bits looks pretty straightforward.
attach looks fine too. I'm assuming there is some rtnl or other lock,
so multiple assigns cannot race?
It's missing query interface though.
Please add support to return prog_id.

> which implements parts of this. It's still missing the TX status path
> and perhaps associated metadata, but that part is easy.
> 
> The bigger "problem" is that we're going to be adding support for
> devices that have 802.11->Ethernet conversion already in hardware, and
> in that case the notion that the filter program will get an 802.11
> header to look at is no longer right.
> 
> Now, most likely for the actual in-service monitoring we'll actually
> have to reconstitute the 802.11 header on the fly (in pure monitoring
> where nothing else is active, we can just disable the conversion), but
> the filtering shouldn't really be reliant on that, since that's not the
> cheapest thing to do.
> 
> The obvious idea around this is to add a metadata field (just a bit
> really), something like "is_data_ethernet", saying that it was both a
> data frame and is already converted to have an Ethernet header.
> However, since these devices don't really exist yet for the vast
> majority of people, I'm a bit afraid that we'll find later a lot of
> code simply ignoring this field and looking at the "802.11" header,
> which is then broken if it encounters an Ethernet header instead.
> 
> Are there lies my question: If we added a new callback to
> bpf_verifier_ops (e.g. "post_verifier_check"), to be called after the
> normal verification, and also added a context argument to
> "is_valid_access" (*), we could easily track that this new metadata
> field is accessed, and reject programs that don't access it at all.
> 
> Now, I realize that people could trivially just work around this in
> their program if they wanted, but I think most will take the reminder
> and just implement
> 
>     if (ctx->is_data_ethernet)
>         return DROP_FRAME;
> 
> instead, since mostly data frames will not be very relevant to them.
> 
> What do you think?

sounds fine and considering new verifier ops after Jakub refactoring
a check that is_data_ethernet was accessed would fit nicely.
Without void** hack.
