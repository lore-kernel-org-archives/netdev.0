From: Abhijit Menon-Sen <ams@wiw.org>
Subject: how is recv(..., MSG_PEEK) racy?
Date: Fri, 5 Sep 2003 16:16:42 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905161642.A29720@lustre.dyn.wiw.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(I posted this To: netdev twice, but it didn't show up, even though I am
receiving other posts from the list. I apologise if anyone gets multiple
copies of this message.)

I'm trying to understand a fetchmail problem that causes large downloads
from IMAP servers to fail randomly. For some reason, fetchmail uses the
following bizarre code inside a loop to read data from the server:

    if ((n = recv(sock, bp, len, MSG_PEEK)) <= 0)
        return (-1);

    if ((newline = memchr(bp, '\n', n)) != NULL)
        n = newline - bp + 1;

    if ((n = read(sock, bp, n)) == -1)
        return (-1);

The problem occurs (at an unpredictable time, but very often, and with a
greater probability with a larger attachment) when the recv() returns 0,
although tcpdump doesn't show the server closing the connection, or any
other unusual behaviour.

Are there any circumstances other than the connection being closed where
recv(..., MSG_PEEK) can return 0? (Stevens/SUSv3 don't mention any.)

I found the following (paraphrased) comment in net/ipv4/tcp.c:

    if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
        printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
               current->comm, current->pid);

While fetchmail doesn't seem to be triggering that printk(), I'm curious
about what the race condition is. Google found a post by DaveM saying it
has something to do with URG data, but without any further details. I'd
appreciate any explanation of the problem(s).

Thank you.

-- ams
