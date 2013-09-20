From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next 1/2] xen-netback: add a vif-is-connected flag
Date: Fri, 20 Sep 2013 15:02:22 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD010F2BA@AMSPEX01CL01.citrite.net>
References: <1379681791-21842-1-git-send-email-paul.durrant@citrix.com>
 <1379681791-21842-2-git-send-email-paul.durrant@citrix.com>
 <20130920133106.GB457@zion.uk.xensource.com> <523C5BA7.2010500@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26965 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab3ITPC0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 11:02:26 -0400
In-Reply-To: <523C5BA7.2010500@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Vrabel
> Sent: 20 September 2013 15:29
> To: Wei Liu
> Cc: Paul Durrant; netdev@vger.kernel.org; xen-devel@lists.xen.org; Ian
> Campbell
> Subject: Re: [PATCH net-next 1/2] xen-netback: add a vif-is-connected flag
> 
> On 20/09/13 14:31, Wei Liu wrote:
> > On Fri, Sep 20, 2013 at 01:56:30PM +0100, Paul Durrant wrote:
> >> Having applied my patch to separate vif disconnect and free, I ran into a
> >> BUG when testing resume from S3 with a Windows frontend because the
> vif task
> >> pointer was not cleared by xenvif_disconnect() and so a double call to this
> >> function tries to stop the thread twice.
> >> Rather than applying a point fix for that issue it seems better to introduce
> >> a boolean to indicate whether the vif is connected or not such that
> repeated
> >> calls to either xenvif_connect() or xenvif_disconnect() behave
> appropriately.
> 
> We already have a backend state of CONNECTED/CLOSED/etc. why do we
> need
> an additional bit of state outside of this?
> 

It's not really additional state; we were essentially inferring connected-ness from the value of tx_irq. This patch really just removes that inference and created something with the intended meaning.

> Does something like this in frontend_changed() fix it?
> 

It may well do, but it's a far more invasive change and would require more testing. It certainly sounds like a good thing to do in the longer term.

  Paul

> 	case XenbusStateClosing:
>                 switch (dev->state) {
>                 case XenbusStateClosed;
>                 	break;
> 		case XenbusStateConnected:
> 			disconnect_backend(dev);
> 			/* fall through */
> 		default:
> 			xenbus_switch_state(dev, XenbusStateClosing);
> 			break;
> 		}
> 		break;
> 
> 	case XenbusStateClosed:
>                 switch (dev->state) {
>                 case XenbusStateConnected;
> 			disconnect_backend(dev);
>                 	/* fall through */
> 		default:
> 			xenbus_switch_state(dev, XenbusStateClosed);
> 			break;
> 		}
> 		if (xenbus_dev_is_online(dev))
> 			break;
> 		/* fall through if not online */
> 
> Can you also remove destroy_backend()?  It's not needed any more.
> 
> I'd also recommend waiting a bit for other review feedback before
> posting an updated series.
> 
> David
