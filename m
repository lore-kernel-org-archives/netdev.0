From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Tue, 29 Nov 2011 17:19:30 +0000
Message-ID: <1322587170.2684.26.camel@bwh-desktop>
References: <20111109075449.13549.58135.stgit@rhel6.1>
	 <1321575301.2749.51.camel@bwh-desktop>  <4EC5A785.3060108@intel.com>
	 <1321577078.2749.58.camel@bwh-desktop>  <4EC68EBB.3080303@intel.com>
	 <1321638038.2883.28.camel@bwh-desktop>  <4ECA8D50.9080603@intel.com>
	 <1322584544.2684.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40999 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754469Ab1K2RTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 12:19:36 -0500
In-Reply-To: <1322584544.2684.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-29 at 16:35 +0000, Ben Hutchings wrote:
> On Mon, 2011-11-21 at 09:41 -0800, Greg Rose wrote:
> > On 11/18/2011 9:40 AM, Ben Hutchings wrote:
> [...]
> > > What concerns me is that this seems to be a workaround rather than a fix
> > > for over-use of promiscuous mode, and it changes the semantics of
> > > filtering modes in ways that haven't been well-specified.
> > 
> > I feel the opposite is true.  It allows a known set of receive filters 
> > so that you don't have to use promiscuous mode, which cuts down on 
> > overhead from processing packets the upper layer stack isn't really 
> > interested in.
> >
> > >
> > > What if there's a software bridge between two net devices corresponding
> > > to separate physical ports, so that they really need to be promiscuous?
> > > What if the administrator runs tcpdump and really wants the (PF) net
> > > device to be promiscuous?
> > 
> > I don't believe there is anything in this patch set that removes 
> > promiscuous mode operation as it is commonly used.  Perhaps I've missed 
> > something.
> [...]
> 
> Maybe I missed something!
> 
> Let's be clear on what our models are for filtering.  At the moment we
> have MAC filters set through ndo_set_rx_mode and VF filters set through
> ndo_set_vf_{mac,vlan}.
> 
> Ignoring anti-spoofing for the moment, should the currently defined
> filters look like this (a):
> 
>                 TX ^   | RX
>                    |   v
> +------------------+---+-----------------+
> |                  |  ++------------+    |
> |                  |  |RX MAC filter|    |
> |                  |  ++------------+    |
> |                  |   |match            |
> |                  ^   v                 |
> |                  |  ++------------+    |
> |                  |  |RX VF filters|    |
> |                  |  +-------+-----+    |
> |                 /|\     no /|\         |
> |                | | \ match/ | |match 2 |
> |                | ^  \    /  v |        |
> |                | |   \  /match|        |
> |                |  \   \/  1/  |        |
> |                |   \  /\  /   |        |
> |                ^    \/  \/    v        |
> |                |    /\  /\    |        |
> |                |   /  ||  \   |        |
> |                |  /   ||   \  |        |
> |                | /    ||    \ |        |
> |                ||     ||     ||        |
> +----------------++-----++-----++--------+
>                  ||     ||     ||
>                  PF    VF 1   VF 2
> 
> or like this (b):
> 
>                 TX ^   | RX
>                    |   v
> +------------------+---+-----------------+
> |                  |  ++------------+    |
> |                  |  |RX VF filters|    |
> |                  |  ++--------+---+    |
> |                  | no|match  /|        |
> |                  ^   v      | |        |
> |                  | +-+----+ | |        |
> |                  | |RX MAC| | |        |
> |                  | |filter| | |        |
> |                  | +------+ | |        |
> |                  |   |match | |        |
> |                 /|\  |      | |        |
> |                | | \ | match| |match 2 |
> |                | ^  \/    1 v |        |
> |                | |  /\      | |        |
> |                |  \/  \    /  |        |
> |                |  /\   \  /   |        |
> |                ^ /  \   \/    v        |
> |                ||    \  /\    |        |
> |                ||     ||  \   |        |
> |                ||     ||   \  |        |
> |                ||     ||    \ |        |
> |                ||     ||     ||        |
> +----------------++-----++-----++--------+
>                  ||     ||     ||
>                  PF    VF 1   VF 2
> 
> I think the current model is (a); do you agree?
> 
> So is the proposed new model something like this (c):

Corrected diagram:

                TX ^   | RX
                   |   v
+------------------+---+-----------------+
|                  |  ++------------+    |
|                  |  |RX MAC filter|    |
|                  ^  ++------------+    |
|                  |   |match            |
|          no match|   v                 |
|  +----------------+ ++------------+    |
|  |loopback filters| |RX VF filters|    |
|  +---------+-----++ +-------+-----+    |
|           /|\   /|\ match  /|\         |
|          v | `-+>+-+-.2   / | |        |
|           \ \  | |m \ \   / | |        |
|     match 0\ `-+-+.a \ \ /  v |        |
|             \  | | \t \ X   / |        |
|              \ |  \ \c X \ /  |        |
|               \|   \ \h \ X   |        |
|                \    \/\1 X \  v        |
|                ||   /\ |/ \ \ |        |
|                |v  /  ||   \ \|        |
|                || /   ^|    \ |        |
|                ||/    |v     ||        |
|                ||     ||     ||        |
+----------------++-----++-----++--------+
                 ||     ||     ||
                 PF    VF 1   VF 2

> (I've labelled the new filters as loopback filters here, and I'm still
> leaving out anti-spoofing.)
> 
> If not, please explain what the new model *is*.
> 
> Ben.
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
