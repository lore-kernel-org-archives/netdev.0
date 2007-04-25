From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Wed, 25 Apr 2007 22:51:43 +0200
Message-ID: <462FBF5F.20909@trash.net>
References: <E1HgVxj-0003U6-00@gondolin.me.apana.org.au>	<462F54F3.9050306@trash.net> <20070425124449.98bf091c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060406050409020007000703"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031123AbXDYUwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:52:10 -0400
In-Reply-To: <20070425124449.98bf091c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060406050409020007000703
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> I just retested bare net-2.6.22, pulled 30 minutes ago.  I got just one
> warning:
> 
> BUG: at kernel/mutex-debug.c:82 debug_mutex_unlock()
>  [<c012d18a>] debug_mutex_unlock+0x5a/0x134
>  [<c02d67e2>] __mutex_unlock_slowpath+0x9d/0xcf
>  [<f8c3618b>] ipw_wx_set_encode+0x0/0x82 [ipw2200]
>  [<c028b92c>] rtnl_unlock+0xa/0x29
>  [<c0286651>] dev_ioctl+0x3d0/0x402
>  [<c014b078>] __handle_mm_fault+0x7c6/0x7e8
>  [<c01a649b>] selinux_file_alloc_security+0x1f/0x40
>  [<c027b943>] sock_ioctl+0x0/0x1be
>  [<c0162925>] do_ioctl+0x19/0x4d
>  [<c0162b58>] vfs_ioctl+0x1ff/0x216
>  [<c0162bbb>] sys_ioctl+0x4c/0x65
>  [<c0103b0c>] syscall_call+0x7/0xb
>  [<c02d0000>] unix_dgram_sendmsg+0x76/0x400
>  =======================
> 
> It's 100% reproducible here, using
> http://userweb.kernel.org/~akpm/config-sony.txt
> 
> 
> The weird ASSERT_RTNL warnings aren't there, so something else in -mm
> (prior to git-net.patch in the series file) would appear to be interacting
> with net changes.


I think I found the problem, the rtnl_mutex was reinitialized on every
rtnetlink socket creation. This is most likely responsible for both
warnings.


--------------060406050409020007000703
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: don't reinitialize callback mutex

Don't reinitialize the callback mutex the netlink_kernel_create caller
handed in, it is supposed to already be initialized and could already
be held by someone.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9cc4e9c2d8b022c10ded98610a3cd76a8b89cf49
tree e53f10a158858e20ef2e9922cabc5bf43980708d
parent 7255fbb088e3f1b8be97472a38f645a8da595fe2
author Patrick McHardy <kaber@trash.net> Wed, 25 Apr 2007 22:47:20 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 25 Apr 2007 22:47:20 +0200

 net/netlink/af_netlink.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec16c9b..64d4b27 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -388,8 +388,12 @@ static int __netlink_create(struct socket *sock, struct mutex *cb_mutex,
 	sock_init_data(sock, sk);
 
 	nlk = nlk_sk(sk);
-	nlk->cb_mutex = cb_mutex ? : &nlk->cb_def_mutex;
-	mutex_init(nlk->cb_mutex);
+	if (cb_mutex)
+		nlk->cb_mutex = cb_mutex;
+	else {
+		nlk->cb_mutex = &nlk->cb_def_mutex;
+		mutex_init(nlk->cb_mutex);
+	}
 	init_waitqueue_head(&nlk->wait);
 
 	sk->sk_destruct = netlink_sock_destruct;

--------------060406050409020007000703--
