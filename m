From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 3/3] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Tue, 22 Aug 2017 21:40:01 +0000
Message-ID: <PS1P15301MB0011D3F00204245172E8150EBF840@PS1P15301MB0011.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00086EF58514BFD08F66B6C4BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817145551.GI5539@stefanha-x1.localdomain>
 <KL1P15301MB0008C56CCD01B69186EF3A93BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822101433.GC16799@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Jorgen Hansen <jhansen@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "joe@perches.com" <joe@perches.com>,
        "lin
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sg2apc01on0093.outbound.protection.outlook.com ([104.47.125.93]:54044
        "EHLO APC01-SG2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752303AbdHVVkS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 17:40:18 -0400
In-Reply-To: <20170822101433.GC16799@stefanha-x1.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> On Fri, Aug 18, 2017 at 10:23:54PM +0000, Dexuan Cui wrote:
> > > > +static bool hvs_stream_allow(u32 cid, u32 port)
> > > > +{
> > > > +	static const u32 valid_cids[] =3D {
> > > > +		VMADDR_CID_ANY,
> > >
> > > Is this for loopback?
> >
> > No, we don't support lookback in Linux VM, at least for now.
> > In our Linux implementation, Linux VM can only connect to the host, and
> > here when Linux VM calls connect(), I treat  VMADDR_CID_ANY
> > the same as VMADDR_CID_HOST.
>=20
> VMCI and virtio-vsock do not treat connect(VMADDR_CID_ANY) the same as
> connect(VMADDR_CID_HOST).  It is an error to connect to VMADDR_CID_ANY.

Ok. Then I'll only allow VMADDR_CID_HOST as the destination CID, since=20
we don't support loopback mode.

> > > > +	/* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF)
> > > is
> > > > +	 * reserved as ephemeral ports, which are used as the host's port=
s
> > > > +	 * when the host initiates connections.
> > > > +	 */
> > > > +	if (port > MAX_HOST_LISTEN_PORT)
> > > > +		return false;
> > >
> > > Without this if statement the guest will attempt to connect.  I guess
> > > there will be no listen sockets above MAX_HOST_LISTEN_PORT, so the
> > > connection attempt will fail.
> >
> > You're correct.
> > To use the vsock common infrastructure, we have to map Hyper-V's
> > GUID <VM_ID, Service_ID> to int <cid, port>, and hence we must limit
> > the port range we can listen() on to [0, MAX_LISTEN_PORT], i.e.
> > we can only use half of the whole 32-bit port space for listen().
> > This is detailed in the long comments starting at about Line 100.
> >
> > > ...but hardcode this knowledge into the guest driver?
> > I'd like the guest's connect() to fail immediately here.
> > IMO this is better than a connect timeout. :-)
>=20
> Thanks for explaining.  Perhaps the comment could be updated:
>=20
>  /* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF) is
>   * reserved as ephemeral ports, which are used as the host's ports when
>   * the host initiates connections.
>   *
>   * Perform this check in the guest so an immediate error is produced
>   * instead of a timeout.
>   */
>=20
> Stefan

Thank you, Stefan!=20
Please see the below for the updated version of the function:

static bool hvs_stream_allow(u32 cid, u32 port)
{
        /* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF) is
         * reserved as ephemeral ports, which are used as the host's ports
         * when the host initiates connections.
         *
         * Perform this check in the guest so an immediate error is produce=
d
         * instead of a timeout.
         */
        if (port > MAX_HOST_LISTEN_PORT)
                return false;

        if (cid =3D=3D VMADDR_CID_HOST)
                return true;

        return false;
}

I'll send a v2 of the patch later today.

-- Dexuan
