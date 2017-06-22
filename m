From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v3 07/11] tty: improve tty_insert_flip_char() fast path
Date: Thu, 22 Jun 2017 19:13:51 +0200
Message-ID: <20170622171355.267192-8-arnd@arndb.de>
References: <20170622171355.267192-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Kees Cook <keescook@chromium.org>,
        Ingo Molnar <mingo@kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kbuild@vger.kernel.org,
        Samuel Thibault <samuel.thibault@ens-lyon.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, stable@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170622171355.267192-1-arnd@arndb.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kernelci.org reports a crazy stack usage for the VT code when CONFIG_KASAN
is enabled:

drivers/tty/vt/keyboard.c: In function 'kbd_keycode':
drivers/tty/vt/keyboard.c:1452:1: error: the frame size of 2240 bytes is larger than 2048 bytes [-Werror=frame-larger-than=]

The problem is that tty_insert_flip_char() gets inlined many times into
kbd_keycode(), and also into other functions, and each copy requires 128
bytes for stack redzone to check for a possible out-of-bounds access on
the 'ch' and 'flags' arguments that are passed into
tty_insert_flip_string_flags as a variable-length string.

This introduces a new __tty_insert_flip_char() function for the slow
path, which receives the two arguments by value. This completely avoids
the problem and the stack usage goes back down to around 100 bytes.

Without KASAN, this is also slightly better, as we don't have to
spill the arguments to the stack but can simply pass 'ch' and 'flag'
in registers, saving a few bytes in .text for each call site.

This should be backported to linux-4.0 or later, which first introduced
the stack sanitizer in the kernel.

Cc: stable@vger.kernel.org
Fixes: c420f167db8c ("kasan: enable stack instrumentation")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I already submitted this separately to Greg, but he hasn't replied
yet. I assume that it's fine if Andrew picks it up along with the
other patches and drops it again in case Greg applies it to linux-next.

 drivers/tty/tty_buffer.c | 24 ++++++++++++++++++++++++
 include/linux/tty_flip.h |  3 ++-
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/tty/tty_buffer.c b/drivers/tty/tty_buffer.c
index 4e7a4e9dcf4d..2da05fa37aec 100644
--- a/drivers/tty/tty_buffer.c
+++ b/drivers/tty/tty_buffer.c
@@ -362,6 +362,30 @@ int tty_insert_flip_string_flags(struct tty_port *port,
 EXPORT_SYMBOL(tty_insert_flip_string_flags);
 
 /**
+ *	__tty_insert_flip_char   -	Add one character to the tty buffer
+ *	@port: tty port
+ *	@ch: character
+ *	@flag: flag byte
+ *
+ *	Queue a single byte to the tty buffering, with an optional flag.
+ *	This is the slow path of tty_insert_flip_char.
+ */
+int __tty_insert_flip_char(struct tty_port *port, unsigned char ch, char flag)
+{
+	struct tty_buffer *tb = port->buf.tail;
+	int flags = (flag == TTY_NORMAL) ? TTYB_NORMAL : 0;
+
+	if (!tty_buffer_request_room(port, 1))
+		return 0;
+
+	*flag_buf_ptr(tb, tb->used) = flag;
+	*char_buf_ptr(tb, tb->used++) = ch;
+
+	return 1;
+}
+EXPORT_SYMBOL(__tty_insert_flip_char);
+
+/**
  *	tty_schedule_flip	-	push characters to ldisc
  *	@port: tty port to push from
  *
diff --git a/include/linux/tty_flip.h b/include/linux/tty_flip.h
index c28dd523f96e..d43837f2ce3a 100644
--- a/include/linux/tty_flip.h
+++ b/include/linux/tty_flip.h
@@ -12,6 +12,7 @@ extern int tty_prepare_flip_string(struct tty_port *port,
 		unsigned char **chars, size_t size);
 extern void tty_flip_buffer_push(struct tty_port *port);
 void tty_schedule_flip(struct tty_port *port);
+int __tty_insert_flip_char(struct tty_port *port, unsigned char ch, char flag);
 
 static inline int tty_insert_flip_char(struct tty_port *port,
 					unsigned char ch, char flag)
@@ -26,7 +27,7 @@ static inline int tty_insert_flip_char(struct tty_port *port,
 		*char_buf_ptr(tb, tb->used++) = ch;
 		return 1;
 	}
-	return tty_insert_flip_string_flags(port, &ch, &flag, 1);
+	return __tty_insert_flip_char(port, ch, flag);
 }
 
 static inline int tty_insert_flip_string(struct tty_port *port,
-- 
2.9.0
