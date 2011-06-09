From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 5/5] net: ep93xx_eth: fix DMA API violations
Date: Thu, 9 Jun 2011 16:25:02 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3820B8639@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
	<a0d2d13698ea27f671a077c9f47b7ce855054a47.1307040443.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ryan@bluewatersys.com" <ryan@bluewatersys.com>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Mika Westerberg <mika.westerberg@iki.fi>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <a0d2d13698ea27f671a077c9f47b7ce855054a47.1307040443.git.mika.westerberg@iki.fi>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thursday, June 02, 2011 12:00 PM, Mika Westerberg wrote:
> Russell King said:
>>
>> So, to summarize what its doing:
>>
>> 1. It allocates buffers for rx and tx.
>> 2. It maps them with dma_map_single().
>>       This transfers ownership of the buffer to the DMA device.
>> 3. In ep93xx_xmit,
>> 3a. It copies the data into the buffer with skb_copy_and_csum_dev()
>>       This violates the DMA buffer ownership rules - the CPU should
>>       not be writing to this buffer while it is (in principle) owned
>>       by the DMA device.
>> 3b. It then calls dma_sync_single_for_cpu() for the buffer.
>>       This transfers ownership of the buffer to the CPU, which surely
>>       is the wrong direction.
>> 4. In ep93xx_rx,
>> 4a. It calls dma_sync_single_for_cpu() for the buffer.
>>       This at least transfers the DMA buffer ownership to the CPU
>>       before the CPU reads the buffer
>> 4b. It then uses skb_copy_to_linear_data() to copy the data out.
>>       At no point does it transfer ownership back to the DMA device.
>> 5. When the driver is removed, it dma_unmap_single()'s the buffer.
>>       This transfers ownership of the buffer to the CPU.
>> 6. It frees the buffer.
>>
>> While it may work on ep93xx, it's not respecting the DMA API rules,
>> and with DMA debugging enabled it will probably encounter quite a few
>> warnings.
>
> This patch fixes these violations.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Well... I'm not going to even pretend to actually understand the DMA API
at this point.  But, this patch seems to follow what DMA-API-HOWTO.txt
describes as the proper usage of the DMA API.

Also, with this patch and the others in your series my test systems are
still booting and working properly.

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
