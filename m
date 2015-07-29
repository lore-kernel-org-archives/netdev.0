From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 4/8] xen: Use the correctly the Xen memory terminologies
Date: Wed, 29 Jul 2015 10:14:47 -0400
Message-ID: <55B8DFD7.6070107@oracle.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
 <1438095769-2560-5-git-send-email-julien.grall@citrix.com>
 <55B7D40B.5080903@oracle.com> <55B8B846.2060103@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Jiri Slaby <jslaby@suse.com>, Russell King <linux@arm.linux.org.uk>,
 linux-scsi@vger.kernel.org, x86@kernel.org,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, linux-input@vger.kernel.org,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com,
 "James E.J. Bottomley" <JBottomley@odin.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 linux-arm-kernel@lists.infradead.org, Juergen Gross <jgross@suse.com>,
 Wei Liu <wei.liu2@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Dmitry Torokhov <dmitry.torokhov@gmail.com>, linux-kernel@vger.kernel.org,
 David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org,
 =?windows-1252?Q?Roger_Pau_Monn=E9?
To: Julien Grall <julien.grall@citrix.com>, xen-devel@lists.xenproject.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <55B8B846.2060103@citrix.com>
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

On 07/29/2015 07:25 AM, Julien Grall wrote:
> Hi Boris,
>
> On 28/07/15 20:12, Boris Ostrovsky wrote:
>> On 07/28/2015 11:02 AM, Julien Grall wrote:
>>> Based on include/xen/mm.h [1], Linux is mistakenly using MFN when GFN
>>> is meant, I suspect this is because the first support for Xen was for
>>> PV. This brough some misimplementation of helpers on ARM and make the
>>> developper confused the expected behavior.
>>>
>>> For instance, with pfn_to_mfn, we expect to get an MFN based on the name.
>>> Although, if we look at the implementation on x86, it's returning a GFN.
>>>
>>> For clarity and avoid new confusion, replace any reference of mfn into
>>> gnf in any helpers used by PV drivers.
>>
>>
>>
>>
>>> @@ -730,7 +730,7 @@ static void xen_do_pin(unsigned level, unsigned
>>> long pfn)
>>>        struct mmuext_op op;
>>>
>>>        op.cmd = level;
>>> -    op.arg1.mfn = pfn_to_mfn(pfn);
>>> +    op.arg1.mfn = pfn_to_gfn(pfn);
>>
>>
>> This looks slightly odd. It is correct but given that purpose of this
>> series is to make things more clear perhaps we can add another union
>> member (gfn) to mmuext_op.arg1?
>>
>> (Of course, the hypervisor will continue referring to mfn which could
>> still be confusing)
>
> This operation is only used for PV guests, right?
>
> IHMO re-introducing pfn_to_mfn for PV-guests only (i.e with a BUG_ON to
> ensure no usage for auto-translated guest) would be the best solution.
> It would avoid to have different name than the hypersivor one in the
> hypercall interface. It will also make clear that virt_to_machine & co
> is only PV specific.
>
> I though doing this but I preferred to defer it to x86 expert as my
> knowledge for x86 Xen is very limited. I don't know where it's more
> suitable to use MFN or GFN. I guess this file (mmu.c) is mostly PV specific?
>
> Would something like below fine for you?
>
> static inline unsigned long pfn_to_mfn(unsigned long pfn)
> {
> 	unsigned long mfn;
>
> 	BUG_ON(xen_feature(XENFEAT_auto_translated_physmap));
>
> 	mfn = __pfn_to_mfn(pfn);
> 	if (mfn != INVALID_P2M_ENTRY)
> 		mfn &= ~(FOREIGN_FRAME_BIT | IDENTITY_FRAME_BIT);
>
> 	return mfn;
> }
>
> static inline unsigned long pfn_to_gfn(unsigned long pfn)
> {
> 	if (xen_feature(XENFEAT_autotranslated_physmap))
> 		return pfn;
> 	else
> 		return pfn_to_mfn(pfn);
> }


But you'd still say 'op.arg1.mfn = pfn_to_gfn(pfn);' in xen_do_pin() 
i.e. assign GFN to MFN, right? That's what I was referring to.

(In general, I am not sure a guest should ever use 'mfn' as it is purely 
a hypervisor construct. Including p2m, which I think should really be 
p2g as this is what we use to figure out what to stick into page tables)

-boris


>
> Similar splitting would be done for gfn_to_pfn and mfn_to_pfn.
>
> Regards,
>
