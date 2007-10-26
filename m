From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [2.6 patch] unexport softnet_data
Date: Fri, 26 Oct 2007 08:38:55 -0700
Message-ID: <BAE9DCEF64577A439B3A37F36F9B691C034CC519@orsmsx418.amr.corp.intel.com>
References: <20071024162425.GI30533@stusta.de> <20071026.041906.223457165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@linux-foundation.org>, <netdev@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
To: "David Miller" <davem@davemloft.net>, <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33384 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164AbXJZPkJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 11:40:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071026.041906.223457165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>
>From: Adrian Bunk <bunk@kernel.org>
>Date: Wed, 24 Oct 2007 18:24:25 +0200
>
>> The EXPORT_PER_CPU_SYMBOL(softnet_data) is no longer used.
>> 
>> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
>I wanted to apply this, but in validing the patch I noticed
>what appears to be an omission in TCP ipv6.
>
>It seems that NET_DMA support there is only half-cooked and
>the following patch is needed (and thus there is a modular
>use of softnet_data again).
>
>Looking at Christopher Leech's original TCP I/O AT commit:
>
>1a2449a87bb7606113b1aa1a9d3c3e78ef189a1c
>
>this appears to just be an oversight.
>
>If one of the current I/O AT folks can look this over and
>confirm I'd appreciate it.
>
>Thanks!
>
>[TCP]: Add missing I/O AT code to ipv6 side.
>
>Signed-off-by: David S. Miller <davem@davemloft.net>
>
>diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>index 32dc329..06fa4ba 100644
>--- a/net/ipv6/tcp_ipv6.c
>+++ b/net/ipv6/tcp_ipv6.c
>@@ -1732,6 +1732,8 @@ process:
> 	if (!sock_owned_by_user(sk)) {
> #ifdef CONFIG_NET_DMA
> 		struct tcp_sock *tp = tcp_sk(sk);
>+		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
>+			tp->ucopy.dma_chan = get_softnet_dma();
> 		if (tp->ucopy.dma_chan)
> 			ret = tcp_v6_do_rcv(sk, skb);
> 		else
>

There is no creation of a pinned_list yet in this path, so I don't think
this would do us much good.  Anyway, I believe the next bit is simply
checking to see if we can process it right away (if we have a dma
channel or a reader task is waiting) otherwise stick it into backlog.
Once we go to process it, if it is an IP packet we'll drop into the ipv4
processing code and end up in tcp_recv() which can create the
pinned_list and process from there.

I'm sure someone will correct me if I'm wrong, but I believe this bit it
not needed.  I suggest a NAK for this patch.

sln
