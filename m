From: Takashi Hibi <hibi665@oki.com>
Subject: Re: Kernel 2.4.22 MLD problems
Date: Tue, 16 Dec 2003 17:24:18 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031216172417.1ba1c59e%hibi665@oki.com>
References: <OF606B371E.03D6C1CF-ON88256DF9.007F6B6C@us.ibm.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>, netdev@oss.sgi.com
In-Reply-To: (Your message of "Thu, 11 Dec 2003 15:19:55 -0800")
  <OF606B371E.03D6C1CF-ON88256DF9.007F6B6C@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Steven,

> Takashi,
> 
>>>But there are still some problems.
>>>[MLDv2]
>>>1. After joining multicast address, MLDv2 listener report isn't issued
>>>immediately.
>>
>>This looks like a bug; it should send the first one immediately,
>>and QRV-1 more at random intervals between 0 and MRC. It's adding
>>the MRC random delay before sending the first one. Not critical,
>>but I'll put a patch together in the next couple of days.
> 
> I thought this was a bug, from a quick glance at the code, but I
> just looked some more and it already does the fix I had in mind.
> I also ran some tests, and I do see the advertisement immediately
> after an interface state change. That was with 2.6.0-test11bk8,
> but 2.4.22 has the same code for this piece.
> 
> In MLDv1 compatibility mode, interface state changes are not sent, but a
> "leave group" will result in an MLDv1 leave group message. So, I can't
> explain (or reproduce) this behaviour right now.
> 
> Please do send me a packet trace with the MLD packets and describing
> what your application is doing in more detail if you still have a problem
> with
> this.
> 
>                         +-DLS


I found a problem in the code of MLDv1 compatibility mode.
The computation of Older Version Querier Present Timeout is wrong.

In the draft of MLDv2 9.12

   This value MUST be ([Robustness Variable] times (the [Query
   Interval] in the last Query received)) plus ([Query Response
   Interval]).

In the code (patch-2.4.24-pre1 is applied)

        if (len == 24) {
                int switchback;
                /* MLDv1 router present */

                /* Translate milliseconds to jiffies */
                max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;

                switchback = (idev->mc_qrv + 1) * max_delay;
                idev->mc_v1_seen = jiffies + switchback;


With the default setting, max_delay is 10sec and QRV is 2.
So the host reverts to MLDv2 mode after only 30sec.

The correct timeout value is 2*125+10=260 sec. (125sec is the
default value of Query Interval)

It isn't very easy to fix it. The host must save the last query interval, 
because MLDv1 packet doesn't include QQIC(Querier's Query Interval Code).
If it is OK to use default value, it is easy to fix.

Regards,
Takashi Hibi
