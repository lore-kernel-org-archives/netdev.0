From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2 v2] sctp: sctp_sendmsg: Don't initialize default_sinfo
Date: Thu, 12 May 2011 14:27:20 -0700
Message-ID: <1305235641.6124.64.camel@Joe-Laptop>
References: <cover.1305227620.git.joe@perches.com>
	 <a4e846ed62d7f9222dc9b09ca00b5356a1eb9b73.1305227620.git.joe@perches.com>
	 <20110512.170603.549349521517995900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110512.170603.549349521517995900.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This variable only needs initialization when cmsgs.info
is NULL.

Use memset to ensure padding is also zeroed so
kernel doesn't leak any data.

Signed-off-by: Joe Perches <joe@perches.com>

---

On Thu, 2011-05-12 at 17:06 -0400, David Miller wrote:
From: Joe Perches <joe@perches.com>
> Date: Thu, 12 May 2011 12:19:09 -0700
> > This variable only needs initialization when cmsgs.info
> > is NULL.
> > Don't use memset, just initialize every struct member.
> > Signed-off-by: Joe Perches <joe@perches.com>
> I don't think you do this, this structure has padding holes on pretty
> much every architecture.
> It starts with 3 u16's, then there is a u32, so there is a 2-byte
> piece of padding after the 3rd u16.
> Can you prove that these uninitialized portions never make it to
> userspace?  If you can, that proof belongs in the commit message.

Thanks David.  I didn't notice it went to userspace.

> I think it's too risky.

It is.  I like memset.

The current initialization isn't guaranteed by c90 standard
to zero all padding either.  In practice it does though.

The idea was to avoid doing a (non-memset) struct foo bar = {}
when unnecessary for every packet as it's only needed when
cmsgs.info is NULL.

 net/sctp/socket.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 33d9ee6..d4b8db1 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1496,7 +1496,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct sctp_chunk *chunk;
 	union sctp_addr to;
 	struct sockaddr *msg_name = NULL;
-	struct sctp_sndrcvinfo default_sinfo = { 0 };
+	struct sctp_sndrcvinfo default_sinfo;
 	struct sctp_sndrcvinfo *sinfo;
 	struct sctp_initmsg *sinit;
 	sctp_assoc_t associd = 0;
@@ -1760,6 +1760,7 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		/* If the user didn't specify SNDRCVINFO, make up one with
 		 * some defaults.
 		 */
+		memset(&default_sinfo, 0, sizeof(default_sinfo));
 		default_sinfo.sinfo_stream = asoc->default_stream;
 		default_sinfo.sinfo_flags = asoc->default_flags;
 		default_sinfo.sinfo_ppid = asoc->default_ppid;
