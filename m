From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Wed, 12 Aug 2009 15:19:36 +0200
Message-ID: <200908121519.36808.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net> <0199E0D51A61344794750DC57738F58E6D6AE99C53@GVW1118EXC.americas.hpqcorp.net> <001001ca1a93$b6e50ee0$24af2ca0$@edu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'Fischer, Anna'" <anna.fischer@hp.com>,
	"'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	evb@yahoogroups.com, davem@davemloft.net, kaber@trash.net,
	adobriyan@gmail.com, "'Eric Biederman'" <ebiederm@xmission.com>
To: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:63576 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbZHLNUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 09:20:14 -0400
In-Reply-To: <001001ca1a93$b6e50ee0$24af2ca0$@edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 August 2009, Paul Congdon (UC Davis) wrote:
> > >
> > > The patch from Eric Biederman to allow macvlan to bridge between
> > > its slave ports is at
> > >
> > > http://kerneltrap.org/mailarchive/linux-netdev/2009/3/9/5125774
> > 
> > Looking through the discussions here, it does not seem as if a decision
> > was made to integrate those patches, because they would make the
> > macvlan interface behave too much like a bridge. 

Right, that question is still open, and dont't see it as very important
right now, as long as we can still use it for VEPA.

> > Also, it seems as if there was still a problem with doing
> > multicast/broadcast delivery when enabling local VM-to-VM
> > communication. Is that solved by now?

Not yet, but I guess it comes as a natural extension when I fix
multicast/broadcast delivery from the reflective relay for VEPA.

The logic that I would use there is:

broadcast from a dowstream port:
     if (bridge_mode(source_port)) {
          forward_to_upstream(frame);
          for_each_downstream(port) {
                /* deliver to all bridge ports except self, do
                   not deliver to any VEPA port. */
                if (bridge_mode(port) && port != source_port) {
                       forward_to_downstream(frame, port);
                }
          }
     } else {
          forward_to_upstream(frame);
     }


broadcast from the upstream port
     if (bridge_mode(frame.source)) {
          /* comes from a port in bridge mode, so has already been
             delivered to all other bridge ports */
          for_each_downstream(port) {
                if (!bridge_mode(port)) {
                         forward_to_downstream(frame, port);
                }
          }
     } else if (vepa_mode(frame.source)) {
          /* comes from VEPA port, so need to deliver to all
             bridge and all vepa ports except self */
          for_each_downstream(port) {
                if (port != frame.source)
                       forward_to_downstream(frame, port);
     } else {
          /* external source, so flood to everyone */
          for_each_downstream(port) {
                forward_to_downstream(frame, port);
     }

For multicast, we can do the same, or optionally add a per-port filter
as you mentioned, if it becomes a bottleneck. 

Do you think this addresses the problem, or did I miss something important?

> Also, is there a solution, or plans for a solution, to address macvtap
> interfaces that are set to 'promiscuous' mode?  It would seem fairly easy to
> support this for interfaces that are simply trying to listen to the port
> (e.g. Wireshark). 

If you want to use tcpdump or wireshark on all ports simulateously in a pure
VEPA, you can still attach it to the 'lowerdev', e.g. eth0 or eth0.2 (for macvlan
nested in vlan).
If we allow bridge ports, we might want to extend the local delivery
to also go through all the hooks of the external port, so that you can
attach packet sockets there.

> If the port was being used by something like a firewall
> then the VEPA filtering doesn't work too well.

Not sure what you mean. Are you talking about a firewall separating the guests
from the outside, between the VEPA and the reflective relay, or a firewall between
the guests in case of local delivery?

	Arnd <><
