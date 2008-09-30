From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Tue, 30 Sep 2008 23:30:52 +0200
Message-ID: <20080930213052.GA6449@ami.dom.local>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local> <48E1F417.7080304@free.fr> <20080930101030.GA6290@ff.dom.local> <20080930111733.GB6290@ff.dom.local> <48E29337.2080400@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:13630 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbYI3V1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 17:27:40 -0400
Received: by ey-out-2122.google.com with SMTP id 6so96896eyi.37
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 14:27:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48E29337.2080400@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 10:59:35PM +0200, Bernard Pidoux F6BVP wrote:
> Jarek,
>
> Yes I am using n2kpci/8390 driver.
> The second patch seems to have removed the inconsistent lock state.

It's fine: this patch is only for this one (simpler) problem.

> But the kernel panic still occured systematically.
> However I did not catch netconsole messages since the patch prevented  
> transmission to remote console via ethernet.
>
> Before the machine rebooted I only noted the following information at  
> the bottom of the local console page :
>
> EIP: [<.....>] datagram_poll + 0xe9/0xf0
>
> Does it help ?

Probably the beginning of the same oops as before.

Here is a debugging patch #2, which should give us more details.
Apply after reverting debugging patch #1 (lib8390 patch should stay).
Alas the oops in datagram_poll is still possible.

Thanks,
Jarek P.

---

 net/core/sock.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2d358dd..3ad8eaa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -960,6 +960,15 @@ void sk_free(struct sock *sk)
 {
 	struct sk_filter *filter;
 
+	if (sk->sk_socket) {
+		printk("AX25_DBG: %p, %p, %u, %u, %u, %p\n", sk, sk->sk_socket,
+			 sk->sk_family, sk->sk_type, sk->sk_protocol, sk->sk_socket->sk);
+		if (sk->sk_family == 3 && sk->sk_type == 5 && sk->sk_protocol == 240) {
+			WARN_ON_ONCE(1);
+			sock_orphan(sk);
+		}
+	}
+
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
 
