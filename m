From: Cong Wang <cwang@twopensource.com>
Subject: Re: rtnl_mutex deadlock?
Date: Tue, 4 Aug 2015 22:31:30 -0700
Message-ID: <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:34221 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbHEFbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 01:31:31 -0400
Received: by ykax123 with SMTP id x123so27136562yka.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 22:31:31 -0700 (PDT)
In-Reply-To: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 4, 2015 at 8:48 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Sorry for the spamming of random rtnetlink people, but I just resumed
> my laptop at PDX, and networking was dead.
>
> It looks like a deadlock on rtnl_mutex, possibly due to some error
> path not releasing the lock. No network op was making any progress,
> and as you can see from the attached sysrq-w, it all seems to be hung
> in rtnl_lock().
>
> The call trace from NetworkManager looks different from the others,
> and looks to me like it might actually be a recursive invocation of
> rtnetlink_rcv(), but since I have a fairly light configuration on this
> laptop and don't have frame pointers enabled, I'm not sure how
> reliable that stack trace is. It might be just stale entries. But if
> they aren't stale, then that would certainly explain the deadlock.
>

You are right, looks like kernel received a GETLINK netlink message
from NetworkManager and then replied back but accidentally sent the
reply to itself, seems something wrong with NETLINK_CB(skb).portid.
