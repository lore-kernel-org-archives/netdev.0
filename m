From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH net-next 3/3] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Tue, 22 Aug 2017 11:14:33 +0100
Message-ID: <20170822101433.GC16799@stefanha-x1.localdomain>
References: <KL1P15301MB00086EF58514BFD08F66B6C4BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817145551.GI5539@stefanha-x1.localdomain>
 <KL1P15301MB0008C56CCD01B69186EF3A93BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
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
        "linux
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <KL1P15301MB0008C56CCD01B69186EF3A93BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2017 at 10:23:54PM +0000, Dexuan Cui wrote:
> > From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> > Sent: Thursday, August 17, 2017 07:56
> > To: Dexuan Cui <decui@microsoft.com>
> > On Tue, Aug 15, 2017 at 10:18:41PM +0000, Dexuan Cui wrote:
> > > +static u32 hvs_get_local_cid(void)
> > > +{
> > > +	return VMADDR_CID_ANY;
> > > +}
> > 
> > Interesting concept: the guest never knows its CID.  This is nice from a
> > live migration perspective.  Currently VMCI and virtio adjust listen
> > socket local CIDs after migration.
> > 
> > > +static bool hvs_stream_allow(u32 cid, u32 port)
> > > +{
> > > +	static const u32 valid_cids[] = {
> > > +		VMADDR_CID_ANY,
> > 
> > Is this for loopback?
> 
> No, we don't support lookback in Linux VM, at least for now.
> In our Linux implementation, Linux VM can only connect to the host, and
> here when Linux VM calls connect(), I treat  VMADDR_CID_ANY 
> the same as VMADDR_CID_HOST.

VMCI and virtio-vsock do not treat connect(VMADDR_CID_ANY) the same as
connect(VMADDR_CID_HOST).  It is an error to connect to VMADDR_CID_ANY.

> > > +		VMADDR_CID_HOST,
> > > +	};
> > > +	int i;
> > > +
> > > +	/* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF)
> > is
> > > +	 * reserved as ephemeral ports, which are used as the host's ports
> > > +	 * when the host initiates connections.
> > > +	 */
> > > +	if (port > MAX_HOST_LISTEN_PORT)
> > > +		return false;
> > 
> > Without this if statement the guest will attempt to connect.  I guess
> > there will be no listen sockets above MAX_HOST_LISTEN_PORT, so the
> > connection attempt will fail.
> 
> You're correct.
> To use the vsock common infrastructure, we have to map Hyper-V's
> GUID <VM_ID, Service_ID> to int <cid, port>, and hence we must limit
> the port range we can listen() on to [0, MAX_LISTEN_PORT], i.e.
> we can only use half of the whole 32-bit port space for listen().
> This is detailed in the long comments starting at about Line 100.
>  
> > ...but hardcode this knowledge into the guest driver?
> I'd like the guest's connect() to fail immediately here.
> IMO this is better than a connect timeout. :-)

Thanks for explaining.  Perhaps the comment could be updated:

 /* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF) is
  * reserved as ephemeral ports, which are used as the host's ports when
  * the host initiates connections.
  *
  * Perform this check in the guest so an immediate error is produced
  * instead of a timeout.
  */

Stefan
