From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 23 Apr 2008 16:29:58 -0700
Message-ID: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:57588 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbYDWXaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 19:30:04 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m3NNU0tQ002345
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 00:30:00 +0100
Received: from hs-out-0708.google.com (hsbx43.prod.google.com [10.44.100.43])
	by zps38.corp.google.com with ESMTP id m3NNTwnt024489
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 16:29:59 -0700
Received: by hs-out-0708.google.com with SMTP id x43so1866970hsb.0
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 16:29:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been seeing the same problem here and am trying to fix it.
My fix is to not count those pkts still in the host queue as "prior_in_flight"
when feeding the latter to tcp_cong_avoid(). This should cause
tcp_is_cwnd_limited() test to fail when the previous in_flight build-up
is all due to the large host queue, and stop the cwnd to grow beyond
what's really necessary.

"sysctl_tcp_tso_win_divisor causes cwnd" also unnecessarily inflates
cwnd quite a bit when TSO is enabled.

Jerry

From: David Miller <davem@davemloft.net>

>
>
> Date: Tue, Apr 22, 2008 at 8:59 PM
>
> Subject: Re: Socket buffer sizes with autotuning
> To: johnwheffner@gmail.com
> Cc: rick.jones2@hp.com, netdev@vger.kernel.org
>
>
> From: "John Heffner" <johnwheffner@gmail.com>
> Date: Tue, 22 Apr 2008 19:17:39 -0700
>
>
>
> > On Tue, Apr 22, 2008 at 5:38 PM, Rick Jones <rick.jones2@hp.com> wrote:
> > >  oslowest:~# netstat -an | grep ESTAB
> > >  ...
> > >  tcp    0 2760560 10.208.0.1:40500    10.208.0.45:42049   ESTABLISHED
> > >  ...
> > >
> > >  Is this expected behaviour?
> >
>
> > What is your interface txqueuelen and mtu?  If you have a very large
> > interface queue, TCP will happily fill it up unless you are using a
> > delay-based congestion controller.
>
>
> Yes, that's the fundamental problem with loss based congestion
> control.  If there are any queues in the path, TCP will fill them up.
>
> Vegas and other similar techniques are able to avoid this, but come
> with the fundamental flaw that it's easy to get them into situations
> where they do not respond to increases in pipe space adequately, and
> thus underperform compared to loss based algorithms.
>
>
>
> --
>
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
