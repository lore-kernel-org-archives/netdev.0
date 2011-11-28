From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 21/62] net: remove the second argument of k[un]map_atomic()
Date: Mon, 28 Nov 2011 10:06:03 -0800
Message-ID: <4ED3CD8B.5060000@intel.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>  <1322371662-26166-22-git-send-email-amwang@redhat.com> <1322381248.2826.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dean Nelson <dnelson@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jiri Pirko <jpirko@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322381248.2826.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/27/2011 12:07 AM, Eric Dumazet wrote:
> Le dimanche 27 novembre 2011 =C3=A0 13:27 +0800, Cong Wang a =C3=A9cr=
it :
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>> ---
>> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers=
/net/ethernet/intel/e1000/e1000_main.c
>> index cf480b5..b194beb 100644
>> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> @@ -3878,11 +3878,9 @@ static bool e1000_clean_jumbo_rx_irq(struct e=
1000_adapter *adapter,
>>  				if (length <=3D copybreak &&
>>  				    skb_tailroom(skb) >=3D length) {
>>  					u8 *vaddr;
>> -					vaddr =3D kmap_atomic(buffer_info->page,
>> -					                    KM_SKB_DATA_SOFTIRQ);
>> +					vaddr =3D kmap_atomic(buffer_info->page);
>>  					memcpy(skb_tail_pointer(skb), vaddr, length);
>> -					kunmap_atomic(vaddr,
>> -					              KM_SKB_DATA_SOFTIRQ);
>> +					kunmap_atomic(vaddr);
>>  					/* re-use the page, so don't erase
>>  					 * buffer_info->page */
>>  					skb_put(skb, length);
>> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/ne=
t/ethernet/intel/e1000e/netdev.c
>> index a855db1..8603c87 100644
>> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>> @@ -1272,9 +1272,9 @@ static bool e1000_clean_rx_irq_ps(struct e1000=
_adapter *adapter,
>>  			 */
>>  			dma_sync_single_for_cpu(&pdev->dev, ps_page->dma,
>>  						PAGE_SIZE, DMA_FROM_DEVICE);
>> -			vaddr =3D kmap_atomic(ps_page->page, KM_SKB_DATA_SOFTIRQ);
>> +			vaddr =3D kmap_atomic(ps_page->page);
>>  			memcpy(skb_tail_pointer(skb), vaddr, l1);
>> -			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
>> +			kunmap_atomic(vaddr);
>>  			dma_sync_single_for_device(&pdev->dev, ps_page->dma,
>>  						   PAGE_SIZE, DMA_FROM_DEVICE);
>> =20
>> @@ -1465,12 +1465,10 @@ static bool e1000_clean_jumbo_rx_irq(struct =
e1000_adapter *adapter,
>>  				if (length <=3D copybreak &&
>>  				    skb_tailroom(skb) >=3D length) {
>>  					u8 *vaddr;
>> -					vaddr =3D kmap_atomic(buffer_info->page,
>> -					                   KM_SKB_DATA_SOFTIRQ);
>> +					vaddr =3D kmap_atomic(buffer_info->page);
>>  					memcpy(skb_tail_pointer(skb), vaddr,
>>  					       length);
>> -					kunmap_atomic(vaddr,
>> -					              KM_SKB_DATA_SOFTIRQ);
>> +					kunmap_atomic(vaddr);
>>  					/* re-use the page, so don't erase
>>  					 * buffer_info->page */
>>  					skb_put(skb, length);
> But why are these drivers using kmap_atomic() in first place, since
> their fragments are allocated in regular zone (GFP_ATOMIC or
> GFP_KERNEL) ?

I was asking the same thing myself recently when I started working on
some copy-break like code for the ixgbe driver.  I believe the main
reason is a lack of documentation.  This code is based loosely on the
skb_copy_bits code which will use kmap_skb_frag over all of the paged
portions of the sk_buff.  As such it was decided to map things via
kmap_atomic in order to guarantee the pages had a valid virtual address=
=2E

If I understand things correctly, what you are brining up is that pages
allocated with either GFP_ATOMIC or GFP_KERNEL will always be allocated
from the lowmem pool and as such page_address should always succeed.  I=
s
that correct?

Thanks,

Alex
