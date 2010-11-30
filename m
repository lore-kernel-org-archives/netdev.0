From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] Net-ethtool : Allow ethtool to set interface in loopback mode.
Date: Tue, 30 Nov 2010 11:05:41 -0800
Message-ID: <AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
	<1291129305.21077.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	laurent chavey <chavey@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:33096 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab0K3TFq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 14:05:46 -0500
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id oAUJ5iJx017833
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:05:44 -0800
Received: from bwz2 (bwz2.prod.google.com [10.188.26.2])
	by kpbe12.cbf.corp.google.com with ESMTP id oAUJ5gsV003965
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:05:42 -0800
Received: by bwz2 with SMTP id 2so19227209bwz.27
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:05:41 -0800 (PST)
In-Reply-To: <1291129305.21077.9.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 7:01 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> On Tue, 2010-11-30 at 00:00 -0800, Mahesh Bandewar wrote:
> > This patch enables ethtool to set the loopback mode on a given
> > interface. This is the reworked version of earlier submit (which I
> > don't have reference to). By configuring the interface in loopback
> > mode in conjunction with a policy route / rule, a userland applicat=
ion
> > can stress the egress / ingress path exposing the flows of the chan=
ge
> > in progress and potentially help developer(s) understand the impact=
 of
> > those changes without even sending a packet out on the network.
>
> Is the aim to stress the generic egress/ingress code or also to cover
> the specific driver in use?
>
The idea is to stress maximum egress / ingress path, so if possible
include the driver portion of that path too.

> I note that your colleague Laurent Chavey posted a very similar patch
> back in April <http://article.gmane.org/gmane.linux.network/157489> b=
ut
> he emphasised hardware diagnosis.
>
Hardware diagnostic folks are also welcome to use it if they find it
useful apart
from the tools they already have. :)

> > Following set of commands illustrates one such example -
> > =A0 =A0 a) ifconfig eth1 192.168.1.1
> > =A0 =A0 b) ip -4 rule add from all iif eth1 lookup 250
> > =A0 =A0 c) ip -4 route add local 0/0 dev lo proto kernel scope host=
 table 250
> > =A0 =A0 d) arp -Ds 192.168.1.100 eth1
> > =A0 =A0 e) arp -Ds 192.168.1.200 eth1
> > =A0 =A0 f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
> > =A0 =A0 g) sysctl -w net.ipv4.conf.all.accept_local=3D1
> > =A0 =A0 # Assuming that the machine has 8 cores
> > =A0 =A0 h) taskset 000f netserver -L 192.168.1.200
> > =A0 =A0 i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.=
168.1.200 -l 30
> >
> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> > ---
> > =A0include/linux/ethtool.h | =A0 =A04 ++++
> > =A0net/core/ethtool.c =A0 =A0 =A0| =A0 39 +++++++++++++++++++++++++=
++++++++++++++
> > =A02 files changed, 43 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > index 6628a50..7523d45 100644
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > @@ -678,6 +678,8 @@ struct ethtool_ops {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct ethtool_rxfh_indir *);
> > =A0 =A0 =A0 =A0 int =A0 =A0 (*set_rxfh_indir)(struct net_device *,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 const struct ethtool_rxfh_indir *);
> > + =A0 =A0 =A0 int =A0 =A0 (*get_loopback)(struct net_device *, u32 =
*);
> > + =A0 =A0 =A0 int =A0 =A0 (*set_loopback)(struct net_device *, u32)=
;
> > =A0};
> > =A0#endif /* __KERNEL__ */
> >
> > @@ -741,6 +743,8 @@ struct ethtool_ops {
> > =A0#define ETHTOOL_GSSET_INFO =A0 =A0 0x00000037 /* Get string set =
info */
> > =A0#define ETHTOOL_GRXFHINDIR =A0 =A0 0x00000038 /* Get RX flow has=
h indir'n table */
> > =A0#define ETHTOOL_SRXFHINDIR =A0 =A0 0x00000039 /* Set RX flow has=
h indir'n table */
> > +#define ETHTOOL_SLOOPBACK =A0 =A0 =A00x0000003a /* Enable / Disabl=
e Loopback */
> [...]
>
> Where should loopback be done, when enabled? =A0As near as possible t=
o the
> host, so it only covers the DMA engines, or as far away as possible, =
so
> it covers most of the MAC/PHY hardware?
>
Putting it very close to the HW would stress the maximum soft path and
would make it
beneficial to more people / developers. I understand that capabilities
offered by different
NIC vendors vary so it's little difficult to draw the line as to where
it  should be done. So
if the theme to "maximize the soft path" is maintained, we can leave
it to the individual
driver(s) to maximize the value in offering.

--mahesh..

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
