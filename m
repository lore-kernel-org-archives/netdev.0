From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [DECNET] Endian bug fixes
Date: Mon, 06 Nov 2006 11:50:26 +0000
Message-ID: <1162813826.18219.47.camel@quoit.chygwyn.com>
References: <1162809062.27980.311.camel@quoit.chygwyn.com>
	 <20061106103243.GF29920@ftp.linux.org.uk>
	 <20061106103449.GG29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Caulfield <patrick@tykepenguin.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:13447 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752653AbWKFLsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 06:48:14 -0500
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20061106103449.GG29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 2006-11-06 at 10:34 +0000, Al Viro wrote:
> On Mon, Nov 06, 2006 at 10:32:43AM +0000, Al Viro wrote:
> > On Mon, Nov 06, 2006 at 10:31:02AM +0000, Steven Whitehouse wrote:
> > > +	opt->opt_optl   = dn_htons((__u16)*ptr++);
> > 
> > Lose that cast; it's only confusing the things...
> > 
> > > +	memcpy(opt->opt_data, ptr, dn_ntohs(opt->opt_optl));
> > > +	skb_pull(skb, dn_ntohs(opt->opt_optl) + 1);
> > 
> > ... and I'd actually do
> > 
> > 	u16 len = *ptr++; /* yes, it's 8bit on the wire */
> > 	opt->opt_optl   = dn_htons(len);
> > 	BUG_ON(len > 16); /* we've checked the contents earlier */
> > 	memcpy(opt->opt_data, ptr, len);
> > 	skb_pull(skb, len + 1);
> 
> BTW, why the hell do we keep ->opt_optl __le16 internally?  If we ever
> pass it to userland, fine, but let's convert to __le16 *then*...

Really the only thing that we do with this data is verify it and pass to
userland. It does mean that getsockopt() is simpler for just being able
to use copy_to_user() with a ptr & len depending on which of the
structures the user has requested rather than having to convert each
field of each structure for example.

I'm not sure its worth changing it now, for saving just one byte per
socket in this case,

Steve.


