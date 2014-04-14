From: Joe Perches <joe@perches.com>
Subject: Re: [patch] isdn: icn: buffer overflow in icn_command()
Date: Mon, 14 Apr 2014 08:52:28 -0700
Message-ID: <1397490748.2803.18.camel@joe-AO722>
References: <20140414080756.GA13372@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140414080756.GA13372@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-14 at 11:07 +0300, Dan Carpenter wrote:
> The cbuf[] buffer is 60 characters but we're putting a potential 79
> characters and a NUL into it.  I've made it 80 characters and changed
> the sprintf() to snprintf().
[]
> @@ -1309,7 +1309,6 @@ icn_command(isdn_ctrl *c, icn_card *card)
>  			break;
>  		if ((c->arg & 255) < ICN_BCH) {
>  			char *p;
> -			char dial[50];
>  			char dcode[4];

The change log does not mentioned removal of dial.

As this subsystem likely has 0 active users, perhaps
making the minimal correctness change might be better.

Also, if making other changes, perhaps it'd be better
to similarly replace dcode with a pointer as well.

> @@ -1321,10 +1320,10 @@ icn_command(isdn_ctrl *c, icn_card *card)
>  			} else
>  				/* Normal Dial */
>  				strcpy(dcode, "CAL");
> -			strcpy(dial, p);
> -			sprintf(cbuf, "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
> -				dcode, dial, c->parm.setup.si1,
> -				c->parm.setup.si2, c->parm.setup.eazmsn);
> +			snprintf(cbuf, sizeof(cbuf),
> +				 "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
> +				 dcode, p, c->parm.setup.si1,
> +				 c->parm.setup.si2, c->parm.setup.eazmsn);
>  			i = icn_writecmd(cbuf, strlen(cbuf), 0, card);

Maybe save the snprintf result length and use it
in icn_writecmd too.


