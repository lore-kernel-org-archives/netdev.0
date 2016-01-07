From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Question regarding {G,S}CHANNELS API
Date: Thu, 7 Jan 2016 15:43:24 +0000
Message-ID: <20160107154324.4081743c@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36527 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbcAGPna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 10:43:30 -0500
Received: by mail-wm0-f50.google.com with SMTP id l65so102028755wmf.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 07:43:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm trying to understand how number of "separate" rx/tx vs combined
channels should be configured.  I'd like to express asymmetric but
mostly combined queue configuration (i.e. min(rx, tx) is combined the
rest is separate).  Since default number of RX queues is just 8 it is
tempting to allocate 8 RX queues but num_online_cpus() TX queues.  Does
this configuration make sense?  What should ethtool -l report?

I had a look through the drivers and it seems that most of them fall
nicely into the all combined and all separate categories. Two
exceptions I found are bnxt_en (recent Michael's changes) and tg3.
bnxt_en can switch between combined and separate mode.  tg3 is more
interesting, it uses separate rx/tx parameters but combines first
min(rx, tx) of the queues as I would like to.

The problem is if I hijack the "separate" rx/tx queues parameters like
tg3 does there is no way for the user to express that (s)he truly wants
them separate.  Also it seems that tg3 goes against the ethtool manual
which states:
>  rx N   Changes the number of channels with only receive queues.
>  tx N   Changes the number of channels with only transmit queues.
Which indicates that if user wants 8 rx, 12 tx and combining (s)he
should do:
  ethtool -L ethX combined 8 tx 4

This, however, makes the max_* info from SCHANNLES quite imprecise
since device which has 16 IRQs and 16 queues in each directions would
probably report:
max_rx:       16
max_tx:       16
max_combined: 16
But setting 'ethtool -L ethX combined 16 tx 8' would obviously
fail even though parameters are within 1..max limits.

Any comments/advice would be much appreciated.
