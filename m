From: Simon McVittie <simon.mcvittie@collabora.co.uk>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Wed, 3 Feb 2016 11:36:47 +0000
Message-ID: <56B1E64F.3070206@collabora.co.uk>
References: <201601100657.u0A6vk1B025554@mail.home.local>
 <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	socketpair@gmail.com,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: David Herrmann <dh.herrmann@gmail.com>, Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/02/16 17:34, David Herrmann wrote:
> Furthermore, with this patch in place, a process better not pass any
> file-descriptors to an untrusted process.
...
> Did anyone notify the dbus maintainers of this? They
> might wanna document this, if not already done (CC: smcv).

Sorry, I'm not clear from this message on what patterns I should be
documenting as bad, and what the effect of non-compliance would be.

dbus-daemon has a fd-passing feature, which uses AF_UNIX sockets'
existing ability to pass fds to let users of D-Bus attach fds to their
messages. The message is passed from the sending client to dbus-daemon,
then from dbus-daemon to the recipient:

             AF_UNIX             AF_UNIX
               |                    |
    sender -------> dbus-daemon -------> recipient
               |                    |

This has been API since before I was a D-Bus maintainer, so I have no
influence over its existence; just like the kernel doesn't want to break
user-space, dbus-daemon doesn't want to break its users.

The system dbus-daemon (dbus-daemon --system) is a privilege boundary,
and accepts senders and recipients with differing privileges. Without
configuration, messages are denied by default. Recipients can open this
up (by installing system-wide configuration) to allow arbitrary
processes to send messages to them, so that they can carry out their own
discretionary access control. Since 2014, the system dbus-daemon accepts
up to 16 file descriptors per message by default.

There is also a session or user dbus-daemon (dbus-daemon --session) per
uid, but that isn't normally a privilege boundary, so any user trying to
carry out a denial of service there is only hurting themselves.

Am I right in saying that the advice I give to D-Bus users should be
something like this?

* system services should not send fds at all, unless they trust the
  dbus-daemon
* system services should not send fds via D-Bus that will be delivered
  to recipients that they do not trust
* sending fds to an untrusted recipient would enable that recipient to
  carry out a denial-of-service attack (on what? the sender? the
  dbus-daemon?)

-- 
Simon McVittie
Collabora Ltd. <http://www.collabora.com/>
