From: <gregkh@linuxfoundation.org>
Subject: Patch "tcp: Fix crash in TCP Fast Open" has been added to the 3.14-stable tree
Date: Fri, 17 Apr 2015 12:05:42 +0200
Message-ID: <14292651428767@kroah.com>
References: <1429120832.3211.91.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: <stable@vger.kernel.org>, <stable-commits@vger.kernel.org>
To: ben@decadent.org.uk, edumazet@google.com, eric.dumazet@gmail.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1429120832.3211.91.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a note to let you know that I've just added the patch titled

    tcp: Fix crash in TCP Fast Open

to the 3.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     tcp-fix-crash-in-tcp-fast-open.patch
and it can be found in the queue-3.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From ben@decadent.org.uk  Fri Apr 17 11:41:49 2015
From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 15 Apr 2015 19:00:32 +0100
Subject: tcp: Fix crash in TCP Fast Open
To: stable <stable@vger.kernel.org>
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, 782515@bugs.debian.org
Message-ID: <1429120832.3211.91.camel@decadent.org.uk>

From: Ben Hutchings <ben@decadent.org.uk>

Commit 355a901e6cf1 ("tcp: make connect() mem charging friendly")
changed tcp_send_syn_data() to perform an open-coded copy of the 'syn'
skb rather than using skb_copy_expand().

The open-coded copy does not cover the skb_shared_info::gso_segs
field, so in the new skb it is left set to 0.  When this commit was
backported into stable branches between 3.10.y and 3.16.7-ckty
inclusive, it triggered the BUG() in tcp_transmit_skb().

Since Linux 3.18 the GSO segment count is kept in the
tcp_skb_cb::tcp_gso_segs field and tcp_send_syn_data() does copy the
tcp_skb_cb structure to the new skb, so mainline and newer stable
branches are not affected.

Set skb_shared_info::gso_segs to the correct value of 1.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/ipv4/tcp_output.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2933,6 +2933,7 @@ static int tcp_send_syn_data(struct sock
 		goto fallback;
 	syn_data->ip_summed = CHECKSUM_PARTIAL;
 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
+	skb_shinfo(syn_data)->gso_segs = 1;
 	if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
 					 fo->data->msg_iov, 0, space))) {
 		kfree_skb(syn_data);


Patches currently in stable-queue which might be from ben@decadent.org.uk are

queue-3.14/tcp-fix-crash-in-tcp-fast-open.patch
