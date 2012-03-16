From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Fri, 16 Mar 2012 07:55:38 +0100
Message-ID: <20120316065537.GB2199@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	john.ronciak@intel.com, john.stultz@linaro.org,
	jacob.e.keller@intel.com, tglx@linutronix.de
To: chetan loke <loke.chetan@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2012 at 01:18:26PM -0400, chetan loke wrote:
> 
> 1) how can I use igb->PHC to set/discipline my system time?
>  a) clock_gettime(IGB_CLK_ID...);
>  b) clock_settime(REAL_TIME,...) ? Good/bad idea?

This is a very crude method, and it will cause frequent jumps in your
system clock.

Better would be:

    a = clock_gettime(igb_clk_id);
    clock_settime(CLOCK_REALTIME, a);

    once_every_second()
    {
        a = clock_gettime(igb_clk_id);
        b = clock_gettime(CLOCK_REALTIME);
        offset = a - b;
        freq_adj = pi_servo(offset);
        clock_adjtime(CLOCK_REALTIME, freq_adj);
    }

There is a program, phc2sys, that does something very similar to this
(but using a kernel PPS time stamp instead of clock_gettime) in the
linuxptp code. You could modify that program to do the above fairly
easily. With a heavy enough filter, it might even be acceptable.

    http://linuxptp.sourceforge.net/

Even better would be to use the internal PPS provided by some PHC
hardware to get a better time stamp from the system clock. The IGB
could provide this (I think), but it is not implemented yet.

> 2) what is this deadlock from intel's datasheet
> (http://download.intel.com/design/network/datashts/82576_Datasheet.pdf)
> - goto pg 426
>   2.1) Is this applicable? If not please ignore this question.
>   2.2) Do we need to worry about it. Just asking because a quick
> visual scan didn't pull up - TIMADJL/H.

Do you mean RXSTMPL/H?

Looking at igb_rx_hwtstamp() in igb_main.c, it appears that the 82576
might deliver wrong time stamps with a received packet, if ever a
packet gets time stamped in hardware but does not make it into the Rx
ring buffer.

The 82580 delivers the time stamp with the frame and does not have this
problem.

> 3) Testing IGB PHC (couple of months from now because I'm busy with
> something else):
> 
>    3.1) CardX(It's a different non-intel NIC) and CardY(intel) are in
> hostA. Both cards will use the same time-source Z.
>    3.2) CardX is time-sync'd using PTP.
>    3.3) CardY - is a dual port card. Port 0 will receive PTP packets
> via time-srcZ.
>    3.4) Wait for some time for both the cards to get in-sync.
>    3.5) feed same traffic to Card X and CardY-Port1.
>    3.6) measure time-difference across packets from different NICs on hostA.
> 
>    Is this a good test configuration? Now, ofcourse there will be some
> delta but the intention is to get a feel. See how far off are both the
> adapters.

The best way to do this is to compare a 1 PPS output from each card. I
think the IGB hardware can provide a PPS output, but driver support is
not yet there. Also, the pin providing the signal may or may not be
accessible on your card. Talk to Intel about this.
 
> 4) possible contention on tmreg_lock?
> I will read previous emails/patches shortly but I was thinking - what
> if there are many readers who would like to use PHC as reference time?
> Then do we want them to block the driver who wants to time-stamp the
> packet?
>  igb_gettime->spin_lock::tmreg_lock         <---contention--->  driver
> ->igb_systim_to_hwtstamp->spin_lock::tmreg_lock

Under normal use cases, I would not expect much contention at all.

HTH,

Richard

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
