From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Tue, 2 Feb 2016 11:29:59 -0800
Message-ID: <CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com>
References: <201601100657.u0A6vk1B025554@mail.home.local>
	<CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
	<56B0F574.5080105@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Herrmann <dh.herrmann@gmail.com>, Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B0F574.5080105@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 2, 2016 at 10:29 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>>
>> Anyway, can someone provide a high-level description of what exactly
>> this patch is supposed to do? Which operation should be limited, who
>> should inflight FDs be accounted on, and which rlimit should be used
>> on each operation? I'm having a hard time auditing existing
>> user-space, given just the scarce description of this commit.
>
> Yes, all your observations are true. I think we need to explicitly
> need to refer to the sending socket while attaching the fds.

I don't think that really helps. Maybe somebody passed a unix domain
socket around, and now we're crediting the wrong socket again.

So how about we actually add a "struct cred *" to the scm_cookie
itself, and we initialize it to "get_current_cred()". And then always
use that.

That way it's always the person who actually does the send (rather
than the opener of the socket _or_ the opener of the file that gets
passed around) that gets credited, and thanks to the cred pointer we
can then de-credit them properly.

Hmm?

                Linus
