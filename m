From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] poll: prevent missed events if _qproc is NULL
Date: Mon, 31 Dec 2012 23:24:24 +0000
Message-ID: <20121231232424.GA24235@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:58801 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898Ab2LaXYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 18:24:25 -0500
Content-Disposition: inline
In-Reply-To: <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Wong <normalperson@yhbt.net> wrote:
> This patch seems to fix my issue with ppoll() being stuck on my
> SMP machine: http://article.gmane.org/gmane.linux.file-systems/70414

OK, it doesn't fix my issue, but it seems to make it harder-to-hit...

> The change to sock_poll_wait() in
> commit 626cf236608505d376e4799adb4f7eb00a8594af
>   (poll: add poll_requested_events() and poll_does_not_wait() functions)
> seems to have allowed additional cases where the SMP memory barrier
> is not issued before checking for readiness.
> 
> In my case, this affects the select()-family of functions
> which register descriptors once and set _qproc to NULL before
> checking events again (after poll_schedule_timeout() returns).
> The set_mb() barrier in poll_schedule_timeout() appears to be
> insufficient on my SMP x86-64 machine (as it's only an xchg()).
> 
> This may also be related to the epoll issue described by
> Andreas Voellmy in http://thread.gmane.org/gmane.linux.kernel/1408782/

However, I believe my patch will still fix Andreas' issue with epoll
due to how ep_modify() uses a NULL qproc when calling ->poll().

(I've never been able to reproduce Andreas' issue on my 4-core system,
 but he's been hitting it since 3.4 (at least))
