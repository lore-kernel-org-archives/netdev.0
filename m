From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Fri, 23 Mar 2012 06:59:29 +0100
Message-ID: <20120323055927.GA2311@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321170003.GA5533@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
 <20120322064107.GB2182@netboy.at.omicron.at>
 <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50248 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab2CWF7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 01:59:42 -0400
Received: by wibhq7 with SMTP id hq7so1622501wib.1
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 22:59:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 07:13:42PM -0400, chetan loke wrote:

> /* users can keep re-trying - dont really care */

[Sigh] No, they do in fact care...

> igb_gettime_locking (...) {
>      unsigned int seq;
>      u64 ns;
>      do {
>      seq = read_seqbegin( &pigb->tmreg_seq_lock);
>      ns = timecounter_read(&pigb->tc);

And what happens here?

timecounter_read()
 timecounter_read_delta()
  tc->cc->read() == igb_825xx_systim_read()

   lo = rd32(E1000_SYSTIML); /* this read latches the time value */
   hi = rd32(E1000_SYSTIMH); /* and here is your race */

If two readers enter this code at nearly the same time, then they can
corrupt each other's hi/lo values.

>      } while (read_seqretry(&pigb->tmreg_seq_lock, seq));
>      // process ns
> }
> 
> 
> copyright 2012 - Chetan Loke <lokechetan@gmail.com>
> 
> // trip cnt will ensure/enforce - evil adjtime user-space code can
> still not block us.
> // called from igb_tx[rx]_hwtstamp
> driver_rx_tx_path_locking( ... ) {
>      unsigned int seq, trip_cnt = 0;
>      u64 ns;
>      do {
>      seq = read_seqbegin( &pigb->tmreg_seq_lock);
>      trip_cnt++;
>      ns = timecounter_read(&pigb->tc);

Same here.

Thanks,
Richard
