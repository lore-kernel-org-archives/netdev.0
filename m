From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero
 window is advertised
Date: Tue, 16 Sep 2014 12:31:42 -0400
Message-ID: <CADVnQy=QM8sE93Rn+MyyHdgzW6xqioCsKSQ6xdMTbX5E7iM4WQ@mail.gmail.com>
References: <54170FC0.6020907@oktetlabs.ru>
	<1410822949.5018.4.camel@localhost>
	<54183150.5030400@oktetlabs.ru>
	<1410872966.7106.187.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAK6E8=eNtNwREF8J+eF1LWhmg-aZmkYycDkXEAKn7Xb0_xv2rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:40252 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090AbaIPQbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:31:43 -0400
Received: by mail-qc0-f179.google.com with SMTP id i17so155955qcy.10
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:31:42 -0700 (PDT)
In-Reply-To: <CAK6E8=eNtNwREF8J+eF1LWhmg-aZmkYycDkXEAKn7Xb0_xv2rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 11:11 AM, Yuchung Cheng <ycheng@google.com> wrote:
> On Tue, Sep 16, 2014 at 6:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Normally SO_LINGER could be used, or TCP_USER_TIMEOUT. This requires a
>> system call before doing the close().
>>
>> 1) TCP_USER_TIMEOUT would be the fit for this, but its current
>> implementation do not take care of the probes sent, even in FIN_WAIT
>> state when in this zero window mode. A patch would be needed.
> Yes that's what I meant. I am proposing we should patch
> TCP_USER_TIMEOUT to do this.

We should probably be careful here. It would be a non-trivial change
in semantics to have TCP_USER_TIMEOUT solve this issue.

TCP_USER_TIMEOUT, in both the man page, the RFC, and the existing
code, is about a user-specific limit on the maximum amount of time the
TCP stack will attempt to transmit a single packet. (For example, the
man page: "specifies the maximum amount of time in milliseconds that
transmitted data may remain unacknowledged before TCP will forcibly
close the corresponding connection"). Any existing apps that are
setting TCP_USER_TIMEOUT are probably setting it to something in the
range of seconds to a few minutes, and may reasonably expect their
orphaned connections to last minutes to hours, as long as they are
making progress (each of the packets is ACKed in the
seconds-to-minutes range).

By contrast, AFAICT what we are talking about here for these
ZWP-forever/tarpit scenarios is to be able to cap the maximum overall
lifetime of an orphan connection. That's a different parameter, and
folks might want to set it in the minutes-to-hours range.

neal
