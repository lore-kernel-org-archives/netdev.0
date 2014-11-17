From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH Iproute2 next v1] ip link: Add ipvlan support to the
 iproute2/ip util
Date: Mon, 17 Nov 2014 13:54:43 -0800
Message-ID: <CAF2d9jgRE1K7We9wxfeofPhL8Lui7=TQgt+YCdi1pnkZ_cF7Kg@mail.gmail.com>
References: <1416205677-26706-1-git-send-email-maheshb@google.com> <CF9D1877D81D214CB0CA0669EFAE020C68CEC1DB@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Sathya Perla <Sathya.Perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:65062 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaKQVzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 16:55:06 -0500
Received: by mail-vc0-f175.google.com with SMTP id hy10so3839481vcb.34
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 13:55:04 -0800 (PST)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C68CEC1DB@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 16, 2014 at 10:57 PM, Sathya Perla <Sathya.Perla@emulex.com> wrote:
>
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> >
> > Adding basic support to create virtual devices using 'ip'
> > utility. Following is the syntax -
> >
> >       ip link add link <master> <virtual> type ipvlan mode [ l2 | l3 ]
> >       e.g. ip link add link eth0 ipvl0 type ipvlan mode l3
> >
> ..
> > ---
> >  include/linux/if_link.h | 14 ++++++++
> >  ip/Makefile             |  2 +-
> >  ip/iplink.c             |  2 +-
> >  ip/iplink_ipvlan.c      | 85
> > +++++++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 101 insertions(+), 2 deletions(-)
> >  create mode 100644 ip/iplink_ipvlan.c
> >
> > diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> > index 47320636361c..ef1e9f73fb15 100644
> > --- a/include/linux/if_link.h
> > +++ b/include/linux/if_link.h
> > @@ -325,6 +325,20 @@ enum macvlan_macaddr_mode {
> >       MACVLAN_MACADDR_SET,
> >  };
> >
> > +/* IPVLAN section */
> > +enum {
> > +     IFLA_IPVLAN_UNSPEC,
> > +     IFLA_IPVLAN_MODE,
> > +     __IFLA_IPVLAN_MAX,
> > +};
> > +
> > +#define IFLA_IPVLAN_MAX (__IFLA_IPVLAN_MAX - 1)
> > +
> > +enum ipvlan_mode {
> > +     IPVLAN_MODE_L2 = 0, /* Process packets all the way upto L2 */
> > +     IPVLAN_MODE_L3 = 1, /* Process Packets all the way upto L3 */
> > +};
> > +
> >  #define MACVLAN_FLAG_NOPROMISC       1
> >
> >... +
> > +#include <stdio.h>
> > +#include <stdlib.h>
> > +#include <string.h>
> > +#include <sys/socket.h>
> > +#include <linux/if_link.h>
> > +
> > +#include "rt_names.h"
> > +#include "utils.h"
> > +#include "ip_common.h"
> > +
> > +static void explain(void)
> > +{
> > +     fprintf(stderr, "Usage: ... ipvlan [ mode { l2 | l3 } ]\n");
> > +}
> > +
> > +static int mode_arg(void)
> > +{
> > +     fprintf(stderr, "Error: argument of \"mode\" must be either \"l2\", "
> > +             "or \"l3\"\n");
> > +        return -1;
> I guess you wanted to "return -1" from the caller routine ipvlan_parse_opt()
> and not from this routine.
>
Hmmm, that caught another error where I intended it to be "return
mode_arg()" instead of just "mode_arg" in the caller. This is clearly
wrong! Thanks for catching it.
> > +}
> > +
> > +static int ipvlan_parse_opt(struct link_util *lu, int argc, char **argv,
> > +                       struct nlmsghdr *n)
> > +{
> > +     while (argc > 0) {
> > +         if (matches(*argv, "mode") == 0) {
> > +                     __u16 mode = 0;
> > +                     NEXT_ARG();
> > +
> > +                     if (strcmp(*argv, "l2") == 0)
> > +                             mode = IPVLAN_MODE_L2;
> > +                     else if (strcmp(*argv, "l3") == 0)
> > +                             mode = IPVLAN_MODE_L3;
> > +                     else
> > +                             mode_arg();
> > +
> > +                     addattr16(n, 1024, IFLA_IPVLAN_MODE, mode);
> > +             } else if (matches(*argv, "help") == 0) {
> > +                     explain();
> > +                     return -1;
> > +             } else {
> > +                     fprintf(stderr, "ipvlan: unknown option \"%s\"?\n",
> > *argv);
> > +                     explain();
> > +                     return -1;
> > +             }
> > +             argc--, argv++;
> > +     }
> > +
> > +     return 0;
> > +}
> > +
