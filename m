From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] random: introduce get_random_bytes_busy_wait_initialized
Date: Wed, 25 Sep 2013 11:00:34 +0200
Message-ID: <20130925090034.GC4904@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924054532.GA24446@order.stressinduktion.org> <1380028797.3165.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, tytso@mit.edu,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380028797.3165.65.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 24, 2013 at 06:19:57AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> A host might need net_secret[] and never open a single socket. 
> 
> Problem added in commit aebda156a570782
> ("net: defer net_secret[] initialization")
> 
> Based on prior patch from Hannes Frederic Sowa.
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Perhaps we can even do a bit better? This patch is a RFC and I could split the
random and network parts if needed.

[PATCH RFC] random: introduce get_random_bytes_busy_wait_initialized

We want to use good entropy for initializing the secret keys used for
hashing in the core network stack. So busy wait before extracting random
data until the nonblocking_pool is initialized.

Further entropy is also gathered by interrupts, so we are guaranteed to
make progress here.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/char/random.c  | 18 ++++++++++++++++++
 include/linux/random.h |  1 +
 net/core/secure_seq.c  |  3 ++-
 net/ipv4/af_inet.c     |  2 +-
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 7737b5b..50e8030 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1058,6 +1058,24 @@ void get_random_bytes(void *buf, int nbytes)
 EXPORT_SYMBOL(get_random_bytes);
 
 /*
+ * Busy loop until the nonblocking_pool is intialized and return
+ * random data in buf of size nbytes.
+ *
+ * This is used by the network stack to defer the extraction of
+ * entropy from the nonblocking_pool until the pool is initialized.
+ *
+ * We need to busy loop here, because we could be called from an
+ * atomic section.
+ */
+void get_random_bytes_busy_wait_initialized(void *buf, int nbytes)
+{
+	while (!nonblocking_pool.initialized)
+		cpu_relax();
+	get_random_bytes(buf, nbytes);
+}
+EXPORT_SYMBOL(get_random_bytes_busy_wait_initialized);
+
+/*
  * This function will use the architecture-specific hardware random
  * number generator if it is available.  The arch-specific hw RNG will
  * almost certainly be faster than what we can do in software, but it
diff --git a/include/linux/random.h b/include/linux/random.h
index 3b9377d..0b7e7dd 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -15,6 +15,7 @@ extern void add_input_randomness(unsigned int type, unsigned int code,
 extern void add_interrupt_randomness(int irq, int irq_flags);
 
 extern void get_random_bytes(void *buf, int nbytes);
+void get_random_bytes_busy_wait_initialized(void *buf, int nbbytes);
 extern void get_random_bytes_arch(void *buf, int nbytes);
 void generate_random_uuid(unsigned char uuid_out[16]);
 
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 3f1ec15..ac55cb7 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -24,7 +24,8 @@ static void net_secret_init(void)
 
 	for (i = NET_SECRET_SIZE; i > 0;) {
 		do {
-			get_random_bytes(&tmp, sizeof(tmp));
+			get_random_bytes_busy_wait_initialized(&tmp,
+							       sizeof(tmp));
 		} while (!tmp);
 		cmpxchg(&net_secret[--i], 0, tmp);
 	}
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cfeb85c..3edd277 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -260,7 +260,7 @@ void build_ehash_secret(void)
 	u32 rnd;
 
 	do {
-		get_random_bytes(&rnd, sizeof(rnd));
+		get_random_bytes_busy_wait_initialized(&rnd, sizeof(rnd));
 	} while (rnd == 0);
 
 	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0)
-- 
1.8.3.1
