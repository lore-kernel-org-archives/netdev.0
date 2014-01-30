From: Zoltan Kiss <zoltan.kiss@schaman.hu>
Subject: igb and bnx2: "NETDEV WATCHDOG: transmit queue timed out" when skb
 has huge linear buffer
Date: Thu, 30 Jan 2014 19:08:11 +0000
Message-ID: <52EAA31B.1090606@schaman.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
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
	e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've experienced some queue timeout problems mentioned in the subject 
with igb and bnx2 cards. I haven't seen them on other cards so far. I'm 
using XenServer with 3.10 Dom0 kernel (however igb were already updated 
to latest version), and there are Windows guests sending data through 
these cards. I noticed these problems in XenRT test runs, and I know 
that they usually mean some lost interrupt problem or other hardware 
error, but in my case they started to appear more often, and they are 
likely connected to my netback grant mapping patches. These patches 
causing skb's with huge (~64kb) linear buffers to appear more often.
The reason for that is an old problem in the ring protocol: originally 
the maximum amount of slots were linked to MAX_SKB_FRAGS, as every slot 
ended up as a frag of the skb. When this value were changed, netback had 
to cope with the situation by coalescing the packets into fewer frags.
My patch series take a different approach: the leftover slots (pages) 
were assigned to a new skb's frags, and that skb were stashed to the 
frag_list of the first one. Then, before sending it off to the stack it 
calls skb = skb_copy_expand(skb, 0, 0, GFP_ATOMIC, __GFP_NOWARN), which 
basically creates a new skb and copied all the data into it. As far as I 
understood, it put everything into the linear buffer, which can amount 
to 64KB at most. The original skb are freed then, and this new one were 
sent to the stack.
I suspect that this is the problem as it only happens when guests send 
too much slots. Does anyone familiar with these drivers have seen such 
issue before? (when these kind of skb's get stucked in the queue)

Regards,

Zoltan Kiss
