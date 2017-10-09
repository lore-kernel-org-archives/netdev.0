From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: xt_bpf: Fix XT_BPF_MODE_FD_PINNED mode of
 'xt_bpf_info_v1'
Date: Mon, 9 Oct 2017 15:18:51 +0200
Message-ID: <20171009131851.GA6068@salvia>
References: <20171009122715.19010-1-shmulik@nsof.io>
 <59DB6D22.6080507@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shmulik Ladkani <shmulik@nsof.io>, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, Rafael Buchbinder <rafi@rbk.ms>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:40881 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754836AbdJINS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:18:59 -0400
Content-Disposition: inline
In-Reply-To: <59DB6D22.6080507@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 02:35:46PM +0200, Daniel Borkmann wrote:
> On 10/09/2017 02:27 PM, Shmulik Ladkani wrote:
> >From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> >
> >Commit 2c16d6033264 ("netfilter: xt_bpf: support ebpf") introduced
> >support for attaching an eBPF object by an fd, with the
> >'bpf_mt_check_v1' ABI expecting the '.fd' to be specified upon each
> >IPT_SO_SET_REPLACE call.
> >
> >However this breaks subsequent iptables calls:
> >
> >  # iptables -A INPUT -m bpf --object-pinned /sys/fs/bpf/xxx -j ACCEPT
> >  # iptables -A INPUT -s 5.6.7.8 -j ACCEPT
> >  iptables: Invalid argument. Run `dmesg' for more information.
> >
> >That's because iptables works by loading exising rules using
> >IPT_SO_GET_ENTRIES to userspace, then issuing IPT_SO_SET_REPLACE with
> >the replacement set.
> >
> >However, the loaded 'xt_bpf_info_v1' has an arbitrary '.fd' number
> >(from the initial "iptables -m bpf" invocation) - so when 2nd invocation
> >occurs, userspace passes a bogus fd number, which leads to
> >'bpf_mt_check_v1' to fail.
> >
> >One suggested solution [1] was to hack iptables userspace, to perform a
> >"entries fixup" immediatley after IPT_SO_GET_ENTRIES, by opening a new,
> >process-local fd per every 'xt_bpf_info_v1' entry seen.
> >
> >However, in [2] both Pablo Neira Ayuso and Willem de Bruijn suggested to
> >depricate the xt_bpf_info_v1 ABI dealing with pinned ebpf objects.
> >
> >This fix changes the XT_BPF_MODE_FD_PINNED behavior to ignore the given
> >'.fd' and instead perform an in-kernel lookup for the bpf object given
> >the provided '.path'.
> >
> >It also defines an alias for the XT_BPF_MODE_FD_PINNED mode, named
> >XT_BPF_MODE_PATH_PINNED, to better reflect the fact that the user is
> >expected to provide the path of the pinned object.
> >
> >Existing XT_BPF_MODE_FD_ELF behavior (non-pinned fd mode) is preserved.
> >
> >References: [1] https://marc.info/?l=netfilter-devel&m=150564724607440&w=2
> >             [2] https://marc.info/?l=netfilter-devel&m=150575727129880&w=2
> >
> >Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> >Cc: Willem de Bruijn <willemb@google.com>
> >Reported-by: Rafael Buchbinder <rafi@rbk.ms>
> >Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks everyone.
