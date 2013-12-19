From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 13:43:06 -0800
Message-ID: <CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
References: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
	<1387475178.1876.29.camel@bwh-desktop.uk.level5networks.com>
	<ff7f7541d0164d408b3a4278569c593a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<52B33EC1.5040901@redhat.com>
	<6ee28c6a94e74c958ee96c3547741fb9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
	<05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch is below. This version did most pre-computation of the variants
I built, but results in largest table (40*256*4 bytes), This gives
performance roughly comparable with jhash (roughly same as jhash for
IPv4, about 30% more cycles for IPv6). I have the simpler less memory
intensive versions also if you're interested, these are 10x worse
cycles so I wouldn't want those in critical path.
----
Introduce Toeplitz hash functions. Toeplitz is a hash used primarily in
NICs to performan RSS flow steering.  This is a software implemenation
of that. In order to make the hash calculation efficient, we precompute
the possible hash values for each inidividual byte of input. The input
length is up to 40 bytes, so we make an array of cache[40][256].

The implemenation was verified against MSDN "Verify RSS hash" sample
values.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  3 +++
 include/linux/toeplitz.h  | 27 +++++++++++++++++++
 lib/Kconfig               |  3 +++
 lib/Makefile              |  2 ++
 lib/toeplitz.c            | 66 +++++++++++++++++++++++++++++++++++++++++++++++
 net/Kconfig               |  5 ++++
 net/core/dev.c            | 11 ++++++++
 7 files changed, 117 insertions(+)
 create mode 100644 include/linux/toeplitz.h
 create mode 100644 lib/toeplitz.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3de49ac..546caf2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -38,6 +38,7 @@
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 #include <linux/dynamic_queue_limits.h>
+#include <linux/toeplitz.h>

 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
