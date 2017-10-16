From: Johannes Berg <johannes@sipsolutions.net>
Subject: using verifier to ensure a BPF program uses certain metadata?
Date: Mon, 16 Oct 2017 09:38:44 +0200
Message-ID: <1508139524.10607.25.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        alexei.starovoitov@gmail.com,
        linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.63.242]:41000 "EHLO
        sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdJPHir (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 03:38:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As we discussed in April already (it's really been that long...), I'd
wanted to allow using BPF to filter wireless monitor frames, to enable
new use cases and higher performance in monitoring. I have some code,
at

https://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git/log/?h=bpf

which implements parts of this. It's still missing the TX status path
and perhaps associated metadata, but that part is easy.

The bigger "problem" is that we're going to be adding support for
devices that have 802.11->Ethernet conversion already in hardware, and
in that case the notion that the filter program will get an 802.11
header to look at is no longer right.

Now, most likely for the actual in-service monitoring we'll actually
have to reconstitute the 802.11 header on the fly (in pure monitoring
where nothing else is active, we can just disable the conversion), but
the filtering shouldn't really be reliant on that, since that's not the
cheapest thing to do.

The obvious idea around this is to add a metadata field (just a bit
really), something like "is_data_ethernet", saying that it was both a
data frame and is already converted to have an Ethernet header.
However, since these devices don't really exist yet for the vast
majority of people, I'm a bit afraid that we'll find later a lot of
code simply ignoring this field and looking at the "802.11" header,
which is then broken if it encounters an Ethernet header instead.

Are there lies my question: If we added a new callback to
bpf_verifier_ops (e.g. "post_verifier_check"), to be called after the
normal verification, and also added a context argument to
"is_valid_access" (*), we could easily track that this new metadata
field is accessed, and reject programs that don't access it at all.

Now, I realize that people could trivially just work around this in
their program if they wanted, but I think most will take the reminder
and just implement

    if (ctx->is_data_ethernet)
        return DROP_FRAME;

instead, since mostly data frames will not be very relevant to them.

What do you think?

johannes

(*) the context argument could just be a void **, and is_valid_access
can allocate memory if needed - in this case I'd probably just do
something like "return *is_valid_access ?: NULL;" and return something
like "(void *)1" for when the field in question was accessed, and then
just check that in "post_verifier_check".
