From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue
 timed out" when skb has huge linear buffer
Date: Tue, 4 Feb 2014 21:32:53 +0000
Message-ID: <52F15C85.7050200@citrix.com>
References: <52EAA31B.1090606@schaman.hu>
	<20140131185619.GB27553@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Carolyn, Tushar,
	e1000-devel@lists.sourceforge.net, Michael Chan <mchan@broadcom.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Peter
To: Wei Liu <wei.liu2@citrix.com>, Zoltan Kiss <zoltan.kiss@schaman.hu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140131185619.GB27553@zion.uk.xensource.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 31/01/14 18:56, Wei Liu wrote:
> On Thu, Jan 30, 2014 at 07:08:11PM +0000, Zoltan Kiss wrote:
>> Hi,
>>
>> I've experienced some queue timeout problems mentioned in the
>> subject with igb and bnx2 cards. I haven't seen them on other cards
>> so far. I'm using XenServer with 3.10 Dom0 kernel (however igb were
>> already updated to latest version), and there are Windows guests
>> sending data through these cards. I noticed these problems in XenRT
>> test runs, and I know that they usually mean some lost interrupt
>> problem or other hardware error, but in my case they started to
>> appear more often, and they are likely connected to my netback grant
>> mapping patches. These patches causing skb's with huge (~64kb)
>> linear buffers to appear more often.
>> The reason for that is an old problem in the ring protocol:
>> originally the maximum amount of slots were linked to MAX_SKB_FRAGS,
>> as every slot ended up as a frag of the skb. When this value were
>> changed, netback had to cope with the situation by coalescing the
>> packets into fewer frags.
>> My patch series take a different approach: the leftover slots
>> (pages) were assigned to a new skb's frags, and that skb were
>> stashed to the frag_list of the first one. Then, before sending it
>> off to the stack it calls skb = skb_copy_expand(skb, 0, 0,
>> GFP_ATOMIC, __GFP_NOWARN), which basically creates a new skb and
>> copied all the data into it. As far as I understood, it put
>> everything into the linear buffer, which can amount to 64KB at most.
>> The original skb are freed then, and this new one were sent to the
>> stack.
>
> Just my two cents, if it is this case, you can try to call
> skb_copy_expand on every SKB netback receives to manually create SKBs
> with ~64KB linear buffer to see how it goes...

I've tried it, and it did break everything in a similar way, so that's a 
strong clue that the problem lies here. I've rewrote that part of my 
patches to do less modification, based on Malcolm's idea: netback pulls 
the first frag into linear buffer, then moves a frag from the frag_list 
skb into the first one. That seems to help, but so far I have only one 
relevant test result, I'm waiting for more results.

Zoli


------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
