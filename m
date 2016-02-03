From: Simon McVittie <simon.mcvittie@collabora.co.uk>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Wed, 3 Feb 2016 12:49:23 +0000
Message-ID: <56B1F753.4020304@collabora.co.uk>
References: <201601100657.u0A6vk1B025554@mail.home.local>
 <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
 <56B1E64F.3070206@collabora.co.uk>
 <CANq1E4Sz2U2D7hvWLEknbrKURG_ZbMiqAsVnd5yRF1Qesm3nEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	socketpair@gmail.com,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANq1E4Sz2U2D7hvWLEknbrKURG_ZbMiqAsVnd5yRF1Qesm3nEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/16 11:56, David Herrmann wrote:
> However, with Hannes' revised patch, a different DoS attack against
> dbus-daemon is possible. Imagine a peer that receives batches of FDs,
> but never dequeues them. They will be accounted on the inflight-limit
> of dbus-daemon, as such causing messages of independent peers to be
> rejected in case they carry FDs.
> Preferably, dbus-daemon would avoid queuing more than 16 FDs on a
> single destination (total). But that would require POLLOUT to be
> capped by the number of queued fds. A possible workaround is to add
> CAP_SYS_RESOURCE to dbus-daemon.

We have several mitigations for this:

* there's a limit on outgoing fds queued inside dbus-daemon for a
  particular recipient connection, currently 64, and if that's
  exceeded, we stop accepting messages for that recipient, feeding back
  a send failure to the sender for messages to that recipient;
* there's a time limit for how long any given fd can stay queued up
  inside dbus-daemon, currently 2.5 minutes, and if that's exceeded, we
  drop the message;
* if started as root[1], we increase our fd limit to 64k before
  dropping privileges to the intended uid, which in combination with
  the maximum of 256 connections per uid and 64 fds per connection means
  it takes multiple uids working together to carry out a DoS;
* all of those limits can be adjusted by a local sysadmin if necessary,
  if their users are particularly hostile (for instance 16 fds per
  message is a generous limit intended to avoid unforeseen breakage,
  and 4 would probably be enough in practice)

The queueing logic is fairly involved, so I'd appreciate suggested
patches on freedesktop.org Bugzilla or to
dbus-security@lists.freedesktop.org if you have an idea for better
limits. If you believe you have found a non-public vulnerability, please
mark any Bugzilla bugs as restricted to the D-Bus security group.

Thanks,
    S

[1] The system dbus-daemon is started as root (and hence able to
increase its own fd limit) on all systemd systems, anything that uses
the Red Hat or Slackware sysvinit scripts bundled with dbus, and any
Debian derivatives that use sysvinit and have taken security updates
from at least Debian 7. Other distro-specific init system glue is up to
the relevant distro.

-- 
Simon McVittie
Collabora Ltd. <http://www.collabora.com/>
