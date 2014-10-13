From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: release skbuf when nlmsg put fail
Date: Mon, 13 Oct 2014 13:42:56 +0200
Message-ID: <20141013114256.GB6560@breakpoint.cc>
References: <CAL8JtxAqDhOXooLtOebSBHtKxwE=sLFqW8B-VgtCzsr-M4OD7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Houcheng Lin <houcheng@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAL8JtxAqDhOXooLtOebSBHtKxwE=sLFqW8B-VgtCzsr-M4OD7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Houcheng Lin <houcheng@gmail.com> wrote:
> When system is under heavy loading, the __nfulnl_send() may may failed
> to put nlmsg into skbuf of nfulnl_instance. If not clear the skbuff on failed,
> the __nfulnl_send() will still try to put next nlmsg onto this half-full skbuf
> and cause the user program can never receive packet.
> 
> This patch fix this issue by releasing skbuf immediately after nlmst put
> failed.

Did you observe such problem or is this based on code reading?
I ask because nflog should make sure we always have enough room left in
skb to append a done message, see nfulnl_log_packet():

if (inst->skb &&
    size > skb_tailroom(inst->skb) - sizeof(struct nfgenmsg)) {
	/* flush skb */

Your patch fixes such 'can never send' skb condition by leaking the
skb.  So at the very least you would need to call kfree_skb(), and
perhaps also add WARN_ON() so we catch this and can fix up the size
accounting?
