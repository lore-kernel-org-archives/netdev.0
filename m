From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Thu, 22 Mar 2012 19:13:42 -0400
Message-ID: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
	<CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321170003.GA5533@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
	<20120322064107.GB2182@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:40813 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031376Ab2CVXNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:13:43 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so2291199yhm.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 16:13:42 -0700 (PDT)
In-Reply-To: <20120322064107.GB2182@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 2:41 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Wed, Mar 21, 2012 at 05:50:34PM -0400, chetan loke wrote:
>>
>> Richard - Intent is to make the readers(get_time) wait (or return last
>> read value if the seq_counter tripped because you know that this value
>> was recent) and let the tx/rx path continue. I haven't looked in more
>> details but as Jake mentioned you will also need to change the way you
>> read the values(by not using timecounter_read in get_time).
>
> I don't get what you guys are saying. How can you avoid the spin lock
> around the two time register reads? How about a patch or some pseudo
> code?
>

tmreg_lock now becomes seqlock_t instead of spinlock_t.

/* users can keep re-trying - dont really care */
igb_gettime_locking (...) {
     unsigned int seq;
     u64 ns;
     do {
     seq = read_seqbegin( &pigb->tmreg_seq_lock);
     ns = timecounter_read(&pigb->tc);
     } while (read_seqretry(&pigb->tmreg_seq_lock, seq));
     // process ns
}


copyright 2012 - Chetan Loke <lokechetan@gmail.com>

// trip cnt will ensure/enforce - evil adjtime user-space code can
still not block us.
// called from igb_tx[rx]_hwtstamp
driver_rx_tx_path_locking( ... ) {
     unsigned int seq, trip_cnt = 0;
     u64 ns;
     do {
     seq = read_seqbegin( &pigb->tmreg_seq_lock);
     trip_cnt++;
     ns = timecounter_read(&pigb->tc);
     } while (read_seqretry(&pigb->tmreg_seq_lock, seq) && trip_cnt < 2));
     // process ns
}


igb_adjtime () {
    /* just let first user of adjtime or settime succeed? */
    if (write_try_seqlock(&pigb->tmreg_seq_lock)) {
         // update NIC counter - here ...
         write_sequnlock(&pigb->tmreg_seq_lock);
    }
}

igb_settime () {
    // let all of them do their thing ... or you can use trylock here
too if you like...
    write_seqlock(&pigb->tmreg_seq_lock);
         // update NIC counter - here ...
    write_sequnlock(&pigb->tmreg_seq_lock);
 }

write_seq_xxx will spinlock as usual but read_seq reads the atomically
incremented counter. Also notice the use of trip_cnt to further ensure
the driver never keeps re-trying.

The regular __irqsave flavors are also available for use for the
write_seq calls.

> Thanks,
> Richard

Chetan
