From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 4/8] xen: Use the correctly the Xen memory terminologies
Date: Tue, 28 Jul 2015 15:12:11 -0400
Message-ID: <55B7D40B.5080903@oracle.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com> <1438095769-2560-5-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com,
	linux-kernel@vger.kernel.org,
	Russell King <linux@arm.linux.org.uk>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	=?UTF-8?B?Um9nZXIgUGF1IE1vbm7DqQ==?= <roger.pau@citrix.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Wei Liu <wei.liu2@citrix.com>, Juergen Gross <jgross@suse.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	linux-input@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-fbdev@vger.kernel.org, linux-ar
To: Julien Grall <julien.grall@citrix.com>,
	xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438095769-2560-5-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2015 11:02 AM, Julien Grall wrote:
> Based on include/xen/mm.h [1], Linux is mistakenly using MFN when GFN
> is meant, I suspect this is because the first support for Xen was for
> PV. This brough some misimplementation of helpers on ARM and make the
> developper confused the expected behavior.
>
> For instance, with pfn_to_mfn, we expect to get an MFN based on the name.
> Although, if we look at the implementation on x86, it's returning a GFN.
>
> For clarity and avoid new confusion, replace any reference of mfn into
> gnf in any helpers used by PV drivers.




> @@ -730,7 +730,7 @@ static void xen_do_pin(unsigned level, unsigned long pfn)
>   	struct mmuext_op op;
>
>   	op.cmd = level;
> -	op.arg1.mfn = pfn_to_mfn(pfn);
> +	op.arg1.mfn = pfn_to_gfn(pfn);


This looks slightly odd. It is correct but given that purpose of this 
series is to make things more clear perhaps we can add another union 
member (gfn) to mmuext_op.arg1?

(Of course, the hypervisor will continue referring to mfn which could 
still be confusing)


>
>   	xen_extend_mmuext_op(&op);
>   }
> @@ -1323,7 +1323,7 @@ static void __xen_write_cr3(bool kernel, unsigned long cr3)
>   	trace_xen_mmu_write_cr3(kernel, cr3);
>
>   	if (cr3)
> -		mfn = pfn_to_mfn(PFN_DOWN(cr3));
> +		mfn = pfn_to_gfn(PFN_DOWN(cr3));

Here too. And further down, thoughout this patch.




-boris
