From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Reset skb to network header in neigh_hh_output
Date: Wed, 26 Oct 2016 10:08:31 -0700
Message-ID: <1477501711.7065.198.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com>
         <1475874656.28155.268.camel@edumazet-glaptop3.roam.corp.google.com>
         <157fe46f382.10e50a6d8188917.494328765811573491@abahmed.com>
         <1477440742.7065.161.camel@edumazet-glaptop3.roam.corp.google.com>
         <15801e95765.f826e84d266359.4807464957002677781@abahmed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Abdelrhman Ahmed <ab@abahmed.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15801e95765.f826e84d266359.4807464957002677781@abahmed.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-10-26 at 18:53 +0200, Abdelrhman Ahmed wrote:
> I think it's at the right place as the current one is a little different from the
> commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c.
> 
> In the next lines, skb_push is called after copying the hardware header and there
> is no change to the data pointer inside the retry loop. We only need to reset
> before this loop.
> 
> __skb_pull(skb, skb_network_offset(skb));
> 
> do {
> 	seq = read_seqbegin(&hh->hh_lock);
> 	hh_len = hh->hh_len;
> 	if (likely(hh_len <= HH_DATA_MOD)) {
> 		/* this is inlined by gcc */
> 		memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);
> 	} else {
> 		int hh_alen = HH_DATA_ALIGN(hh_len);
> 
> 		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
> 	}
> } while (read_seqretry(&hh->hh_lock, seq));
> 
> skb_push(skb, hh_len);
> 
> In the commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c, dev_hard_header which
> calls create method for adding hardware header (uses skb_push) so it was
> required to reset to network header in the beginning of the retry loop.

Right you are, thanks for the clarification !

Back to the cause of the bug then.

If netfilter is the only case this might be needed, can't this be fixed
in netfilter ?

neigh_hh_output() is in fast path, it is quite annoying adding this
operation.
