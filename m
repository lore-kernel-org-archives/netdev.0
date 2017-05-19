From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next PATCH 3/5] net: introduce XDP driver features interface
Date: Fri, 19 May 2017 19:13:29 +0200
Message-ID: <591F27B9.9070003@iogearbox.net>
References: <149512205297.14733.15729847433404265933.stgit@firesoul> <149512210317.14733.15039298820296846614.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47751 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdESRNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 13:13:34 -0400
In-Reply-To: <149512210317.14733.15039298820296846614.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2017 05:41 PM, Jesper Dangaard Brouer wrote:
> There is a fundamental difference between normal eBPF programs
> and (XDP) eBPF programs getting attached in a driver. For normal
> eBPF programs it is easy to add a new bpf feature, like a bpf
> helper, because is it strongly tied to the feature being
> available in the current core kernel code.  When drivers invoke a
> bpf_prog, then it is not sufficient to simply relying on whether
> a bpf_helper exists or not.  When a driver haven't implemented a
> given feature yet, then it is possible to expose uninitialized
> parts of xdp_buff.  The driver pass in a pointer to xdp_buff,
> usually "allocated" on the stack, which must not be exposed.

When xdp_buff is being extended, then we should at least zero
initialize all in-tree users that don't support or populate this
field, thus that it's not uninitialized memory. Better would be
to have a way to reject the prog in the first place until it's
implemented (but further comments on feature bits below).

> Only two user visible NETIF_F_XDP_* net_device feature flags are
> exposed via ethtool (-k) seen as "xdp" and "xdp-partial".
> The "xdp-partial" is detected when there is not feature equality
> between kernel and driver, and a netdev_warn is given.

I think having something like a NETIF_F_XDP_BIT for ethtool to
indicate support as "xdp" is quite useful. Avoids having to grep
the kernel tree for ndo_xdp callback. ;) A "xdp-partial" would
still be unclear/confusing to the user whether his program loads
or doesn't which is the only thing a user (or some loading infra)
cares about eventually, so one still needs to go trying to load
the XDP code to see whether that fails for the native case.

> The idea is that XDP_DRV_* feature bits define a contract between
> the driver and the kernel, giving a reliable way to know that XDP
> features a driver promised to implement. Thus, knowing what bpf
> side features are safe to allow.
>
> There are 3 levels of features: "required", "devel" and "optional".
>
> The motivation is pushing driver vendors forward to support all
> the new XDP features.  Once a given feature bit is moved into
> the "required" features, the kernel will reject loading XDP
> program if feature isn't implemented by driver.  Features under
> developement, require help from the bpf infrastrucure to detect
> when a given helper or direct-access is used, using a bpf_prog
> bit to mark a need for the feature, and pulling in this bit in
> the xdp_features_check().  When all drivers have implemented
> a "devel" feature, it can be moved to the "required" feature and

The problem is that once you add bits markers to bpf_prog like we
used to do in the past, then as you do in patch 4/5 with the
xdp_rxhash_needed bit, they will need to be turned /on/ unconditionally
when a prog has tail calls.

Meaning, xdp_features_check() would then bail out when you have
XDP_DRV_F_RXHASH set. This has the effect that while XDP prog X
was running fine on kernel Y, it will suddenly get rejected on
later kernel (Y + 1), without using the feature (but tail calls).
And more complex networking progs are likely to use tail calls,
so that would break all of them unfortunately as they cannot load
anymore.

> the bpf_prog bit can be refurbished. The "optional" features are
> for things that are handled safely runtime, but drivers will
> still get flagged as "xdp-partial" if not implementing those.
