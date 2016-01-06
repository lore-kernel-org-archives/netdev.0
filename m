From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Wed, 06 Jan 2016 14:45:55 +0000
Message-ID: <87ziwizrz0.fsf@doppelsaurus.mobileactivedefense.com>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
	<56826754.2060003@stressinduktion.org>
	<87ege2xve5.fsf@doppelsaurus.mobileactivedefense.com>
	<87ziwmk0b7.fsf@doppelsaurus.mobileactivedefense.com>
	<1451949906.2606240.482870994.43973946@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	David Miller <davem@davemloft.net>, dvyukov@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451949906.2606240.482870994.43973946@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Tue, 05 Jan 2016 00:25:06 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On Sun, Jan 3, 2016, at 19:03, Rainer Weikusat wrote:

[reorder i_mutex and readlock locking]

> I was concerned because of the comment in skb_socket_splice:
>
>         /* Drop the socket lock, otherwise we have reverse
>          * locking dependencies between sk_lock and i_mutex
>          * here as compared to sendfile(). We enter here
>          * with the socket lock held, and splice_to_pipe() will
>          * grab the pipe inode lock. For sendfile() emulation,
>          * we call into ->sendpage() with the i_mutex lock held
>          * and networking will grab the socket lock.
>          */

AFAICT, this comment is "a bit misleading": sendfile (from file to
socket) is internally implemented as 'splice from file to pipe' +
'splice from pipe to socket'. The later acquires the pipe lock of the
pipe and then invokes the sendpage method of the socket which acquires
the appropiate socket lock (for an AF_UNIX socket, it's
u->readlock). But 'pipe lock' and 'i_mutex' are two completely
different things: The former is the mutex in a struct pipe_inode_info
(pipe_fs_u.h), the latter is the i_mutex in a struct inode (fs.h).

"Code explains comment" :-)
