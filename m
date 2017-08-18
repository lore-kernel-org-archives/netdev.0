From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 3/3] hv_sock: implements Hyper-V transport for
 Virtual Sockets (AF_VSOCK)
Date: Fri, 18 Aug 2017 22:23:54 +0000
Message-ID: <KL1P15301MB0008C56CCD01B69186EF3A93BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00086EF58514BFD08F66B6C4BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817145551.GI5539@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, "joe@perches.com" <joe@perches.com>,
 "olaf@aepfle.de" <olaf@aepfle.de>, Stephen Hemminger <sthemmin@microsoft.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Haiyang
 Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>, Jorgen Hansen <jhansen@vmware.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Marcelo Cerri <marcelo.cerri@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 George Zhang <georgezhang@vmware.com>,
 Dan Carpenter <dan.carpenter@oracle.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170817145551.GI5539@stefanha-x1.localdomain>
Content-Language: en-US
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

> From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> Sent: Thursday, August 17, 2017 07:56
> To: Dexuan Cui <decui@microsoft.com>
> On Tue, Aug 15, 2017 at 10:18:41PM +0000, Dexuan Cui wrote:
> > +static u32 hvs_get_local_cid(void)
> > +{
> > +	return VMADDR_CID_ANY;
> > +}
> 
> Interesting concept: the guest never knows its CID.  This is nice from a
> live migration perspective.  Currently VMCI and virtio adjust listen
> socket local CIDs after migration.
> 
> > +static bool hvs_stream_allow(u32 cid, u32 port)
> > +{
> > +	static const u32 valid_cids[] = {
> > +		VMADDR_CID_ANY,
> 
> Is this for loopback?

No, we don't support lookback in Linux VM, at least for now.
In our Linux implementation, Linux VM can only connect to the host, and
here when Linux VM calls connect(), I treat  VMADDR_CID_ANY 
the same as VMADDR_CID_HOST.

> > +		VMADDR_CID_HOST,
> > +	};
> > +	int i;
> > +
> > +	/* The host's port range [MIN_HOST_EPHEMERAL_PORT, 0xFFFFFFFF)
> is
> > +	 * reserved as ephemeral ports, which are used as the host's ports
> > +	 * when the host initiates connections.
> > +	 */
> > +	if (port > MAX_HOST_LISTEN_PORT)
> > +		return false;
> 
> Without this if statement the guest will attempt to connect.  I guess
> there will be no listen sockets above MAX_HOST_LISTEN_PORT, so the
> connection attempt will fail.

You're correct.
To use the vsock common infrastructure, we have to map Hyper-V's
GUID <VM_ID, Service_ID> to int <cid, port>, and hence we must limit
the port range we can listen() on to [0, MAX_LISTEN_PORT], i.e.
we can only use half of the whole 32-bit port space for listen().
This is detailed in the long comments starting at about Line 100.
 
> ...but hardcode this knowledge into the guest driver?
I'd like the guest's connect() to fail immediately here.
IMO this is better than a connect timeout. :-)

Thanks,
-- Dexuan
