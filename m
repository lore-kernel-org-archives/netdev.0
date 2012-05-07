From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 7 May 2012 14:22:32 +0200
Message-ID: <20120507122232.GA32146@1984>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
 <201205071114.35324.hans.schillstrom@ericsson.com>
 <20120507115612.GA31110@1984>
 <201205071409.47945.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49917 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756159Ab2EGMWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 08:22:35 -0400
Content-Disposition: inline
In-Reply-To: <201205071409.47945.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 07, 2012 at 02:09:46PM +0200, Hans Schillstrom wrote:
> On Monday 07 May 2012 13:56:12 Pablo Neira Ayuso wrote:
> > On Mon, May 07, 2012 at 11:14:34AM +0200, Hans Schillstrom wrote:
> > > > > We have plenty of rules where just source port mask is zero.
> > > > > and the dest-port-mask is 0xfffc (or 0xffff)
> > > > 
> > > > 0xffff and 0x0000 means on/off respectively.
> > > > 
> > > > Still curious, how can 0xfffc be useful?
> > > 
> > > That's a special case where an appl is using 4 ports.
> > > But in general, have not seen other than "on/off" except for above.
> > 
> > I see. Well I'm fine with this way to switch on/off things, just
> > wanted some clafication.
> > 
> > Still one final thing I'd like to remove before inclusion:
> > 
> > +       union hmark_ports       port_mask;
> > +       union hmark_ports       port_set;
> > +       __u32                   spi_mask;
> > +       __u32                   spi_set;
> > 
> > the spi_mask seems redundant. The port_mask already provides u32 for
> > it.
> 
> No problems, I'll remove it.

OK. As a nice side-effect, this will lead to removing the branch that
tests ESP/AH in hmark_set_tuple_ports.

Please, use the patch that I sent you yesterday. Recover the swap
behaviour that you need, I'll mangle the patch myself to add the
little comment to explain why we do this with CT as well.

BTW, note that you do *not* have to remove the XT_HMARK_SPI flags, we
still need those for iptables-save.

While at it:

+enum {                      
+       XT_HMARK_NONE,       
+       XT_HMARK_SADR_AND,   
+       XT_HMARK_DADR_AND,   
+       XT_HMARK_SPI_AND,    
+       XT_HMARK_SPI_OR,    

remove all trailing _OR

+       XT_HMARK_SPORT_AND,  
+       XT_HMARK_DPORT_AND,  
+       XT_HMARK_SPORT_OR,   
+       XT_HMARK_DPORT_OR,   
+       XT_HMARK_PROTO_AND,

rename all _AND by _MASK.

+       XT_HMARK_RND,        
+       XT_HMARK_MODULUS,    
+       XT_HMARK_OFFSET,     
+       XT_HMARK_CT,         
+       XT_HMARK_METHOD_L3,  
+       XT_HMARK_METHOD_L3_4,
};

What I'm asking should require very little changes in the kernel-code.

> > In case you want to support different masks for AH/ESP and TCP, you
> > could do the following:
> > 
> > iptables -I PREROUTING -t mangle -p esp -j HARK --spi-mask 0xffff0000
> > iptables -I PREROUTING -t mangle -p tcp -j HARK --port-mask 0xfffc
> > 
> > Any objection?
> 
> I don't think this is a problem, but it should be written in the man page
> that ports and spi share mask so they can't be used at the same time.

documentation is fine.

iptables can stop this by spotting a warning message from user-space.
