From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] poll: prevent missed events if _qproc is NULL
Date: Tue, 01 Jan 2013 10:42:30 -0800
Message-ID: <1357065750.21409.12527.camel@edumazet-glaptop>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Eric Wong <normalperson@yhbt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-12-31 at 13:21 +0000, Eric Wong wrote:
> This patch seems to fix my issue with ppoll() being stuck on my
> SMP machine: http://article.gmane.org/gmane.linux.file-systems/70414
> 
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

Hmm, the change seems not very logical to me.

If it helps, I would like to understand the real issue.

commit 626cf236608505d376e4799adb4f7eb00a8594af should not have this
side effect, at least for poll()/select() functions. The epoll() changes
I am not yet very confident.

I suspect a race already existed before this commit, it would be nice to
track it properly.
