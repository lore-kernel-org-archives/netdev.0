From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 16:52:43 +0200
Message-ID: <1217343163.30512.34.camel@ecld0pohly>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com>
	 <1217290080-4251-2-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38654 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbYG2Oyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 10:54:31 -0400
In-Reply-To: <1217290080-4251-2-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-29 at 03:08 +0300, Octavian Purdila wrote:
> New socket option and socket control message are added as well
> (SO_TIMESTAMPHW and SCM_TIMESTAMPHW).

How is a network driver notified that it is expected to do hardware time
stamping? The connection between the socket option and the driver isn't
quite clear to me (which might very well be due to my lack of experience
in this area - please bear with me...). Is the driver expected to check
the socket flags whenever it gets a chance?

IMHO it would be necessary to attach this configuration change not just
to a socket, but also to a message which is then routed to the right
device driver.

A simple on/off flag is not sufficient, either: for example, the Intel
82576 chip only has one RX register that is locked until read by the
driver. When time stamping all incoming packets, relevant time stamps
may get lost under high load. The hardware can be configured to only
time stamp packets of interest, which helps considerably. Here are some
generally useful modes:
      * PTP v1/2 Sync via UDP
      * PTP v1/2 DelayRequest via UDP
      * PTP v2 Sync via L2 (802.AS)
      * PTP v2 DelayRequest via L2 (802.AS)
      * all packets

The docs can be found here, in case anyone is interested:
http://sourceforge.net/project/showfiles.php?group_id=42302

It would be nice if the user space PTP could choose which packets are
time stamped (depending whether it is master or slave it needs either
Sync or DelayRequest, and it may use UDP or Ethernet). It may also be
important to know for the application whether the hardware is really
capable of delivering what it is asked for.

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 299ec4b..f19ed43 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -199,7 +199,8 @@ typedef unsigned char *sk_buff_data_t;
>   *	@next: Next buffer in list
>   *	@prev: Previous buffer in list
>   *	@sk: Socket we are owned by
> - *	@tstamp: Time we arrived
> + *	@tstamp: Time we arrived; representation might be hardware specific, do
> + *	        not access directly but via skb_get_tstamp

Given that the semantic of the "tstamp" member has changed and any
existing code which still accesses it directly is broken, should the
member perhaps be renamed to trigger compiler errors in such a case?
Just a thought.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

The email footer below is automatically added to comply with company
policy; this particular email is not confidental and does not have a
limited set of recipients. Therefore it can be redistributed and
discussed without restrictions.

