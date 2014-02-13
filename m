From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7 overlapping mappings of pfn 55ebe
Date: Thu, 13 Feb 2014 22:49:22 +0100
Message-ID: <343228200.20140213224922@eikelenboom.it>
References: <1859471893.20140126115521@eikelenboom.it> <20140127000305.GA14236@electric-eye.fr.zoreil.com> <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com> <84816226.20140206123631@eikelenboom.it> <942972114.20140206140909@eikelenboom.it> <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com> <1434499348.20140211205617@eikelenboom.it> <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com> <1392178661.1752.1.camel@edumazet-glaptop2.roam.corp.google.com> <1392322487.11022.4.camel@dwillia2-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392322487.11022.4.camel@dwillia2-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Thursday, February 13, 2014, 9:14:47 PM, you wrote:

> On Tue, 2014-02-11 at 20:17 -0800, Eric Dumazet wrote:
>> On Tue, 2014-02-11 at 18:07 -0800, Dan Williams wrote:
>> 
>> > The overlap granularity is too large.  Multiple dma_map_single
>> > mappings are allowed to a given page as long as they don't collide on
>> > the same cache line.
>> > 
>> 
>> I am not sure why you try number of mappings of a page.
>> 
>> Try launching 100 concurrent netperf -t TCP_SENFILE
>> 
>> Same page might be mapped more than 100 times, more than 10000 times in
>> some cases.

> Thanks for that test case.

> I updated the fix patch with the following.

> diff --git a/lib/dma-debug.c b/lib/dma-debug.c
> index 42b12740940b..611010df1e9c 100644
> --- a/lib/dma-debug.c
> +++ b/lib/dma-debug.c
> @@ -513,6 +513,13 @@ static int active_cln_insert(struct dma_debug_entry *entry)
>         unsigned long flags;
>         int rc;
>  
> +       /* If the device is not writing memory then we don't have any
> +        * concerns about the cpu consuming stale data.  This mitigates
> +        * legitimate usages of overlapping mappings.
> +        */
+       if (entry->>direction == DMA_TO_DEVICE)
> +               return 0;
> +
>         spin_lock_irqsave(&radix_lock, flags);
>         rc = radix_tree_insert(&dma_active_cacheline, to_cln(entry), entry);
>         if (rc == -EEXIST)
> @@ -526,6 +533,10 @@ static void active_cln_remove(struct dma_debug_entry *entry)
>  {
>         unsigned long flags;
>  
> +       /* ...mirror the insert case */
+       if (entry->>direction == DMA_TO_DEVICE)
> +               return;
> +
>         spin_lock_irqsave(&radix_lock, flags);
>         /* since we are counting overlaps the final put of the
>          * cacheline will occur when the overlap count is 0.


> Sander, barring a negative test result from you I'll send the attached
> patch to Andrew.

Hi Dan,

That seems to effectively suppress the warning, thanks and:

Tested-by; Sander Eikelenboom <linux@eikelenboom.it>

--
Sander

> --
> Dan
