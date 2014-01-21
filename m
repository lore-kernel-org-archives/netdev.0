From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v3] xen/grant-table: Avoid m2p_override during
 mapping
Date: Tue, 21 Jan 2014 13:40:15 +0000
Message-ID: <52DE78BF.2070909@citrix.com>
References: <1390244288-3186-1-git-send-email-zoltan.kiss@citrix.com> <alpine.DEB.2.02.1401211217510.21510@kaball.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <jonathan.davies@citrix.com>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1401211217510.21510@kaball.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/01/14 12:26, Stefano Stabellini wrote:
> On Mon, 20 Jan 2014, Zoltan Kiss wrote:
>
>> -		ret = m2p_add_override(mfn, pages[i], kmap_ops ?
>> -				       &kmap_ops[i] : NULL);
>> +		if (m2p_override)
>> +			ret = m2p_add_override(mfn, pages[i], kmap_ops ?
>> +					       &kmap_ops[i] : NULL);
>> +		else {
>> +			unsigned long pfn = page_to_pfn(pages[i]);
>> +			WARN_ON(PagePrivate(pages[i]));
>> +			SetPagePrivate(pages[i]);
>> +			set_page_private(pages[i], mfn);
>> +			pages[i]->index = pfn_to_mfn(pfn);
>> +			if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn))))
>> +				return -ENOMEM;
> 
> What happens if the page is PageHighMem?
> 
> This looks like a subset of m2p_add_override, but it is missing some
> relevant bits, like the PageHighMem check, or the p2m(m2p(mfn)) == mfn
> check.  Maybe we can find a way to avoid duplicating the code.
> We could split m2p_add_override in two functions or add yet another
> parameter to it.

The PageHighMem() check isn't relevant as we're not mapping anything
here.  Also, a page for a kernel grant mapping only cannot be highmem.

The check for a local mfn and the additional set_phys_to_machine() is
only necessary if something tries an mfn_to_pfn() on the local mfn.  We
can only omit adding an m2p override if we know thing will try
mfn_to_pfn(), therefore the check and set_phys_to_machine() is unnecessary.

David
