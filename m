From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [Bugme-new] [Bug 12087] New: [drivers/net/cxgb3/sge.c:563]: Possible
 memory leak: s
Date: Thu, 27 Nov 2008 00:26:37 -0800
Message-ID: <492E59BD.8090202@chelsio.com>
References: <bug-12087-10286@http.bugzilla.kernel.org/> <20081122213532.fe01a22c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	danielm77@spray.se, Jay Cliburn <jacliburn@bellsouth.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:19693 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbYK0I1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 03:27:31 -0500
In-Reply-To: <20081122213532.fe01a22c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 22 Nov 2008 21:11:51 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=12087
>>
>>            Summary: [drivers/net/cxgb3/sge.c:563]: Possible memory leak: s
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: latest git tree
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: jgarzik@pobox.com
>>         ReportedBy: danielm77@spray.se
>>
>>
>> There will be a memory leak in the function alloc_ring when the parameter
>> sw_size is nonzero and metadata is NULL. I don't know if that can happen.
>>
>> Here is the code, taken from the latest git tree.
>>
>> static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
>>                         size_t sw_size, dma_addr_t * phys, void *metadata)
>> {
>>         size_t len = nelem * elem_size;
>>         void *s = NULL;
>>         void *p = dma_alloc_coherent(&pdev->dev, len, phys, GFP_KERNEL);
>>
>>         if (!p)
>>                 return NULL;
>>         if (sw_size) {
>>                 s = kcalloc(nelem, sw_size, GFP_KERNEL);
>>
>>                 if (!s) {
>>                         dma_free_coherent(&pdev->dev, len, p, *phys);
>>                         return NULL;
>>                 }
>>         }
>>         if (metadata)
>>                 *(void **)metadata = s;
>>         memset(p, 0, len);
>>         return p;
>> }
>>
>>
> 
> yeah, that is a bit silly-looking.

The following patch should hopefully take care of this issue:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=5256554489531f3e177e7308752d8f0681cdd5a6

Cheers,
Divy
