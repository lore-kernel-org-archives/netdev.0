From: Vivek Kashyap <kashyapv@us.ibm.com>
Subject: Re: [Ipoverib] [PATCH] IPv6: Add correct padding
 to IPoIB link addr option
Date: Wed, 19 Jan 2005 00:18:37 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501190011440.19427-100000@localhost.localdomain>
References: <OF89EA98A0.9BCDAC57-ON87256F8E.00204D4F-65256F8E.002B4CC8@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
	netdev@oss.sgi.com, davem@davemloft.net, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF89EA98A0.9BCDAC57-ON87256F8E.00204D4F-65256F8E.002B4CC8@us.ibm.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

I suggest that the implementation discussion not be reflected on ipoverib. 
I've bcc'd to ipoverib for this mail. Those interested in the details can 
follow it on netdev/openib.

Thanks,
	Vivek

On Wed, 19 Jan 2005, Krishna Kumar wrote:

> 
> 
> 
> 
> 
> Hi Roland,
> 
> Couple of minor comments on this :
> 
> 1 : In  "+static int ndisc_addr_option_pad(unsigned short type)", change
> the function
>      name to ndisc_lladdr_option_pad() and the argument name to addr_type,
> to be
>      more precise ? addr_option seems confusing, unless it is known that
> this is a LL
>      address option (not a big deal, though).
> 
> 2. I know memset has optimized check for count, but isn't it better to
> check for pad
>     before this code since most of time it is going to be zero (unless you
> are doing only
>     IB traffic) ?
> 
> +           if (pad) {
>                   memset(opt + 2, 0, pad);
>                   opt   += pad;
>                   space -= pad;
> +           }
> 
> 3. I guess there is no clean way to avoid changing all consumers of ll_addr
> to not worry
>     about the padding after the length and before the LL address, but it
> would be nice if
>     that were possible (eg via the ndisc_parse_options).
> 
> Also, Dave/Yoshifuji, can't ndisc_options have just nd_opt_array[5] instead
> of nd_opt_array[7],
> with indices-1 being used to store/access the options ? In any case, I was
> expecting 6 rather
> than 7 in the current code, since there are 5 options with the array[0]
> being unused.
> 
> thanks,
> 
> - KK
> 
> 
> 
>                                                                        
>              YOSHIFUJI Hideaki                                         
>              / 吉藤英明                                      
>              <yoshfuji@linux-i                                          To
>              pv6.org>                  roland@topspin.com,             
>              Sent by:                  davem@davemloft.net             
>              netdev-bounce@oss                                          cc
>              .sgi.com                  netdev@oss.sgi.com,             
>                                        ipoverib@ietf.org,              
>                                        openib-general@openib.org       
>              01/19/2005 05:50                                      Subject
>              AM                        Re: [Ipoverib] [PATCH] IPv6: Add
>                                        correct padding to IPoIB link addr
>                                        option                          
>                                                                        
>                                                                        
>                                                                        
>                                                                        
>                                                                        
>                                                                        
> 
> 
> 
> 
> David, let me tkink about this.
> Thanks.
> 
> In article <528y6qej5w.fsf@topspin.com> (at Tue, 18 Jan 2005 09:33:47
> -0800), Roland Dreier <roland@topspin.com> says:
> 
> > +++ linux-bk/net/ipv6/ndisc.c            2005-01-14 21:20:55.736745091
> -0800
> > @@ -169,12 +169,33 @@
> >
> >  #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
> >
> > -static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int
> data_len)
> > +/*
> > + * Return the padding between the option length and the start of the
> > + * link addr.  Currently only IP-over-InfiniBand needs this, although
> > + * if RFC 3831 IPv6-over-Fibre Channel is ever implemented it may
> > + * also need a pad of 2.
> > + */
> > +static int ndisc_addr_option_pad(unsigned short type)
> > +{
> > +          switch (type) {
> > +          case ARPHRD_INFINIBAND: return 2;
> > +          default:                return 0;
> > +          }
> > +}
> > +
> > +static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int
> data_len,
> > +                                                unsigned short
> addr_type)
> >  {
> >            int space = NDISC_OPT_SPACE(data_len);
> > +          int pad   = ndisc_addr_option_pad(addr_type);
> >
> >            opt[0] = type;
> >            opt[1] = space>>3;
> > +
> > +          memset(opt + 2, 0, pad);
> > +          opt   += pad;
> > +          space -= pad;
> > +
> >            memcpy(opt+2, data, data_len);
> >            data_len += 2;
> >            opt += data_len;
> 
> --
> Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
> GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
> 
> 
