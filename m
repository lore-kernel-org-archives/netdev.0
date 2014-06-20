From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Fri, 20 Jun 2014 15:48:56 +0000
Message-ID: <5174e5cab2b84decaa903dcf3215bce9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620084158.GR5500@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140620084158.GR5500@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Friday, June 20, 2014 4:42 AM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; olaf@aepfle.de;
> jasowang@redhat.com; driverdev-devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net-next] hyperv: Add handler for
> RNDIS_STATUS_NETWORK_CHANGE event
> 
> On Thu, Jun 19, 2014 at 06:34:36PM -0700, Haiyang Zhang wrote:
> > @@ -589,7 +590,19 @@ void netvsc_linkstatus_callback(struct hv_device
> *device_obj,
> >  	net_device = hv_get_drvdata(device_obj);
> >  	rdev = net_device->extension;
> >
> > -	rdev->link_state = status != 1;
> > +	switch (indicate->status) {
> > +	case RNDIS_STATUS_MEDIA_CONNECT:
> > +		rdev->link_state = false;
> 
> link_state false means that we want to connect?
Yes

> 
> > +		break;
> > +	case RNDIS_STATUS_MEDIA_DISCONNECT:
> > +		rdev->link_state = true;
> 
> link_state true means that we are disconnecting.
Yes.

> > @@ -782,10 +797,17 @@ static void netvsc_link_change(struct
> work_struct *w)
> >  	} else {
> >  		netif_carrier_on(net);
> >  		notify = true;
> > +		if (rdev->link_change) {
> > +			rdev->link_change = false;
> > +			refresh = true;
> > +		}
> 
> How do we know that we received a RNDIS_STATUS_MEDIA_CONNECT before we
> received the RNDIS_STATUS_NETWORK_CHANGE?  In other words, why does
> RNDIS_STATUS_NETWORK_CHANGE imply that the link_state is false?

After host sleep, both RNDIS_STATUS_MEDIA_CONNECT and 
RNDIS_STATUS_NETWORK_CHANGE events are received, but not necessarily in
this order. If RNDIS_STATUS_MEDIA_CONNECT arrives later, the flag saved
in rdev->link_change previously will trigger the refresh, not in the
RNDIS_STATUS_NETWORK_CHANGE event, but in the latter RNDIS_STATUS_MEDIA_CONNECT
event.

> 
> >  	}
> >
> >  	rtnl_unlock();
> >
> > +	if (refresh)
> > +		call_usermodehelper(argv[0], argv, envp, UMH_WAIT_EXEC);
> 
> You may as well use UMH_NO_WAIT since there is no error handling if
> /etc/init.d/network is not found.

I previously tried UMH_NO_WAIT, but not working. We need to wait for the 
exec (not process completion) in this case. Since it's in the work queue,
a bit of waiting is OK.

Thanks,
- Haiyang
