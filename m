From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [ETH]: Combine format_addr() with print_mac().
Date: Fri, 21 Dec 2007 19:58:02 -0800
Message-ID: <1198295882.6752.9.camel@dell>
References: <1198274738.5578.2.camel@dell>
 <1198276619.18877.42.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>, anilgv@broadcom.com,
	michaelc@cs.wisc.edu, david.somayajulu@qlogic.com
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4937 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbXLVDNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 22:13:22 -0500
In-Reply-To: <1198276619.18877.42.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-12-21 at 14:36 -0800, Joe Perches wrote:
> On Fri, 2007-12-21 at 14:05 -0800, Michael Chan wrote:
> > diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> > index 6b2e454..f760d41 100644
> > --- a/net/ethernet/eth.c
> > +++ b/net/ethernet/eth.c
> > @@ -359,10 +359,33 @@ struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count)
> >  }
> >  EXPORT_SYMBOL(alloc_etherdev_mq);
> >  
> > +static ssize_t _format_mac_addr(char *buf, const unsigned char *addr, int len)
> > +{
> > +	int i;
> > +	char *cp = buf;
> > +
> > +	for (i = 0; i < len; i++) {
> > +		cp += sprintf(cp, "%02x", addr[i]);
> > +		if (i == len - 1)
> > +			break;
> > +		*cp++ = ':';
> > +	}
> > +	return cp - buf;
> > +}
> > +
> > +ssize_t format_mac_addr(char *buf, const unsigned char *addr, int len)
> > +{
> > +	ssize_t l;
> > +
> > +	l = _format_mac_addr(buf, addr, len);
> > +	strcpy(buf + l, "\n");
> > +	return l + 1;
> > +}
> > +EXPORT_SYMBOL(format_mac_addr);
> > +
> >  char *print_mac(char *buf, const u8 *addr)
> >  {
> > -	sprintf(buf, MAC_FMT,
> > -		addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
> > +	_format_mac_addr(buf, addr, ETH_ALEN);
> >  	return buf;
> >  }
> >  EXPORT_SYMBOL(print_mac);
> 
> I think const unsigned char *addr should be const u8 *addr

The dev_addr is declared as unsigned char* in struct net_device.  To be
consistent, can we change print_mac() and MAC_BUF to use unsigned char*?
They are really the same.

> ssize_t? shouldn't it be size_t?

I'm just keeping the prototype unchanged as originally defined in net-
sysfs.c

> Indexing buf by int len is unchecked.
> That could lead to unintended buffer overruns.
> Maybe add a buflen argument and use snprintf?

Again, I kept the semantics the same as the original, but will be happy
to add a buflen for better checking.

> 
> I had a patch that added some type-safety to print_mac
> and prevented this unintended buffer overrun.
> 
> It seems it wasn't applied.
> 
> ---------------------------------------
> 
> Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
> Date: Mon, 24 Sep 2007 10:28:36 -0700
> 
> Here is a patch that adds some type safety to print_mac
> by using a struct print_mac_buf * instead of char *.
> 
> It also reduces the defconfig vmlinux size by 8 bytes.
> 
> Signed-off-by:  Joe Perches <joe@perches.com>
> 
> --
> 
>  include/linux/if_ether.h |   12 ++++++++++--
>  net/ethernet/eth.c       |    6 +++---
>  2 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> index 57abca1..620d6b1 100644
> --- a/include/linux/if_ether.h
> +++ b/include/linux/if_ether.h
> @@ -126,7 +126,15 @@ extern struct ctl_table ether_table[];
>   *     Display a 6 byte device address (MAC) in a readable format.
>   */
>  #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
> -extern char *print_mac(char *buf, const u8 *addr);
> -#define DECLARE_MAC_BUF(var) char var[18] __maybe_unused
> +
> +struct print_mac_buf {
> +       char formatted_mac_addr[18];
> +};
> +
> +#define DECLARE_MAC_BUF(var) \
> +       struct print_mac_buf __maybe_unused _##var; \
> +       struct print_mac_buf __maybe_unused *var = &_##var
> +
> +extern char *print_mac(struct print_mac_buf *buf, const u8 *addr);
>  
>  #endif /* _LINUX_IF_ETHER_H */
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 2aaf6fa..ad82613 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -338,10 +338,10 @@ struct net_device *alloc_etherdev_mq(int
> sizeof_priv, unsigned int queue_count)
>  }
>  EXPORT_SYMBOL(alloc_etherdev_mq);
>  
> -char *print_mac(char *buf, const u8 *addr)
> +char *print_mac(struct print_mac_buf *buf, const u8 *addr)
>  {
> -       sprintf(buf, MAC_FMT,
> +       sprintf(buf->formatted_mac_addr, MAC_FMT,
>                 addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
> -       return buf;
> +       return buf->formatted_mac_addr;
>  }
>  EXPORT_SYMBOL(print_mac);
> 
> 
> 
> 

