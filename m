From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Thu, 13 Aug 2009 22:24:20 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6B0C7112@GVW1118EXC.americas.hpqcorp.net>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net>
 <0199E0D51A61344794750DC57738F58E6D6AE99C53@GVW1118EXC.americas.hpqcorp.net>
 <001001ca1a93$b6e50ee0$24af2ca0$@edu> <200908121519.36808.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	'Eric Biederman' <ebiederm@xmission.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755292AbZHMWYz@vger.kernel.org>
In-Reply-To: <200908121519.36808.arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
> 
> On Tuesday 11 August 2009, Paul Congdon (UC Davis) wrote:
> > > >
> > > > The patch from Eric Biederman to allow macvlan to bridge between
> > > > its slave ports is at
> > > >
> > > > http://kerneltrap.org/mailarchive/linux-netdev/2009/3/9/5125774
> > >
> > > Looking through the discussions here, it does not seem as if a
> decision
> > > was made to integrate those patches, because they would make the
> > > macvlan interface behave too much like a bridge.
> 
> Right, that question is still open, and dont't see it as very important
> right now, as long as we can still use it for VEPA.
> 
> > > Also, it seems as if there was still a problem with doing
> > > multicast/broadcast delivery when enabling local VM-to-VM
> > > communication. Is that solved by now?
> 
> Not yet, but I guess it comes as a natural extension when I fix
> multicast/broadcast delivery from the reflective relay for VEPA.
> 
> The logic that I would use there is:
> 
> broadcast from a dowstream port:
>      if (bridge_mode(source_port)) {
>           forward_to_upstream(frame);
>           for_each_downstream(port) {
>                 /* deliver to all bridge ports except self, do
>                    not deliver to any VEPA port. */
>                 if (bridge_mode(port) && port != source_port) {
>                        forward_to_downstream(frame, port);
>                 }
>           }
>      } else {
>           forward_to_upstream(frame);
>      }
> 
> 
> broadcast from the upstream port
>      if (bridge_mode(frame.source)) {
>           /* comes from a port in bridge mode, so has already been
>              delivered to all other bridge ports */
>           for_each_downstream(port) {
>                 if (!bridge_mode(port)) {
>                          forward_to_downstream(frame, port);
>                 }
>           }
>      } else if (vepa_mode(frame.source)) {
>           /* comes from VEPA port, so need to deliver to all
>              bridge and all vepa ports except self */
>           for_each_downstream(port) {
>                 if (port != frame.source)
>                        forward_to_downstream(frame, port);
>      } else {
>           /* external source, so flood to everyone */
>           for_each_downstream(port) {
>                 forward_to_downstream(frame, port);
>      }
> 
> For multicast, we can do the same, or optionally add a per-port filter
> as you mentioned, if it becomes a bottleneck.
> 
> Do you think this addresses the problem, or did I miss something
> important?

Yes, I think this addresses the problem. It would be very useful if
this functionality was in macvlan.

Thanks,
Anna
