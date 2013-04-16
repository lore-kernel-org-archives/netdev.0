From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Tue, 16 Apr 2013 09:15:45 +0800
Message-ID: <CACVXFVOpd6LLjYcz5smx5NktS=+jN74uePSPq7DAeUfpmNYm4w@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<21345916.cd7DzC6Ttz@linux-5eaq.site>
	<1365606080.28888.72.camel@dcbw.foobar.com>
	<7761183.G42DetJs5Z@linux-5eaq.site>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<1366041560.5649.0.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f179.google.com ([209.85.128.179]:54954 "EHLO
	mail-ve0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934863Ab3DPBPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 21:15:47 -0400
In-Reply-To: <1366041560.5649.0.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 11:59 PM, Dan Williams <dcbw@redhat.com> wrote:
>
> So, what was the general consensus on this one?  I know Oliver signed
> off on it, but the discussion about memflags seemed to die out without a
> specific conclusion.  davem might be looking for that conclusion before
> moving forward with the series :)

Suggest to remove the memflags parameter, because:

- the probable issue addressed by introducing memflags is a general issue
of all USB drivers, also very corener one, not a specific one on usbnet, and
the issue only exists on devices with at least one mass storage interface and
another non-mass-storage interface, and it is not considered by other USB
drivers now.

- usbnet_status_start() is called from either probe() or work queue scheduled
from probe(), if we want to address the probable issue, the memflags should
always be GFP_NOIO under the two situations, __or__ GFP_KERNEL if we
choose to ignore the very corner case like other USB drivers.  So hardcoded
GFP_NOIO or GFP_KERNEL should be accepted.

Oliver, do you have objections on not adding the memflags parameter now?

Williams, looks there is another problem in your patch, sorry for not
finding it previously.  usb_autopm_get_interface() need to be called before
submitting URB inside usbnet_status_start(), and usb_autopm_put_interface()
need to be called after killing URB inside usbnet_status_stop(). Otherwise
your patch doesn't work as you expected under runtime PM situation.


Thanks,
-- 
Ming Lei
