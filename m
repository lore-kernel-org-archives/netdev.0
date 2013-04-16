From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Tue, 16 Apr 2013 09:57:45 +0200
Message-ID: <1637650.tuYfvStuVJ@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1366041560.5649.0.camel@dcbw.foobar.com> <CACVXFVOpd6LLjYcz5smx5NktS=+jN74uePSPq7DAeUfpmNYm4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:36974 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933365Ab3DPOSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 10:18:11 -0400
In-Reply-To: <CACVXFVOpd6LLjYcz5smx5NktS=+jN74uePSPq7DAeUfpmNYm4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 April 2013 09:15:45 Ming Lei wrote:
> On Mon, Apr 15, 2013 at 11:59 PM, Dan Williams <dcbw@redhat.com> wrote:
> >
> > So, what was the general consensus on this one?  I know Oliver signed
> > off on it, but the discussion about memflags seemed to die out without a
> > specific conclusion.  davem might be looking for that conclusion before
> > moving forward with the series :)
> 
> Suggest to remove the memflags parameter, because:
> 
> - the probable issue addressed by introducing memflags is a general issue
> of all USB drivers, also very corener one, not a specific one on usbnet, and
> the issue only exists on devices with at least one mass storage interface and
> another non-mass-storage interface, and it is not considered by other USB
> drivers now.

Generally, saying that somebody else has a problem is not an argument
as long as the fix is very simple. Of course it is a corner case, but why
fail to solve it as long as the cost is extremely low?

> - usbnet_status_start() is called from either probe() or work queue scheduled
> from probe(), if we want to address the probable issue, the memflags should

No, we export this symbol. So we keep it generic if that is possible at low cost.
We cannot assume that the conditions it would be called in now, remain so.
Of course we don't add stuff needlessly, but here the fix is trivial.

> always be GFP_NOIO under the two situations, __or__ GFP_KERNEL if we
> choose to ignore the very corner case like other USB drivers.  So hardcoded
> GFP_NOIO or GFP_KERNEL should be accepted.
> 
> Oliver, do you have objections on not adding the memflags parameter now?

Yes, it is a change of almost no gain and a known problem.
It should be added with mem_flags.
 
> Williams, looks there is another problem in your patch, sorry for not
> finding it previously.  usb_autopm_get_interface() need to be called before
> submitting URB inside usbnet_status_start(), and usb_autopm_put_interface()
> need to be called after killing URB inside usbnet_status_stop(). Otherwise
> your patch doesn't work as you expected under runtime PM situation.

Again, no. This is a generic API. It may be called for devices which need
their status polled forever and we cannot block them from sleeping.
If a driver wants to block suspend while a status URB is on, it should
call the autopm method. This is the way we do it while the connection
is up.

	Regards
		Oliver