@@ -195,6 +196,8 @@ struct net_device_stats {
 extern struct static_key rps_needed;
 #endif

+extern struct toeplitz *toeplitz_net;
+
 struct neighbour;
 struct neigh_parms;
 struct sk_buff;
diff --git a/include/linux/toeplitz.h b/include/linux/toeplitz.h
new file mode 100644
index 0000000..bc0b8e8
--- /dev/null
+++ b/include/linux/toeplitz.h
@@ -0,0 +1,27 @@
+#ifndef __LINUX_TOEPLITZ_H
+#define __LINUX_TOEPLITZ_H
+
+#define TOEPLITZ_KEY_LEN 40
+
+struct toeplitz {
+       u8 key_vals[TOEPLITZ_KEY_LEN];
+       u32 key_cache[TOEPLITZ_KEY_LEN][256];
+};
+
+static inline unsigned int
+toeplitz_hash(const unsigned char *bytes,
+             struct toeplitz *toeplitz, int n)
+{
+       int i;
+       unsigned int result = 0;
+
+       for (i = 0; i < n; i++)
+               result ^= toeplitz->key_cache[i][bytes[i]];
+
+        return result;
+};
+
+extern struct toeplitz *toeplitz_alloc(void);
+extern void toeplitz_init(struct toeplitz *toeplitz, u8 *key_vals);
+
+#endif /* __LINUX_TOEPLITZ_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index b3c8be0..463b2b1 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -359,6 +359,9 @@ config CPU_RMAP
 config DQL
        bool

+config TOEPLITZ
+       bool
+
 #
 # Netlink attribute parsing support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index f3bb2cb..a28349b 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -133,6 +133,8 @@ obj-$(CONFIG_CORDIC) += cordic.o

 obj-$(CONFIG_DQL) += dynamic_queue_limits.o

+obj-$(CONFIG_TOEPLITZ) += toeplitz.o
+
 obj-$(CONFIG_MPILIB) += mpi/
 obj-$(CONFIG_SIGNATURE) += digsig.o

diff --git a/lib/toeplitz.c b/lib/toeplitz.c
new file mode 100644
index 0000000..0951dd9
--- /dev/null
+++ b/lib/toeplitz.c
@@ -0,0 +1,66 @@
+/*
+ * Toeplitz hash implemenation. See include/linux/toeplitz.h
+ *
+ * Copyright (c) 2011, Tom Herbert <therbert@google.com>
+ */
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/random.h>
+#include <linux/toeplitz.h>
+
+struct toeplitz *toeplitz_alloc(void)
+{
+       return kmalloc(sizeof(struct toeplitz), GFP_KERNEL);
+}
+
+static u32 toeplitz_get_kval(unsigned char *key, int idx)
+{
+       u32 v, r;
+       int off, rem;
+
+       off = idx / 8;
+       rem = idx % 8;
+
+       v = (((unsigned int)key[off]) << 24) +
+           (((unsigned int)key[off + 1]) << 16) +
+           (((unsigned int)key[off + 2]) << 8) +
+           (((unsigned int)key[off + 3]));
+
+       r = v << rem | (unsigned int)key[off + 4] >> (8 - rem);
+       return r;
+}
+
+static inline int idx8(int idx)
+{
+#ifdef __LITTLE_ENDIAN
+        idx = (idx / 8) * 8 + (8 - (idx % 8 + 1));
+#endif
+        return idx;
+}
+
+void toeplitz_init(struct toeplitz *toeplitz, u8 *key_vals)
+{
+       int i;
+       unsigned long a, j;
+       unsigned int result = 0;
+
+       /* Set up key val table */
+       if (key_vals)
+               for (i = 0; i < TOEPLITZ_KEY_LEN; i++)
+                       toeplitz->key_vals[i] = key_vals[i];
+       else
+               prandom_bytes(toeplitz->key_vals, TOEPLITZ_KEY_LEN);
+
+       /* Set up key cache table */
+       for (i = 0; i < TOEPLITZ_KEY_LEN; i++) {
+               for (j = 0; j < 256; j++) {
+                       result = 0;
+                       for (a = find_first_bit(&j, 8); a < 8;
+                           a = find_next_bit(&j, 8, a + 1))
+                               result ^= toeplitz_get_kval(
+                                  toeplitz->key_vals, idx8(a + (i * 8)));
+                       toeplitz->key_cache[i][j] = result;
+               }
+       }
+}
diff --git a/net/Kconfig b/net/Kconfig
index b50dacc..860c9fa 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -254,6 +254,11 @@ config BQL
        select DQL
        default y

+config NET_TOEPLITZ
+       boolean
+       select TOEPLITZ
+       default n
+
 config BPF_JIT
        bool "enable BPF Just In Time compiler"
        depends on HAVE_BPF_JIT
diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2..074f530 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6633,6 +6633,9 @@ static struct pernet_operations __net_initdata
default_device_ops = {
        .exit_batch = default_device_exit_batch,
 };

+struct toeplitz *toeplitz_net;
+EXPORT_SYMBOL(toeplitz_net);
+
 /*
  *     Initialize the DEV module. At boot time this walks the device list and
  *     unhooks any devices that fail to initialise (normally hardware not
@@ -6656,6 +6659,14 @@ static int __init net_dev_init(void)
        if (netdev_kobject_init())
                goto out;

+#ifdef CONFIG_NET_TOEPLITZ
+       toeplitz_net = toeplitz_alloc();
+       if (!toeplitz_net)
+               goto out;
+
+       toeplitz_init(toeplitz_net, NULL);
+#endif
+
        INIT_LIST_HEAD(&ptype_all);
        for (i = 0; i < PTYPE_HASH_SIZE; i++)
                INIT_LIST_HEAD(&ptype_base[i]);

On Thu, Dec 19, 2013 at 12:49 PM, Haiyang Zhang <haiyangz@microsoft.com> wrote:
>
>
>> -----Original Message-----
>> From: Tom Herbert [mailto:therbert@google.com]
>> Sent: Thursday, December 19, 2013 2:59 PM
>> To: Haiyang Zhang
>> Cc: Daniel Borkmann; Ben Hutchings; davem@davemloft.net;
>> netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
>> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
>> devel@linuxdriverproject.org
>> Subject: Re: [PATCH net-next] hyperv: Add support for Virtual Receive Side
>> Scaling (vRSS)
>>
>> I posted an implementation of library functions for Toeplitz (see [PATCH 1/2]
>> net: Toeplitz library functions).  This includes some pre-computation of the
>> table to get reasonable performance in the host. Please take a look.
>>
>> On the other hand, if you're computing a hash in the host, do you really need
>> Toeplitz, flow_dissector already supports a good hash computation and can
>> parse many more packets than just plain UDP/TCP.
>> We probably only should be doing Toeplitz in the host if we need to match
>> HW computed values.
>
> The Hyper-V host requires the guest to select channel based on Toeplitz hash, so
> we need to compute it on the guest.
>
> Regarding the Toeplitz function, do you mean this patch?
> http://patchwork.ozlabs.org/patch/277344/
> This doesn't contain the implementation. Could you point me to the actual code?
>
> Thanks,
> - Haiyang
>
