From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Tue, 15 Sep 2015 18:07:05 +0100
Message-ID: <878u87ipc6.fsf@doppelsaurus.mobileactivedefense.com>
References: <20150913195354.GA12352@jig.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150913195354.GA12352@jig.fritz.box> (Mathias Krause's message
	of "Sun, 13 Sep 2015 21:53:54 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mathias Krause <minipli@googlemail.com> writes:
> this is an attempt to resurrect the thread initially started here:
>
>   http://thread.gmane.org/gmane.linux.network/353003
>
> As that patch fixed the issue for the mentioned reproducer, it did not
> fix the bug for the production code Olivier is using. :(
>
> Changing the reproducer only slightly allows me to trigger the following
> list debug splat (CONFIG_DEBUG_LIST=y) reliable within seconds -- even
> with the above linked patch applied:

The patch was

--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
 <at>  <at>  -2233,10 +2233,14  <at>  <at>  static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
 	if (other) {
-		if (unix_peer(other) != sk) {
+		unix_state_lock(other);
+		if (!sock_flag(other, SOCK_DEAD) && unix_peer(other) != sk) {
+			unix_state_unlock(other);
 			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
 			if (unix_recvq_full(other))
 				writable = 0;
+		} else {
+			unix_state_unlock(other);
 		}
 		sock_put(other);
 	}

That's obviously not going to help you when 'racing with
unix_release_sock' as the socket might be released immediately after the
unix_state_unlock, ie, before sock_poll_wait is called. Provided I
understand this correctly, the problem is that the socket reference
count may have become 1 by the time sock_put is called but the
sock_poll_wait has created a new reference to it which isn't accounted
for.

A simple way to fix that could be to do something like

unix_state_lock(other);
if (!sock_flag(other, SOCK_DEAD)) sock_poll_wait(...)
unix_state_unlock(other);

This would imply that unix_release_sock either marked the socket as dead
before the sock_poll_wait was executed or that the wake_up_interruptible
call in there will run after ->peer_wait was used (and it will thus
'unpollwait' it again).
