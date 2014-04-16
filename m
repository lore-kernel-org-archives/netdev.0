From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn: icn: buffer overflow in icn_command()
Date: Wed, 16 Apr 2014 14:16:53 +0300
Message-ID: <20140416111653.GF4963@mwanda>
References: <20140414080756.GA13372@mwanda>
 <1397490748.2803.18.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38608 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaDPLRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 07:17:17 -0400
Content-Disposition: inline
In-Reply-To: <1397490748.2803.18.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2014 at 08:52:28AM -0700, Joe Perches wrote:
> On Mon, 2014-04-14 at 11:07 +0300, Dan Carpenter wrote:
> > The cbuf[] buffer is 60 characters but we're putting a potential 79
> > characters and a NUL into it.  I've made it 80 characters and changed
> > the sprintf() to snprintf().
> []
> > @@ -1309,7 +1309,6 @@ icn_command(isdn_ctrl *c, icn_card *card)
> >  			break;
> >  		if ((c->arg & 255) < ICN_BCH) {
> >  			char *p;
> > -			char dial[50];
> >  			char dcode[4];
> 
> The change log does not mentioned removal of dial.
> 

Oops.  Sorry about that.

> As this subsystem likely has 0 active users, perhaps
> making the minimal correctness change might be better.
> 
> Also, if making other changes, perhaps it'd be better
> to similarly replace dcode with a pointer as well.

I thought about that when I was writing the patch, but I wanted to make
minimal changes.  The dial change is necessary because static checkers
would assume we are using all 50 characters of the dial[] buffer instead
of just the first 32.

> 
> > @@ -1321,10 +1320,10 @@ icn_command(isdn_ctrl *c, icn_card *card)
> >  			} else
> >  				/* Normal Dial */
> >  				strcpy(dcode, "CAL");
> > -			strcpy(dial, p);
> > -			sprintf(cbuf, "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
> > -				dcode, dial, c->parm.setup.si1,
> > -				c->parm.setup.si2, c->parm.setup.eazmsn);
> > +			snprintf(cbuf, sizeof(cbuf),
> > +				 "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
> > +				 dcode, p, c->parm.setup.si1,
> > +				 c->parm.setup.si2, c->parm.setup.eazmsn);
> >  			i = icn_writecmd(cbuf, strlen(cbuf), 0, card);
> 
> Maybe save the snprintf result length and use it
> in icn_writecmd too.
> 

snprintf() returns the number of bytes which would have been printed if
there were enough space and not the number of bytes in the string.
Using the value from snprintf() would not introduce a bug because I have
carefully counted the number of bytes in the output string, but it would
hopefully annoy human auditors of this code.  ;)  You are thinking of
scnprintf().

I'm going to apply your minimal changes suggestion here.

regards,
dan carpenter
