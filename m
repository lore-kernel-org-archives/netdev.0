From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] bpf: add bpf_redirect() helper
Date: Tue, 15 Sep 2015 23:45:52 -0700
Message-ID: <55F91020.4030005@gmail.com>
References: <1442383543-4720-1-git-send-email-ast@plumgrid.com> <1442383543-4720-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33077 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbbIPGoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 02:44:06 -0400
Received: by oixx17 with SMTP id x17so113946806oix.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 23:44:04 -0700 (PDT)
In-Reply-To: <1442383543-4720-3-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-09-15 11:05 PM, Alexei Starovoitov wrote:
> Existing bpf_clone_redirect() helper clones skb before redirecting
> it to RX or TX of destination netdev.
> Introduce bpf_redirect() helper that does that without cloning.
> 
> Benchmarked with two hosts using 10G ixgbe NICs.
> One host is doing line rate pktgen.
> Another host is configured as:
> $ tc qdisc add dev $dev ingress
> $ tc filter add dev $dev root pref 10 u32 match u32 0 0 flowid 1:2 \
>    action bpf run object-file tcbpf1_kern.o section clone_redirect_xmit drop
> so it receives the packet on $dev and immediately xmits it on $dev + 1
> The section 'clone_redirect_xmit' in tcbpf1_kern.o file has the program
> that does bpf_clone_redirect() and performance is 2.0 Mpps
> 
> $ tc filter add dev $dev root pref 10 u32 match u32 0 0 flowid 1:2 \
>    action bpf run object-file tcbpf1_kern.o section redirect_xmit drop
> which is using bpf_redirect() - 2.4 Mpps
> 
> and using cls_bpf with integrated actions as:
> $ tc filter add dev $dev root pref 10 \
>   bpf run object-file tcbpf1_kern.o section redirect_xmit integ_act classid 1
> performance is 2.5 Mpps
> 
> To summarize:
> u32+act_bpf using clone_redirect - 2.0 Mpps
> u32+act_bpf using redirect - 2.4 Mpps
> cls_bpf using redirect - 2.5 Mpps
> 
> For comparison linux bridge in this setup is doing 2.1 Mpps
> and ixgbe rx + drop in ip_rcv - 7.8 Mpps
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
> This approach is using per_cpu scratch area to store ifindex and flags.
> The other alternatives discussed at plumbers are slower and more intrusive.
> v1->v2: dropped redundant iff_up check
> 
>  include/net/sch_generic.h    |    1 +
>  include/uapi/linux/bpf.h     |    8 ++++++++
>  include/uapi/linux/pkt_cls.h |    1 +
>  net/core/dev.c               |    8 ++++++++
>  net/core/filter.c            |   44 ++++++++++++++++++++++++++++++++++++++++++
>  net/sched/act_bpf.c          |    1 +
>  net/sched/cls_bpf.c          |    1 +
>  samples/bpf/bpf_helpers.h    |    4 ++++
>  samples/bpf/tcbpf1_kern.c    |   24 ++++++++++++++++++++++-
>  9 files changed, 91 insertions(+), 1 deletion(-)
> 

Acked-by: John Fastabend <john.r.fastabend@intel.com>
