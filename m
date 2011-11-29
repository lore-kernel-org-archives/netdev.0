From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v2] sctp: better integer overflow check in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 14:26:30 -0500
Message-ID: <125BB325-72D4-4FEF-A5CC-118680EC78D2@gmail.com>
References: <426D7BA8-ECD0-44D6-A09F-2033F0C825FC@gmail.com> <4ED3AC7D.6090108@hp.com> <147F953A-CC69-41FF-ACD4-64E5E2956411@gmail.com> <4ED4F428.9030807@hp.com> <A1A6AF9D-8C35-4702-9693-7BCBEDE27219@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A1A6AF9D-8C35-4702-9693-7BCBEDE27219@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The check from commit 30c2235c is incomplete and cannot prevent
cases like key_len = 0x80000000 (INT_MAX + 1).  In that case, the
left-hand side of the check (INT_MAX - key_len), which is unsigned,
becomes 0xffffffff (UINT_MAX) and bypasses the check.

However this shouldn't be a security issue.  The function is called
from the following two code paths:

 1) setsockopt()

 2) sctp_auth_asoc_set_secret()

In case (1), sca_keylength is never going to exceed 65535 since it's
bounded by a u16 from the user API.  As such, the key length will
never overflow.

In case (2), sca_keylength is computed based on the user key (1 short)
and 2 * key_vector (3 shorts) for a total of 7 * USHRT_MAX, which still
will not overflow.

In other words, this overflow check is not really necessary.  Just
make it more correct.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/auth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 865e68f..bf81204 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -82,7 +82,7 @@ static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
 	struct sctp_auth_bytes *key;
 
 	/* Verify that we are not going to overflow INT_MAX */
-	if ((INT_MAX - key_len) < sizeof(struct sctp_auth_bytes))
+	if (key_len > (INT_MAX - sizeof(struct sctp_auth_bytes)))
 		return NULL;
 
 	/* Allocate the shared key */
-- 
1.7.5.4
