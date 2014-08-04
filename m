From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Fw: [Bug 81661] New: Network Performance Regression for large TCP
 transfers starting with v3.10
Date: Mon, 4 Aug 2014 13:00:56 -0400
Message-ID: <CADVnQy=mp+m3s1xp7cZ0r4gpwHbMAnBNxAxcQx-AUtB7dZieiQ@mail.gmail.com>
References: <20140804090529.1a5d146d@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Yuchung Cheng <ycheng@google.com>
To: lexander.Steffen@infineon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:49701 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbaHDRBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 13:01:01 -0400
Received: by mail-wi0-f170.google.com with SMTP id f8so6594893wiw.5
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 10:00:57 -0700 (PDT)
In-Reply-To: <20140804090529.1a5d146d@haswell.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

Thanks for the detailed report!

We think we have a sense of what might be happening, but the traces
are a little hard to interpret.

The  capture-bad-site1 trace seems to be a sender-side trace that
shows SACK blocks with sequence numbers that are 613M bytes ahead of
what has actually been sent, suggesting perhaps a middlebox is
rewriting sequence numbers, but not SACK options, or vice versa.

The capture-bad-site2 trace seems well-formed, but seems to be taken
on the receiver side, which makes it difficult to interpret exactly
what is going wrong on the sending side.

Would you be able to reproduce the capture-bad-site2 case but take a
sender-side tcpdump trace?

Thanks!
neal



On Mon, Aug 4, 2014 at 12:05 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Mon, 4 Aug 2014 06:13:12 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 81661] New: Network Performance Regression for large TCP transfers starting with v3.10
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=81661
>
>             Bug ID: 81661
>            Summary: Network Performance Regression for large TCP transfers
>                     starting with v3.10
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.10 and later
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: Alexander.Steffen@infineon.com
>         Regression: No
>
> Created attachment 145061
>   --> https://bugzilla.kernel.org/attachment.cgi?id=145061&action=edit
> tshark captures of good/bad performance
>
> Our network consists of two separate geographical locations, that are
> transparently connected with some kind of VPN. Using newer kernel versions
> (v3.10 or later) we noticed a strange performance regression when transferring
> larger amounts of data via TCP (e.g. HTTP downloads of files). It only affects
> transfers from one location to the other, but not the other way around. The
> kernel version of the receiving machine does not seem to have any influence
> (tested: v3.2, v3.5, v3.11), whereas on the sending machine everything starting
> with v3.10 results in bad performance.
>
> The problem could be reproduced using iperf and bisecting showed
> 3e59cb0ddfd2c59991f38e89352ad8a3c71b2374 to be the first bad commit. Reverting
> this commit on top of v3.15.4 restores the performance of previous kernels.
>
> Reproducing this problem in a different environment does not seem to be so
> easy. Therefore, I've attached packet captures created with tshark on both the
> sending and the receiving side for the last good commit and the first bad
> commit when using iperf to demonstrate the problem (see output below). Our
> network experts did not find anything obviously wrong with the network
> configuration. Can you see any problem there from the packet captures? Or was
> the algorithm removed in 3e59cb0ddfd2c59991f38e89352ad8a3c71b2374 not so bad
> after all?
>
>
> This is the iperf output of 3cc7587b30032b7c4dd9610a55a77519e84da7db (the last
> good commit):
> user@site1:~$ iperf -c site2
> ------------------------------------------------------------
> Client connecting to site2, TCP port 5001 TCP window size: 20.1 KByte (default)
> ------------------------------------------------------------
> [  3] local 172.31.22.15 port 32821 connected with 172.31.25.248 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.1 sec  15.5 MBytes  12.9 Mbits/sec
>
> This is the iperf output of 3e59cb0ddfd2c59991f38e89352ad8a3c71b2374 (the first
> bad commit):
> user@site1:~$ iperf -c site2
> ------------------------------------------------------------
> Client connecting to site2, TCP port 5001 TCP window size: 20.1 KByte (default)
> ------------------------------------------------------------
> [  3] local 172.31.22.15 port 39947 connected with 172.31.25.248 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-11.3 sec  1.88 MBytes  1.39 Mbits/sec
>
> This is the corresponding iperf output on the server side:
> user@site2:~$ iperf -s
> ------------------------------------------------------------
> Server listening on TCP port 5001
> TCP window size: 85.3 KByte (default)
> ------------------------------------------------------------
> [  4] local 172.31.25.248 port 5001 connected with 172.31.22.15 port 32821
> [ ID] Interval       Transfer     Bandwidth
> [  4]  0.0-10.7 sec  15.5 MBytes  12.1 Mbits/sec [  5] local 172.31.25.248 port
> 5001 connected with 172.31.22.15 port 39947
> [  5]  0.0-19.0 sec  1.88 MBytes   826 Kbits/sec
>
> --
> You are receiving this mail because:
> You are the assignee for the bug.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
