From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 19:30:19 +0200
Message-ID: <200807291930.20033.netdev@axxeo.de>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <20080729085457.033a9fd2@extreme> <200807291911.10364.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:51349 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186AbYG2Rah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 13:30:37 -0400
In-Reply-To: <200807291911.10364.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian,

Octavian Purdila schrieb:
> On Tuesday 29 July 2008, Stephen Hemminger wrote:
> >
> > In my sky2 sample code, I took a different approach:
> >  1. Why have HW timestamps different than existing timestamps? If you
> >     just use existing timestamp, no socket API is needed.
> 
> I agree that is a much better approach if you are ok with the variance 
> introduced by synchronizing the HW timestamps with the CPU clock.

Just convert your hardware specific cookie you have into the nanoseconds
resolution timstamp in skb->tstamp just before calling netif_rx() 
or net_receive_skb().  

These functions will not touch it, as long as they never see a ZERO 
value there. A ZERO value in tstamp.tv64 means, we have no timestamp.

The difference to CPU clock doesn't matter. 
That compensation can be done by your driver or application at will.
For mainline, compensation in driver might be preferred.

As long as it is montonic increasing and related to time in any way, 
you could put anything there, I think :-)

The timestamp in nanoseconds will be submitted as CMSG().
see net/socket.c "put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS, sizeof(ts), &ts);"

Enable it with this code fragment in user space:

	int one = 1;
	setsockopt(mysok, SOL_SOCKET, SO_TIMESTAMPNS, &one);

In the kernel the call chain is: raw_recvmsg() -> sock_recv_timestamp() -> __sock_recv_timestamp()
__sock_recv_timestamp() is:
void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
    struct sk_buff *skb)
{
    ktime_t kt = skb->tstamp;

    if (!sock_flag(sk, SOCK_RCVTSTAMPNS)) {
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Check for nanosecond timestamps
        struct timeval tv;
        /* Race occurred between timestamp enabling and packet
           receiving.  Fill in the current time for now. */
        if (kt.tv64 == 0)
            kt = ktime_get_real();
        skb->tstamp = kt;
        tv = ktime_to_timeval(kt);
        put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP, sizeof(tv), &tv);
    } else {
        struct timespec ts;
        /* Race occurred between timestamp enabling and packet
           receiving.  Fill in the current time for now. */
        if (kt.tv64 == 0)
            kt = ktime_get_real();
        skb->tstamp = kt;
        ts = ktime_to_timespec(kt);
        put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS, sizeof(ts), &ts);
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Put nanosecond timestamps into CMSG()
    }
}

> But if you want to precisely measure one-way delays, and if you have the hw 
> timestamp units synchronized across the nodes, then you need the hardware 
> timesetamp. 

Yes, no argument against that. Just your new user space ABI is simply not 
required for RX timestamps. It works out of the box already.



Best Regards

Ingo Oeser
