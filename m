From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gre: conform to RFC6040 ECN progogation
Date: Tue, 25 Sep 2012 07:17:07 +0200
Message-ID: <1348550227.26828.1910.camel@edumazet-glaptop>
References: <20120924184304.727711327@vyatta.com>
	 <20120924185050.162920909@vyatta.com>
	 <20120924205822.GI26494@x200.localdomain>
	 <20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
	 <20120924212226.GJ26494@x200.localdomain>
	 <20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
	 <1348525536.26828.1885.camel@edumazet-glaptop>
	 <20120924153013.553f0b76@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37618 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab2IYFRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 01:17:12 -0400
Received: by wibhr7 with SMTP id hr7so59457wib.1
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 22:17:11 -0700 (PDT)
In-Reply-To: <20120924153013.553f0b76@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 15:30 -0700, Stephen Hemminger wrote:

> Logging is a bad idea in this case since the tunnel might be from a remote
> host/protocol and the log would be filled with crap.
> 
> The tunnels in general do need to have rx_dropped counter, but it looks
> like that isn't being done right either.
> 

I never suggested to log _all_ messages.


Stephen, I personally was hit by some provider playing with TOS bits so
wrong I had to patch linux to fix a minor problem. [1]

I would like to know why my tunnels are going to fail, and what should I
do to get a fallback. Ie reverting your patches.


RFC 6040 states :

      In these cases,
      particularly the more dangerous ones, the decapsulator SHOULD log
      the event and MAY also raise an alarm.

      Just because the highlighted combinations are currently unused,
      does not mean that all the other combinations are always valid.
      Some are only valid if they have arrived from a particular type of
      legacy ingress, and dangerous otherwise.  Therefore, an
      implementation MAY allow an operator to configure logging and
      alarms for such additional header combinations known to be
      dangerous or CU for the particular configuration of tunnel
      endpoints deployed at run-time.

      Alarms SHOULD be rate-limited so that the anomalous combinations
      will not amplify into a flood of alarm messages.  It MUST be
      possible to suppress alarms or logging, e.g., if it becomes
      apparent that a combination that previously was not used has
      started to be used for legitimate purposes such as a new standards
      action.


[1]
commit 7a269ffad72f3604b8982fa09c387670e0d2ee14
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Sep 22 20:02:19 2011 +0000

    tcp: ECN blackhole should not force quickack mode
    
    While playing with a new ADSL box at home, I discovered that ECN
    blackhole can trigger suboptimal quickack mode on linux : We send one
    ACK for each incoming data frame, without any delay and eventual
    piggyback.
    
    This is because TCP_ECN_check_ce() considers that if no ECT is seen on a
    segment, this is because this segment was a retransmit.
    
    Refine this heuristic and apply it only if we seen ECT in a previous
    segment, to detect ECN blackhole at IP level.
