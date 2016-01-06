From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add per device sg_max_frags for skb
Date: Wed, 06 Jan 2016 06:05:15 -0800
Message-ID: <1452089115.8255.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"\"\"Eric W. Biederman\"\"" <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	"\"\"hannes@stressinduktion.org\"\"" <hannes@stressinduktion.org>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kerne
To: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34903 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbcAFOFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 09:05:17 -0500
In-Reply-To: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 14:16 +0100, Hans Westgaard Ry wrote:
> Devices may have limits on the number of fragments in an skb they
> support. Current codebase uses a constant as maximum for number of
> fragments (MAX_SKB_FRAGS) one skb can hold and use.
> 
> When enabling scatter/gather and running traffic with many small
> messages the codebase uses the maximum number of fragments and thereby
> violates the max for certain devices.
> 
> An example of such a violation is when running IPoIB on a HCA
> supporting 16 SGE on an architecture with 4K pagesize. The
> MAX_SKB_FRAGS will be 17 (64K/4K+1) and because IPoIB adds yet another
> segment we end up with send_requests with 18 SGE resulting in
> kernel-panic.
> 
> The patch allows the device to limit the maximum number fragments used
> in one skb.
> 
> The functionality corresponds to gso_max_size/gso_max_segs for gso.

Unfortunately this is not the right place to fix this issue.

Think about forwarding workloads, where the SKB is cooked by GRO engine.

Anyway, local TCP stack uses 32KB page fragments, so typical skb has no
more than 3 frags.

Look at ndo_features_check(), where the problematic device driver can
add its logic.
