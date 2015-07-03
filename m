From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Fri, 3 Jul 2015 11:32:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507031131010.1649@ja.home.ssi.bg>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com> <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com> <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com> <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com> <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg> <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
 <CALCkm3eGTi6038Zq7N+XZsX3v5vbP0wY42ded0YUbBn0pjSE8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49334 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754071AbbGCIfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2015 04:35:03 -0400
In-Reply-To: <CALCkm3eGTi6038Zq7N+XZsX3v5vbP0wY42ded0YUbBn0pjSE8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 2 Jul 2015, Alex Gartrell wrote:

> On Thu, Jul 2, 2015 at 2:18 PM, Alex Gartrell <alexgartrell@gmail.com> wrote:
> > If early demux was enabled, we'd use the route from the socket
> 
> Actually now that I think about it, this is probably broken, because
> we don't reply to the packet but instead silently drop it.

	I think, the problem is that input packet takes
the output path, not a problem with its sk_state.

	Here is how I understand the situation:

Input packet:

ip_rcv_finish:
	- early_demux:
		- attach skb->sk, skb->destructor, skb->dst
		- skb size is accounted later to sk

LOCAL_IN:
	- IPVS Remote Client mode: ip_vs_in
	- Case 1: IPVS forward to local real server (NF_ACCEPT case):
		- we are going to hit local server, so we should keep
		skb->sk, etc
		- skb->dst not changed
		- return NF_ACCEPT
		- continue to TCP stack
	- Case 2: IPVS forward TUN for example:
		- skb_orphan
		- we should not work with any skb->sk from input path
		- attach new skb->dst for the new real server
		- ip_local_out

TCP:
	- if IPVS does not grab the packet above, we have
	a call to skb_set_owner_r to account the skb size to sk


Locally generated TCP packet:

TCP tcp_transmit_skb:
	- attach skb->sk, skb->destructor, increase sk_wmem_alloc

LOCAL_OUT:
	- IPVS Local Client mode: again ip_vs_in
	- skb->dev is NULL means locally generated packet, skb->sk can
	be set by TCP
	- Case 1: IPVS forward to local real server (NF_ACCEPT case):
		- we are going to hit local server, so we should keep
		skb->sk, etc
		- skb->dst not changed
		- return NF_ACCEPT
		- continue to TCP stack in LOCAL_IN
	- Case 2: IPVS forward TUN for example:
		- no skb_orphan because skb->sk is for
		output path on skb->dev == NULL
		- realloc headroom (call skb_set_owner_w): should happen
		only for skb->sk from output path. This code in
		ip_vs_prepare_tunneled_skb comes from old days from
		ipip.c where skb->sk is present for locally generated
		packets and IPIP's xmit routine reallocs headroom
		- attach new skb->dst for the new real server
		- ip_local_out

To summarize:
	- we should call skb_orphan as soon as possible after
	deciding if packets goes to local or remote real server
	but only for skb->sk set by early_demux, not for packets
	sent by TCP
	- if packets go to local server IPVS should not touch
	skb->dst, skb->sk, etc (NF_ACCEPT case)
	- for skb->sk set by early_demux, skb_orphan should happen before
	skb_set_owner_w in ip_vs_prepare_tunneled_skb because
	skb_set_owner_w will try to increase sk_wmem_alloc which is
	wrong for early_demux phase
	- reaching skb_set_owner_w code for skb->sk set by eraly_demux
	looks wrong to me, it can happen on:
		- redirect (DNAT), if somehow we have socket too
		- IPVS redirect: if we forward both to local and remote
		real servers
		- not likely for forward, nobody forwards traffic
		destined to local IP to remote host

Regards

--
Julian Anastasov <ja@ssi.bg>
