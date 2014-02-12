From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Wed, 12 Feb 2014 06:56:36 -0800
Message-ID: <CAPcyv4hrVBLghSWB=vRoe_iAcWzRL5ZiN6SXrLmCbHx++hixBA@mail.gmail.com>
References: <1859471893.20140126115521@eikelenboom.it>
	<20140127000305.GA14236@electric-eye.fr.zoreil.com>
	<CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	<84816226.20140206123631@eikelenboom.it>
	<942972114.20140206140909@eikelenboom.it>
	<CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	<1434499348.20140211205617@eikelenboom.it>
	<CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
	<1392178661.1752.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392178661.1752.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 11, 2014 at 8:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-02-11 at 18:07 -0800, Dan Williams wrote:
>
>> The overlap granularity is too large.  Multiple dma_map_single
>> mappings are allowed to a given page as long as they don't collide on
>> the same cache line.
>>
>
> I am not sure why you try number of mappings of a page.

For this debug facility I am tracking whether dma has completed by
making sure there are no active dma_map entries in the address range
of a page being cow'd.

> Try launching 100 concurrent netperf -t TCP_SENFILE
>
> Same page might be mapped more than 100 times, more than 10000 times in
> some cases.
>

Aren't these mapping serialized by the device to some extent?
Although multi-queue / multi-device would even defeat that...

Hmm, then I think at a minimum the activity tracking needs to be
constrained to overlapping DMA_FROM_DEVICE or DMA_BIDIRECTIONAL
mappings.  However, I am still operating on the assumption that some
architectures (especially non-io-coherent or dmabounce architectures)
expect a dma mapping to reflect exclusive ownership of the buffer.
>From the conversation I had with Russell, back in the day [1]:

"When we get to the second async_xor(), as we haven't started to run any
of these operations, the source and destination buffers are still mapped.
However, we ignore that and call dma_map_page() on them again - this is
illegal because the CPU does not own these buffers."

It might be the case that we can't have a general overlap detection
facility as it will flag stable use cases that nonetheless violate the
exclusivity expectation.

--
Dan

[1]: http://marc.info/?l=linux-arm-kernel&m=129389649101566&w=2
