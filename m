From: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 4/8] NFC: NCI: Add a special nci_request for driver
Date: Thu, 26 Mar 2015 01:29:46 +0100
Message-ID: <20150326002946.GC10954@ribalta.home>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-5-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1424772112-27399-5-git-send-email-robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Robert,

On Tue, Feb 24, 2015 at 12:01:48PM +0200, Robert Dolca wrote:
> This patch adds nci_request_driver and nci_req_complete_driver
> as a wrapper for __nci_request. When nci_req_complete_driver is
> called it also sets cmd_cnt to 1. This is done because the response is not
> sent to the NFC subsystem so cmd_cnt is not decremented there.
> 
> nci_send_cmd was previously exported in order to send commands to
> the device from the driver. It shouldn't be used without
> nci_req_complete_driver because cmd_cnt will have the wrong value.
Any NCI packet should make it to the NCI core first, because the logic
and synchornization between Tx and Rx, commands and response is implemented
there. When exporting this kind of symbols, you're opening a can of worms by
potentially allowing each driver to implement the same kind of logic
that's already implemented in the NCI core.

The solution I'd like to see implemented is the following one: Add 1
additional nci_ops entry for handling proprietary packets on the Rx
path. From your driver perspective, you call nci_recv_frame for each and
every packet that you receive: No intercept, no trap. The core will call
your proprietary packets handler for each packet (NTF or RSP) with a
proprietary GID.
You should then be able to remove all the rx work, rx queue and
intercept logic from your driver.

Cheers,
Samuel.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
