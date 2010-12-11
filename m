From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control (user-space)
Date: Sat, 11 Dec 2010 14:10:48 +0900
Message-ID: <20101211051048.GD32453@verge.net.au>
References: <1292040838-10579-1-git-send-email-horms@verge.net.au>
 <1292042650.3136.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47771 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab0LKFKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 00:10:52 -0500
Content-Disposition: inline
In-Reply-To: <1292042650.3136.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 11, 2010 at 04:44:10AM +0000, Ben Hutchings wrote:
> On Sat, 2010-12-11 at 13:13 +0900, Simon Horman wrote:
> [...]
> > diff --git a/ethtool.c b/ethtool.c
> > index 239912b..579b4e4 100644
> > --- a/ethtool.c
> > +++ b/ethtool.c
> > @@ -163,7 +163,8 @@ static struct option {
> >  		"		[ xcvr internal|external ]\n"
> >  		"		[ wol p|u|m|b|a|g|s|d... ]\n"
> >  		"		[ sopass %x:%x:%x:%x:%x:%x ]\n"
> > -		"		[ msglvl %d | msglvl type on|off ... ]\n" },
> > +		"		[ msglvl %d | msglvl type on|off ... ]\n"
> > +		"		[ early-orphan on|off ]\n" },
> >      { "-a", "--show-pause", MODE_GPAUSE, "Show pause options" },
> >      { "-A", "--pause", MODE_SPAUSE, "Set pause options",
> >        "		[ autoneg on|off ]\n"
> > @@ -411,6 +412,10 @@ static int msglvl_changed;
> >  static u32 msglvl_wanted = 0;
> >  static u32 msglvl_mask = 0;
> >  
> > +static u32 generic_flags_changed;
> > +static u32 generic_flags_wanted = 0;
> > +static u32 generic_flags_mask = 0;
> > +
> >  static enum {
> >  	ONLINE=0,
> >  	OFFLINE,
> > @@ -608,6 +613,11 @@ static struct cmdline_info cmdline_msglvl[] = {
> >  	  NETIF_MSG_WOL, &msglvl_mask },
> >  };
> >  
> > +static struct cmdline_info cmdline_generic_flags[] = {
> > +	{ "early-orphan", CMDL_FLAG, &generic_flags_wanted, NULL,
> > +	  ETH_FLAG_EARLY_ORPHAN, &generic_flags_mask },
> > +};
> > +
> >  static long long
> >  get_int_range(char *str, int base, long long min, long long max)
> >  {
> > @@ -1125,7 +1135,13 @@ static void parse_cmdline(int argc, char **argp)
> >  				}
> >  				break;
> >  			}
> > -			show_usage(1);
> > +			parse_generic_cmdline(
> > +					argc, argp, i,
> > +					&generic_flags_changed,
> > +					cmdline_generic_flags,
> > +					ARRAY_SIZE(cmdline_generic_flags));
> > +			i = argc;
> > +			break;
> 
> This seems to introduce an order-dependency which doesn't exist with any
> of the other keyword arguments after -s.

Perhaps it would be better to just open-code the parsing
as per the rest of parse_generic_cmdline()?

> [...]
> > +       if (generic_flags_changed) {
> > +               printf("generic flags changed\n");
> > +               struct ethtool_value edata;
> > +
> > +               edata.cmd = ETHTOOL_GFLAGS;
> > +               edata.data = 0;
> > +               ifr->ifr_data = (caddr_t)&edata;
> > +               err = ioctl(fd, SIOCETHTOOL, ifr);
> > +               if (err) {
> > +                       perror("Cannot get device flag settings");
> > +                       return 91;
> > +               }
> > +
> > +               edata.cmd = ETHTOOL_SFLAGS;
> > +               edata.data = ((edata.data & ~generic_flags_mask) |
> > +                             generic_flags_wanted);
> > +
> > +               err = ioctl(fd, SIOCETHTOOL, ifr);
> > +               if (err)
> > +                       perror("Cannot set device flag settings");
> > +       }
> >         return 0;
> >  }
> [...]
> 
> This has a silent failure case (silent to any script checking the exit
> code, anyway).

Oops, sorry about that. I think that it should be:

                err = ioctl(fd, SIOCETHTOOL, ifr);
                if (err) {
                        perror("Cannot set device flag settings");
                        return 92;
                }

