From: Patrick McHardy <kaber@trash.net>
Subject: Re: sfuzz hanging on 2.6.18
Date: Thu, 12 Oct 2006 09:46:47 +0200
Message-ID: <452DF2E7.5060501@trash.net>
References: <20061012073720.GB9274@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030504060703060000040102"
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11237 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422785AbWJLHpV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 03:45:21 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20061012073720.GB9274@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030504060703060000040102
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Dave Jones wrote:
> sfuzz         D 724EF62A  2828 28717  28691                     (NOTLB)
>        cd69fe98 00000082 0000012d 724ef62a 0001971a 00000010 00000007 df6d22b0 
>        dfd81080 725bbc5e 0001971a 000cc634 00000001 df6d23bc c140e260 00000202 
>        de1d5ba0 cd69fea0 de1d5ba0 00000000 00000000 de1d5b60 de1d5b8c de1d5ba0 
> Call Trace:
>  [<c05b1708>] lock_sock+0x75/0xa6
>  [<e0b0b604>] dn_getname+0x18/0x5f [decnet]
>  [<c05b083b>] sys_getsockname+0x5c/0xb0
>  [<c05b0b46>] sys_socketcall+0xef/0x261
>  [<c0403f97>] syscall_call+0x7/0xb
> DWARF2 unwinder stuck at syscall_call+0x7/0xb
> 
> I wonder if the plethora of lockdep related changes inadvertantly broke something?

Looks like unbalanced locking.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------030504060703060000040102
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 70e0273..3456cd3 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1178,8 +1178,10 @@ static int dn_getname(struct socket *soc
 	if (peer) {
 		if ((sock->state != SS_CONNECTED && 
 		     sock->state != SS_CONNECTING) && 
-		    scp->accept_mode == ACC_IMMED)
+		    scp->accept_mode == ACC_IMMED) {
+		    	release_sock(sk);
 			return -ENOTCONN;
+		}
 
 		memcpy(sa, &scp->peer, sizeof(struct sockaddr_dn));
 	} else {

--------------030504060703060000040102--
