From: chetan loke <loke.chetan@gmail.com>
Subject: Re: TPACKET_V3 timeout bug?
Date: Tue, 2 May 2017 10:16:08 -0700
Message-ID: <CAAsGZS4e6XuDxprJUo+ZBY5x0AiWWL4z9Gw7nwe-vcFcrADfzQ@mail.gmail.com>
References: <20170415194042.GA5936@lunn.ch> <20170415224530.GA21010@oracle.com>
 <20170416021050.GA16418@lunn.ch> <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
 <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>,
        tcpdump-workers@lists.tcpdump.org
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34695 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdEBRQK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 13:16:10 -0400
Received: by mail-vk0-f47.google.com with SMTP id s85so13805122vka.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 10:16:09 -0700 (PDT)
In-Reply-To: <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 8:04 AM, chetan loke <loke.chetan@gmail.com> wrote:
> On Sat, Apr 15, 2017 at 7:41 PM, Guy Harris <guy@alum.mit.edu> wrote:
>> On Apr 15, 2017, at 7:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>
>>> Do you think this is a kernel problem, libpcap problem, or an
>>> application problem?
>>
>
> Its clearly a kernel regression.
>

Commit that caused it:

https://github.com/torvalds/linux/commit/41a50d621a321b4c15273cc1b5ed41437f4acdfb

Reverting that change is what we need.

When monitoring aggregated links (example: request going out on one
link and response coming in on another) you have to know when to start
mining packets for time-interval[s] to report anomalies etc. And the
block-retirement was designed such that the kernel would fill those
values for the app in the ts_first[/last]_pkt.

We have already amortized the cost by doing a bulk wakeup. And if
user-space holds on to the block even when it is empty (instead of
just using/copying the start/end time interval and releasing the
block) then its a bug in your app.

And if user-space is lagging behind then you will always run out of
buffer space. So I don't buy the entire commit argument of the patch.
