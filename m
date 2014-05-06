From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets
	between two guests on a bridge since merge of "TX grant
	mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Tue, 6 May 2014 19:33:52 +0200
Message-ID: <1886609598.20140506193352@eikelenboom.it>
References: <395225650.20140430124506@eikelenboom.it>
	<536162D3.5080307@citrix.com>
	<94755525.20140501002553@eikelenboom.it>
	<53624E25.8040404@citrix.com>
	<1810270947.20140501155911@eikelenboom.it>
	<53626C39.3030304@citrix.com>
	<928229683.20140501193936@eikelenboom.it>
	<198418193.20140501213951@eikelenboom.it>
	<5363A508.1000602@citrix.com>
	<653156457.20140502160632@eikelenboom.it>
	<5363AFED.5080601@citrix.com>
	<1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com>
	<5363B929.1000502@citrix.com>
	<35970097.20140502182818@eikelenboom.it>
	<5363CBB0.6050804@citrix.com>
	<15602339.20140505121912@eikelenboom.it>
	<53691783.3060108@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, xen-devel@lists.xen.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <53691783.3060108@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


Tuesday, May 6, 2014, 7:10:27 PM, you wrote:

> On 05/05/14 11:19, Sander Eikelenboom wrote:
>>
>> Hi Zoltan,
>>
>> This weekend i tried some more things, the summary:
>>
>>
>> 1) It's a PITA to isolate your patches that went into 3.15 (to rule out any other changes) and apply
>>     them to 3.14.2, which is tested and worked ok. Could you put up a git tree
>>     somewhere and rebase your patch series on 3.14.2 for testing ?
> I've managed to repro the case in house, now I'll start to add more 
> debug logging

Yippie :-)


>> 2) Does the test suite you are using also has tests verifying that the content of packets isn't altered ?
> Not directly. But the applications running on top of them probably do 
> so. Also, my tests are running on top of 3.10 kernel, where the netback 
> changes are backported.

I would probably be a nice test that would be overlooked quite easily, although 
it the should be the primary concern .. :-)

<big snip>

>>
>> Ad 4a) Assumption that  "An upstream guest shouldn't be able to send 18 slots":
>>      - xen-netfront does this slot check in "xennet_start_xmit":
>>          slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>>                  xennet_count_skb_frag_slots(skb);
>>          if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
>>                  net_alert_ratelimited(
>>                          "xennet: skb rides the rocket: %d slots\n", slots);
>>                  goto drop;
>>          }
>>
>>      - The "MAX_SKB_FRAGS + 1" was changed due to: http://www.gossamer-threads.com/lists/xen/devel/266980,
>>        but it doesn't seem to be the proper solution.
>>      - So your assumption doesn't hold, MAX_SKB_FRAGS==17, so 18 slots can come through.
>>      - On 3.15-rc4 i now started to see this warning getting triggered and packets dropped, i don't see this on 3.14.2:
>>        [  118.526583] xen_netfront: xennet: skb rides the rocket: 19 slots | skb_shinfo(skb)->nr_frags: 3, len: 186, offset: 4070, skb->len: 62330, skb->data_len: 62144, skb->truesize: 63424, np->tx.sring->rsp_prod: 21434, np->tx.rsp_cons: 21434  DIV_ROUND_UP(offset + len, PAGE_SIZE): 2
> Now I get it: compound pages on frags can cause more slots in certain 
> cases. Hm, I don't know how we should handle this on netfront side.

I don't know if something similar as netback does would be possible, do a check 
before dequeuing the skb and do the required slot detection in the capped 
pessimistic way (unless Paul comes up with something more clever) ?
