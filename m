From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/5] qlge: bugfix: Fix endian issue regarding shadow
	registers.
Date: Wed, 24 Dec 2008 16:15:21 -0500
Message-ID: <20081224211521.GA25617@infradead.org>
References: <20081224181834.GA15470@susedev.qlogic.org> <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com> <1230143731.3070.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ron Mercer <ron.mercer@qlogic.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34668 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYLXVPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 16:15:23 -0500
Content-Disposition: inline
In-Reply-To: <1230143731.3070.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 06:35:31PM +0000, Ben Hutchings wrote:
> > -static inline unsigned int ql_read_sh_reg(const volatile void  *addr)
> > +static inline u32 ql_read_sh_reg(const volatile void  *addr)
> >  {
> > -	return *(volatile unsigned int __force *)addr;
> > +	return le32_to_cpu(*(volatile unsigned int __force *)addr);
> 
> I think that should be:
> 	???return le32_to_cpu(*(const volatile __le32 *)addr);

No.  It needs more love than that.

ql_read_sh_reg is only used to access .prod_idx_sh_reg in the rx_ring
structure, which is an offset from the .rx_ring_shadow_reg_area member.
So instead of all this werid casting .prod_idx_sh_reg should simply
be a __le32 pointer, whithout volatile and the other mess, and then
you can use le32_to_cpu directly and kill the helper.

And please verify the whole driver for endianess issues using sparse
while you're at it...
