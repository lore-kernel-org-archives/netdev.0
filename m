From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Move state setting for link query
Date: Wed, 5 Mar 2014 15:06:13 +0000
Message-ID: <ca6e88ec74af496383d25d0c29730d4c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1393890875-1420-1-git-send-email-haiyangz@microsoft.com>
 <531543FD.7090907@redhat.com>
 <856c5dedc14a458b8100dcb2d3a2f9e6@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <5316BCC3.50408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Jason Wang <jasowang@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.90]:7312 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757707AbaCEPGo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 10:06:44 -0500
In-Reply-To: <5316BCC3.50408@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Jason Wang [mailto:jasowang@redhat.com]
> Sent: Wednesday, March 5, 2014 12:57 AM
> To: Haiyang Zhang; davem@davemloft.net; netdev@vger.kernel.org
> Cc: KY Srinivasan; olaf@aepfle.de; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Move state setting for link query
> 
> On 03/05/2014 12:57 AM, Haiyang Zhang wrote:
> >
> >> -----Original Message-----
> >> From: Jason Wang [mailto:jasowang@redhat.com]
> >> Sent: Monday, March 3, 2014 10:10 PM
> >> To: Haiyang Zhang; davem@davemloft.net; netdev@vger.kernel.org
> >> Cc: KY Srinivasan; olaf@aepfle.de; linux-kernel@vger.kernel.org;
> >> driverdev- devel@linuxdriverproject.org
> >> Subject: Re: [PATCH net-next] hyperv: Move state setting for link
> >> query
> >>
> >> On 03/04/2014 07:54 AM, Haiyang Zhang wrote:
> >>> It moves the state setting for query into rndis_filter_receive_response().
> >>> All callbacks including query-complete and status-callback are
> >>> synchronized by channel->inbound_lock. This prevents pentential race
> >> between them.
> >>
> >> This still looks racy to me. The problem is workqueue is not
> >> synchronized with those here.
> >>
> >> Consider the following case in netvsc_link_change():
> >>
> >>     if (rdev->link_state) {
> >>     ... receive interrupt ...
> >>     rndis_filter_receice_response() which changes rdev->link_state
> >>     ...
> >>         netif_carrier_off()
> >>     }
> >>
> >> And also it need to schedule a work otherwise the link status is out of sync.
> > The rndis_filter_query_device_link_status() makes the query and wait
> > for the complete message, including set state, before returning.
> >
> > The rndis_filter_query_device_link_status() is called from
> > rndis_filter_device_add(), which is called from either netvsc_change_mtu()
> or netvsc_probe().
> >
> > The change_mtu() and netvsc_link_change() are synchronized by
> rtnl_lock().
> > In netvsc_probe(), the status query & complete happens before
> > register_netdev(), and the netvsc_linkstatus_callback() schedules the work
> only after netdevice is registered.
> > So, there are no race in either case.
> >
> > The carrier_on/off work will be scheduled when netvsc_open() is
> > called. Then, the status will be updated based on the latest link_state.
> >
> > Thanks,
> > - Haiyang
> >
> 
> I see. Then if the link status is changing during mtu changing in guest.
> Looks like we may miss a link status updating?

When changing mtu, rndis_filter_device_add() is called, and host will send a link
status call back immediately after connect-to-netvsp, no matter the link is changing
or not. This will schedule a work to update the status.

Thanks,
- Haiyang
