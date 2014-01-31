From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue timed out" when
 skb has huge linear buffer
Date: Fri, 31 Jan 2014 18:56:19 +0000
Message-ID: <20140131185619.GB27553@zion.uk.xensource.com>
References: <52EAA31B.1090606@schaman.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	<wei.liu2@citrix.com>
To: Zoltan Kiss <zoltan.kiss@schaman.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52EAA31B.1090606@schaman.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 30, 2014 at 07:08:11PM +0000, Zoltan Kiss wrote:
> Hi,
> 
> I've experienced some queue timeout problems mentioned in the
> subject with igb and bnx2 cards. I haven't seen them on other cards
> so far. I'm using XenServer with 3.10 Dom0 kernel (however igb were
> already updated to latest version), and there are Windows guests
> sending data through these cards. I noticed these problems in XenRT
> test runs, and I know that they usually mean some lost interrupt
> problem or other hardware error, but in my case they started to
> appear more often, and they are likely connected to my netback grant
> mapping patches. These patches causing skb's with huge (~64kb)
> linear buffers to appear more often.
> The reason for that is an old problem in the ring protocol:
> originally the maximum amount of slots were linked to MAX_SKB_FRAGS,
> as every slot ended up as a frag of the skb. When this value were
> changed, netback had to cope with the situation by coalescing the
> packets into fewer frags.
> My patch series take a different approach: the leftover slots
> (pages) were assigned to a new skb's frags, and that skb were
> stashed to the frag_list of the first one. Then, before sending it
> off to the stack it calls skb = skb_copy_expand(skb, 0, 0,
> GFP_ATOMIC, __GFP_NOWARN), which basically creates a new skb and
> copied all the data into it. As far as I understood, it put
> everything into the linear buffer, which can amount to 64KB at most.
> The original skb are freed then, and this new one were sent to the
> stack.

Just my two cents, if it is this case, you can try to call
skb_copy_expand on every SKB netback receives to manually create SKBs
with ~64KB linear buffer to see how it goes...

Wei.

> I suspect that this is the problem as it only happens when guests
> send too much slots. Does anyone familiar with these drivers have
> seen such issue before? (when these kind of skb's get stucked in the
> queue)
> 
> Regards,
> 
> Zoltan Kiss
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
