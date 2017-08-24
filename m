From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH net-next 3/3] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Thu, 24 Aug 2017 16:53:45 +0100
Message-ID: <20170824155345.GA2512@stefanha-x1.localdomain>
References: <KL1P15301MB00086EF58514BFD08F66B6C4BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817145551.GI5539@stefanha-x1.localdomain>
 <KL1P15301MB0008C56CCD01B69186EF3A93BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822101433.GC16799@stefanha-x1.localdomain>
 <PS1P15301MB0011D3F00204245172E8150EBF840@PS1P15301MB0011.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, "joe@perches.com" <joe@perches.com>,
 "olaf@aepfle.de" <olaf@aepfle.de>, Stephen Hemminger <sthemmin@microsoft.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>, Jorgen Hansen <jhansen@vmware.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Marcelo Cerri <marcelo.cerri@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 George Zhang <georgezhang@vmware.com>,
 Dan Carpenter <dan.carpenter@oracle.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <PS1P15301MB0011D3F00204245172E8150EBF840@PS1P15301MB0011.APCP153.PROD.OUTLOOK.COM>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 09:40:01PM +0000, Dexuan Cui wrote:
> > From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> > On Fri, Aug 18, 2017 at 10:23:54PM +0000, Dexuan Cui wrote:
> > > > > +static bool hvs_stream_allow(u32 cid, u32 port)
> > > > > +{
> > > > > +	static const u32 valid_cids[] = {
> > > > > +		VMADDR_CID_ANY,
> > > >
> > > > Is this for loopback?
> > >
> > > No, we don't support lookback in Linux VM, at least for now.
> > > In our Linux implementation, Linux VM can only connect to the host, and
> > > here when Linux VM calls connect(), I treat  VMADDR_CID_ANY
> > > the same as VMADDR_CID_HOST.
> > 
> > VMCI and virtio-vsock do not treat connect(VMADDR_CID_ANY) the same as
> > connect(VMADDR_CID_HOST).  It is an error to connect to VMADDR_CID_ANY.
> 
> Ok. Then I'll only allow VMADDR_CID_HOST as the destination CID, since 
> we don't support loopback mode.
> 
> > > > > +	/* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF)
> > > > is
> > > > > +	 * reserved as ephemeral ports, which are used as the host's ports
> > > > > +	 * when the host initiates connections.
> > > > > +	 */
> > > > > +	if (port > MAX_HOST_LISTEN_PORT)
> > > > > +		return false;
> > > >
> > > > Without this if statement the guest will attempt to connect.  I guess
> > > > there will be no listen sockets above MAX_HOST_LISTEN_PORT, so the
> > > > connection attempt will fail.
> > >
> > > You're correct.
> > > To use the vsock common infrastructure, we have to map Hyper-V's
> > > GUID <VM_ID, Service_ID> to int <cid, port>, and hence we must limit
> > > the port range we can listen() on to [0, MAX_LISTEN_PORT], i.e.
> > > we can only use half of the whole 32-bit port space for listen().
> > > This is detailed in the long comments starting at about Line 100.
> > >
> > > > ...but hardcode this knowledge into the guest driver?
> > > I'd like the guest's connect() to fail immediately here.
> > > IMO this is better than a connect timeout. :-)
> > 
> > Thanks for explaining.  Perhaps the comment could be updated:
> > 
> >  /* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF) is
> >   * reserved as ephemeral ports, which are used as the host's ports when
> >   * the host initiates connections.
> >   *
> >   * Perform this check in the guest so an immediate error is produced
> >   * instead of a timeout.
> >   */
> > 
> > Stefan
> 
> Thank you, Stefan! 
> Please see the below for the updated version of the function:
> 
> static bool hvs_stream_allow(u32 cid, u32 port)
> {
>         /* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF) is
>          * reserved as ephemeral ports, which are used as the host's ports
>          * when the host initiates connections.
>          *
>          * Perform this check in the guest so an immediate error is produced
>          * instead of a timeout.
>          */
>         if (port > MAX_HOST_LISTEN_PORT)
>                 return false;
> 
>         if (cid == VMADDR_CID_HOST)
>                 return true;
> 
>         return false;
> }
> 
> I'll send a v2 of the patch later today.

Great, thanks!
