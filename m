From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: [PATCH 1/4] net: thunderx: Fix IOMMU translation faults
Date: Mon, 6 Mar 2017 16:32:54 +0000
Message-ID: <9a809c6e-3b01-4deb-e69e-65aa62d1e5e1@arm.com>
References: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
 <1488538070-12549-2-git-send-email-sunil.kovvuri@gmail.com>
 <20170303.095635.355325147613813698.davem@davemloft.net>
 <CA+sq2CcFxk=LuqYhR-sFaVVSu3rMaZUcytx-3tC9kEiRFNwREg@mail.gmail.com>
 <cad7da5d-fce7-cef2-d0db-9585c31f0575@arm.com>
 <CA+sq2CeiXZNwVsURxNNE+vxf3uhjM=vnKtb2nhtLRj6QwHKWrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
 Sunil Goutham <sgoutham@cavium.com>, David Miller <davem@davemloft.net>,
 LAKML <linux-arm-kernel@lists.infradead.org>,
 LKML <linux-kernel@vger.kernel.org>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CA+sq2CeiXZNwVsURxNNE+vxf3uhjM=vnKtb2nhtLRj6QwHKWrw@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 06/03/17 12:57, Sunil Kovvuri wrote:
>>>
>>> We are seeing a 0.75Mpps drop with IP forwarding rate due to that.
>>> Hence I have restricted calling DMA interfaces to only when IOMMU is enabled.
>>
>> What's 0.07Mpps as a percentage of baseline? On a correctly configured
>> coherent arm64 system, in the absence of an IOMMU, dma_map_*() is
>> essentially just virt_to_phys() behind a function call or two, so I'd be
>> interested to know where any non-trivial overhead might be coming from.
> 
> It's a 5% drop and yes device is configured as coherent.
> And the drop is due to additional function calls.

OK, interesting - sounds like there's potential for some optimisation
there as well. AFAICS the callchain goes:

dma_map_single_attrs (inline)
- ops->map_page (__swiotlb_map_page)
  - swiotlb_map_page
    - phys_to_dma (inline)
    - dma_capable (inline)

Do you happen to have a breakdown of where the time goes? If it's mostly
just in the indirect branch our options are limited (I'm guessing
ThunderX doesn't have a particularly fancy branch predictor, if it's not
even got a data prefetcher), but if it's in the SWIOTLB code then
there's certainly room for improvement (which will hopefully tie in with
some DMA ops work I'm planning to do soon anyway).

Thanks,
Robin.

> 
> Thanks,
> Sunil.
> 
