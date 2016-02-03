From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Wed, 3 Feb 2016 12:56:39 +0100
Message-ID: <CANq1E4Sz2U2D7hvWLEknbrKURG_ZbMiqAsVnd5yRF1Qesm3nEg@mail.gmail.com>
References: <201601100657.u0A6vk1B025554@mail.home.local>
	<CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
	<56B1E64F.3070206@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	socketpair@gmail.com,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Simon McVittie <simon.mcvittie@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B1E64F.3070206@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Wed, Feb 3, 2016 at 12:36 PM, Simon McVittie
<simon.mcvittie@collabora.co.uk> wrote:
> Am I right in saying that the advice I give to D-Bus users should be
> something like this?
>
> * system services should not send fds at all, unless they trust the
>   dbus-daemon
> * system services should not send fds via D-Bus that will be delivered
>   to recipients that they do not trust
> * sending fds to an untrusted recipient would enable that recipient to
>   carry out a denial-of-service attack (on what? the sender? the
>   dbus-daemon?)

With the revised patch from Hannes, this should no longer be needed.
My original concern was only about accounting inflight-fds on the
file-owner, rather than the sender.

However, with Hannes' revised patch, a different DoS attack against
dbus-daemon is possible. Imagine a peer that receives batches of FDs,
but never dequeues them. They will be accounted on the inflight-limit
of dbus-daemon, as such causing messages of independent peers to be
rejected in case they carry FDs.
Preferably, dbus-daemon would avoid queuing more than 16 FDs on a
single destination (total). But that would require POLLOUT to be
capped by the number of queued fds. A possible workaround is to add
CAP_SYS_RESOURCE to dbus-daemon.

Thanks
David
