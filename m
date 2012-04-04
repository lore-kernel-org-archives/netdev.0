From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss
 command
Date: Wed, 04 Apr 2012 12:21:17 +0200
Message-ID: <1333534877.18626.566.camel@edumazet-glaptop>
References: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
	 <1333530463.18626.545.camel@edumazet-glaptop>
	 <20120404100015.D41B162C03E@msa106.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org
To: Kusanagi Kouichi <slash@ac.auone-net.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404100015.D41B162C03E@msa106.auone-net.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-04 at 19:00 +0900, Kusanagi Kouichi wrote:
> On 2012-04-04 11:07:43 +0200, Eric Dumazet wrote:
> > On Wed, 2012-04-04 at 18:03 +0900, Kusanagi Kouichi wrote:
> > > Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
> > > Move the sock_ code to net/core/"), ss command from iproute package
> > > doesn't work if INET_DIAG is not enabled.
> > > 
> > > $ ss
> > > State       Recv-Q Send-Q                                             Local Address:Port                                                 Peer Address:Port
> > > TCPDIAG answers: Operation not supported
> > > --
> > 
> > Try to update your iproute2 package ?
> 
> iproute seems up to date.
> $ ss --version
> ss utility, iproute2-ss120319
> 
> I tried git master commit 4bb00cd2b7525ad7d6cf6bbea945ad6e546873f4.
> It still fails.

Please try this patch :

diff --git a/misc/ss.c b/misc/ss.c
index 5414f75..8c00760 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1534,8 +1534,10 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 		.msg_iovlen = f->f ? 3 : 1,
 	};
 
-	if (sendmsg(fd, &msg, 0) < 0)
+	if (sendmsg(fd, &msg, 0) < 0) {
+		close(fd);
 		return -1;
+	}
 
 	iov[0] = (struct iovec){
 		.iov_base = buf,
@@ -1589,6 +1591,10 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 					fprintf(stderr, "ERROR truncated\n");
 				} else {
 					errno = -err->error;
+					if (errno == EOPNOTSUPP) {
+						close(fd);
+						return -1;
+					}
 					perror("TCPDIAG answers");
 				}
 				close(fd);
