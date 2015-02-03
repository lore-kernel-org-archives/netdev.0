From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Per-connection tcp_retries2 and RFC 1122 compliance
Date: Tue, 3 Feb 2015 09:50:57 -0500
Message-ID: <CADVnQymEvyJaM8ogia5kmARrrFF0dSk83iSUyPPTHOaCO+GrfQ@mail.gmail.com>
References: <87a90w10tq.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: John Eckersberg <jeckersb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:58130 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965506AbbBCOu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 09:50:58 -0500
Received: by mail-qa0-f52.google.com with SMTP id x12so34010249qac.11
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 06:50:57 -0800 (PST)
In-Reply-To: <87a90w10tq.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 2, 2015 at 4:05 PM, John Eckersberg <jeckersb@redhat.com> wrote:
> Greetings,
>
> RFC 1122, section 4.2.3.5 "TCP Connection Failures", states:
>
>   (d)  An application MUST be able to set the value for R2 for
>        a particular connection.  For example, an interactive
>        application might set R2 to "infinity," giving the user
>        control over when to disconnect.
>
> The R2 value referenced above is implemented as the tcp_retries2 sysctl.
> However it seems that the only way to tune that value is via the global
> sysctl knob.  In other words, there is no provided way to set it only
> for a particular connection as RFC 1122 requires.
>
> Could someone confirm that this is a legitimate bug/deficiency?  Or am I
> just missing something?

I believe the functionality you are looking  for is the
TCP_USER_TIMEOUT socket option:

commit dca43c75e7e545694a9dd6288553f55c53e2a3a3
Author: Jerry Chu <hkchu@google.com>
Date:   Fri Aug 27 19:13:28 2010 +0000

    tcp: Add TCP_USER_TIMEOUT socket option.

    This patch provides a "user timeout" support as described in RFC793. The
    socket option is also needed for the the local half of RFC5482 "TCP User
    Timeout Option".

    TCP_USER_TIMEOUT is a TCP level socket option that takes an unsigned int,
    when > 0, to specify the maximum amount of time in ms that transmitted
    data may remain unacknowledged before TCP will forcefully close the
    corresponding connection and return ETIMEDOUT to the application. If
    0 is given, TCP will continue to use the system default.

    Increasing the user timeouts allows a TCP connection to survive extended
    periods without end-to-end connectivity. Decreasing the user timeouts
    allows applications to "fail fast" if so desired. Otherwise it may take
    upto 20 minutes with the current system defaults in a normal WAN
    environment.
    ....

Note how tcp_write_timeout() can pass in both sysctl_tcp_retries2 and
icsk->icsk_user_timeout to retransmits_timed_out(), and the
icsk->icsk_user_timeout value is used (if non-zero) in preference to
sysctl_tcp_retries2.

neal
