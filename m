From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: Fix handling packets on compound
 pages with skb_linearize
Date: Mon, 1 Dec 2014 13:36:54 +0000
Message-ID: <547C6EF6.8020604@citrix.com>
References: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com> <547C2CFC.7060908@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Paul Durrant <paul.durrant@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <547C2CFC.7060908@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/14 08:55, Stefan Bader wrote:
> On 11.08.2014 19:32, Zoltan Kiss wrote:
>> There is a long known problem with the netfront/netback interface: if the guest
>> tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 ring slots,
>> it gets dropped. The reason is that netback maps these slots to a frag in the
>> frags array, which is limited by size. Having so many slots can occur since
>> compound pages were introduced, as the ring protocol slice them up into
>> individual (non-compound) page aligned slots. The theoretical worst case
>> scenario looks like this (note, skbs are limited to 64 Kb here):
>> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page boundary,
>> using 2 slots
>> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are at the
>> end and the beginning of a page, therefore they use 3 * 15 = 45 slots
>> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 = 4 slots
>> Although I don't think this 51 slots skb can really happen, we need a solution
>> which can deal with every scenario. In real life there is only a few slots
>> overdue, but usually it causes the TCP stream to be blocked, as the retry will
>> most likely have the same buffer layout.
>> This patch solves this problem by linearizing the packet. This is not the
>> fastest way, and it can fail much easier as it tries to allocate a big linear
>> area for the whole packet, but probably easier by an order of magnitude than
>> anything else. Probably this code path is not touched very frequently anyway.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Cc: Ian Campbell <Ian.Campbell@citrix.com>
>> Cc: Paul Durrant <paul.durrant@citrix.com>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: xen-devel@lists.xenproject.org
> 
> This does not seem to be marked explicitly as stable. Has someone already asked
> David Miller to put it on his stable queue? IMO it qualifies quite well and the
> actual change should be simple to pick/backport.

I think it's a candidate, yes.

Can you expand on the user visible impact of the bug this patch fixes?
I think it results in certain types of traffic not working (because the
domU always generates skb's with the problematic frag layout), but I
can't remember the details.

David
