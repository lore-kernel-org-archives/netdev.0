From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Mon, 23 Feb 2004 10:42:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223094209.GA12663@suse.de>
References: <20040217121726.GD8554@suse.de> <20040221130853.4c98bad6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040221130853.4c98bad6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 21, 2004 at 01:08:53PM -0800, David S. Miller wrote:
> Well, first things first, using blocking sockets with select/poll is kind
> of stupid programming.

But that's the way many real world applications do it, including
for instance the glibc sunrpc code.

> I think we should fix it like the following, which is basically the last
> part of Olaf's original patch in this thread.  Just wait for another packet
> if a blocking socket and checksum fails, else if non-blocking -EAGAIN is OK.

But that breaks poll/recvmsg on a blocking socket, because poll with
assert POLLIN, but the recvmsg call with block.

I agree that plucking packets off the queue inside poll() is ugly.
The alternative would be to just walk the queue to see if there is at
least one packet with valid checksum, and clear POLLIN if there isn't,
but otherwise leave the queue untouched. This would work in all except
the most extreme scenarios where your recv queue is filled to the limit
with bad packets, and any new packets with potentially good checksums
get dropped. This would make it easy to DoS any UDP based service
by spraying it with bad udp packets.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 
