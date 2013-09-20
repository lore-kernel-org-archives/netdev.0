From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net-next 1/2] xen-netback: add a vif-is-connected flag
Date: Fri, 20 Sep 2013 15:28:55 +0100
Message-ID: <523C5BA7.2010500@citrix.com>
References: <1379681791-21842-1-git-send-email-paul.durrant@citrix.com> <1379681791-21842-2-git-send-email-paul.durrant@citrix.com> <20130920133106.GB457@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:33080 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3ITO25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 10:28:57 -0400
In-Reply-To: <20130920133106.GB457@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/09/13 14:31, Wei Liu wrote:
> On Fri, Sep 20, 2013 at 01:56:30PM +0100, Paul Durrant wrote:
>> Having applied my patch to separate vif disconnect and free, I ran into a
>> BUG when testing resume from S3 with a Windows frontend because the vif task
>> pointer was not cleared by xenvif_disconnect() and so a double call to this
>> function tries to stop the thread twice.
>> Rather than applying a point fix for that issue it seems better to introduce
>> a boolean to indicate whether the vif is connected or not such that repeated
>> calls to either xenvif_connect() or xenvif_disconnect() behave appropriately.

We already have a backend state of CONNECTED/CLOSED/etc. why do we need
an additional bit of state outside of this?

Does something like this in frontend_changed() fix it?

	case XenbusStateClosing:
                switch (dev->state) {
                case XenbusStateClosed;
                	break;
		case XenbusStateConnected:
			disconnect_backend(dev);
			/* fall through */
		default:
			xenbus_switch_state(dev, XenbusStateClosing);
			break;
		}
		break;

	case XenbusStateClosed:
                switch (dev->state) {
                case XenbusStateConnected;
			disconnect_backend(dev);
                	/* fall through */
		default:
			xenbus_switch_state(dev, XenbusStateClosed);
			break;
		}
		if (xenbus_dev_is_online(dev))
			break;
		/* fall through if not online */

Can you also remove destroy_backend()?  It's not needed any more.

I'd also recommend waiting a bit for other review feedback before
posting an updated series.

David
