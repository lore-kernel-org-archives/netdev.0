From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 2/2] bpf: add bpf_redirect() helper
Date: Tue, 15 Sep 2015 20:10:01 -0700
Message-ID: <55F8DD89.5090709@gmail.com>
References: <1442368295-5204-1-git-send-email-ast@plumgrid.com> <1442368295-5204-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35608 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbbIPDIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 23:08:18 -0400
Received: by oiww128 with SMTP id w128so109287277oiw.2
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 20:08:18 -0700 (PDT)
In-Reply-To: <1442368295-5204-3-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-09-15 06:51 PM, Alexei Starovoitov wrote:
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


Nice, I like this. But just to be sure I read this correctly this will
only work on the ingress qdisc for now right? To get the tx side working
will require a bit more care.

Thanks,
.John
