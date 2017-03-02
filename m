From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 24/26] ocfs2: reduce stack size with KASAN
Date: Thu, 02 Mar 2017 15:58:17 -0800
Message-ID: <1488499097.2179.27.camel@perches.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
         <20170302163834.2273519-25-arnd@arndb.de>
         <1488476770.2179.6.camel@perches.com>
         <CAK8P3a1gW9UqMKD2ijzxMH4rv1zAji0GUoz+bLY_oi0yvLU1cw@mail.gmail.com>
         <1488494428.2179.23.camel@perches.com>
         <CAK8P3a2ZQR8ukt6Aky7onD2Y=b+Cz+pp+C0+Svb2EyK2474j-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2ZQR8ukt6Aky7onD2Y=b+Cz+pp+C0+Svb2EyK2474j-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-02 at 23:59 +0100, Arnd Bergmann wrote:
> KASAN decides that passing a pointer to _m into an extern function
> (_mlog_printk) is potentially dangerous, as that function might
> keep a reference to that pointer after it goes out of scope,
> or it might not know the correct length of the stack object pointed to.
> 
> We can see from looking at the __mlog_printk() function definition
> that it's actually safe, but the compiler cannot see that when looking
> at another source file.

OK, thanks.

btw:

changing __mlog_printk can save ~11% (90+KB) of object text size
by removing __func__ and __LINE__ and using vsprintf pointer extension
%pS, __builtin_return_address(0) as it is already used in dlmmaster.

(defconfig x86-64, with ocfs2)

$ size fs/ocfs2/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 759791	 111373	 105688	 976852	  ee7d4	fs/ocfs2/built-in.o.new
 852959	 111373	 105688	1070020	 1053c4	fs/ocfs2/built-in.o.old

It's nearly the same output.

---

 fs/ocfs2/cluster/masklog.c | 8 ++++----
 fs/ocfs2/cluster/masklog.h | 8 +++-----
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/ocfs2/cluster/masklog.c b/fs/ocfs2/cluster/masklog.c
index d331c2386b94..a3f080f37108 100644
--- a/fs/ocfs2/cluster/masklog.c
+++ b/fs/ocfs2/cluster/masklog.c
@@ -64,8 +64,7 @@ static ssize_t mlog_mask_store(u64 mask, const char *buf, size_t count)
 	return count;
 }
 
-void __mlog_printk(const u64 *mask, const char *func, int line,
-		   const char *fmt, ...)
+void __mlog_printk(const u64 *mask, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
@@ -90,9 +89,10 @@ void __mlog_printk(const u64 *mask, const char *func, int line,
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk("%s(%s,%u,%u):%s:%d %s%pV",
+	printk("%s(%s,%u,%u):%pS %s%pV",
 	       level, current->comm, task_pid_nr(current),
-	       raw_smp_processor_id(), func, line, prefix, &vaf);
+	       raw_smp_processor_id(), __builtin_return_address(0),
+	       prefix, &vaf);
 
 	va_end(args);
 }
diff --git a/fs/ocfs2/cluster/masklog.h b/fs/ocfs2/cluster/masklog.h
index 3c16da69605d..56ba5baf625b 100644
--- a/fs/ocfs2/cluster/masklog.h
+++ b/fs/ocfs2/cluster/masklog.h
@@ -162,9 +162,8 @@ extern struct mlog_bits mlog_and_bits, mlog_not_bits;
 
 #endif
 
-__printf(4, 5) __nocapture(2)
-void __mlog_printk(const u64 *m, const char *func, int line,
-		   const char *fmt, ...);
+__printf(2, 3) __nocapture(2)
+void __mlog_printk(const u64 *m, const char *fmt, ...);
 
 /*
  * Testing before the __mlog_printk call lets the compiler eliminate the
@@ -174,8 +173,7 @@ void __mlog_printk(const u64 *m, const char *func, int line,
 do {									\
 	u64 _m = MLOG_MASK_PREFIX | (mask);				\
 	if (_m & ML_ALLOWED_BITS)					\
-		__mlog_printk(&_m, __func__, __LINE__, fmt,		\
-			      ##__VA_ARGS__);				\
+		__mlog_printk(&_m, fmt, ##__VA_ARGS__);			\
 } while (0)
 
 #define mlog_errno(st) ({						\
