From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/sctp: sock memory leak
Date: Fri, 15 Jan 2016 20:11:03 +0100
Message-ID: <CACT4Y+Z6jY_n_cpmbFz366=JzoLX=u4Zc_o8gHFwJw8ApKf4zw@mail.gmail.com>
References: <CACT4Y+bf9h=vVSb82Jdv2GeV1MQPg15LW_AcV2BOw-XbMfNetw@mail.gmail.com>
 <20160115184620.GE6074@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33305 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245AbcAOTLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 14:11:24 -0500
Received: by mail-wm0-f46.google.com with SMTP id f206so35113042wmf.0
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 11:11:24 -0800 (PST)
In-Reply-To: <20160115184620.GE6074@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 7:46 PM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Wed, Dec 30, 2015 at 09:42:27PM +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> The following program leads to a leak of two sock objects:
> ...
>>
>> On commit 8513342170278468bac126640a5d2d12ffbff106 (Dec 28).
>
> I'm afraid I cannot reproduce this one?
> I enabled dynprintk at sctp_destroy_sock and it does print twice when I
> run this test app.
> Also added debugs to check association lifetime, and then it was
> destroyed. Same for endpoint.
>
> Checking with trace-cmd, both calls to sctp_close() resulted in
> sctp_destroy_sock() being called.
>
> As for sock_hold/put, they are matched too.
>
> Ideas? Log is below for double checking


Hummm... I can reproduce it pretty reliably.

[  197.459024] kmemleak: 11 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
[  307.494874] kmemleak: 409 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
[  549.784022] kmemleak: 125 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)

I double checked via /proc/slabinfo:

SCTPv6              4373   4420   2368   13    8 : tunables    0    0
  0 : slabdata    340    340      0

SCTPv6 starts with almost 0, but grows infinitely while I run the
program in a loop.

Here is my SCTP related configs:

CONFIG_IP_SCTP=y
CONFIG_NET_SCTPPROBE=y
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
# CONFIG_SCTP_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set

I am on commit 67990608c8b95d2b8ccc29932376ae73d5818727 and I don't
seem to have any sctp-related changes on top.
