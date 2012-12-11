From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Tue, 11 Dec 2012 15:04:20 -0800
Message-ID: <1355267060.27891.139.camel@edumazet-glaptop>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	 <3246.1351717319@obiwan.sandelman.ca>
	 <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	 <87mwyi9h1x.fsf@xmission.com>
	 <alpine.OSX.2.00.1212111432430.78903@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: ani@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48473 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab2LKXEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 18:04:22 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so27783pad.19
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 15:04:22 -0800 (PST)
In-Reply-To: <alpine.OSX.2.00.1212111432430.78903@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 14:36 -0800, Ani Sinha wrote:
> >
> > It is possible to test for the presence of support of the new vlan bpf
> > extensions by attempting to load a filter that uses them.  As only valid
> > filters can be loaded, old kernels that do not support filtering of vlan
> > tags will fail to load the a test filter with uses them.
> 
> Unfortunately I do not see this. The sk_chk_filter() does not have a
> default in the case statement and the check will not detect an unknown
> instruction. It will fail when the filter is run and as far as I can see,
> the packet will be dropped. Something like this might help?
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c23543c..96338aa 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -548,6 +548,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>  			return -EINVAL;
>  		/* Some instructions need special checks */
>  		switch (code) {
> +		/* for unknown instruction, return EINVAL */
> +		default : return -EINVAL;
>  		case BPF_S_ALU_DIV_K:
>  			/* check for division by zero */
>  			if (ftest->k == 0)

This patch is wrong.

Check lines 546, 547, 548 where we do the check for unknown instructions

code = codes[code];
if (!code)
	return -EINVAL;

If you want to test ANCILLARY possible values, its already too late, as
old kernels wont use any patch anyway.
