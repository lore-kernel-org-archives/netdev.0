From: Joe Perches <joe@perches.com>
Subject: rfc: Are any of the seq_pad() uses really necessary?
Date: Thu, 22 Sep 2016 14:52:08 -0700
Message-ID: <1474581128.8253.35.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

$ git grep -w seq_pad net
net/ipv4/fib_trie.c:            seq_pad(seq, '\n');
net/ipv4/ping.c:        seq_pad(seq, '\n');
net/ipv4/tcp_ipv4.c:    seq_pad(seq, '\n');
net/ipv4/udp.c: seq_pad(seq, '\n');
net/phonet/socket.c:    seq_pad(seq, '\n');
net/phonet/socket.c:    seq_pad(seq, '\n');
net/sctp/objcnt.c:      seq_pad(seq, '\n');

what these uses do is add trailing blanks to a particular
preset block width and then append a newline.

None of these trailing pad bytes seem useful to me.

Are there really tools that expect specific line widths
when reading from things like /proc/<pid>/net/<file>

For instance:

$ cat /proc/<pid>/net/udp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops             
  484: 00000000:14E9 00000000:0000 07 00000000:00000000 00:00000000 00000000   111        0 16961 2 0000000000000000 0         
  486: 00000000:14EB 00000000:0000 07 00000000:00000000 00:00000000 00000000   102        0 2022599 2 0000000000000000 0       
  788: 00000000:A619 00000000:0000 07 00000000:00000000 00:00000000 00000000  1000        0 4390482 2 0000000000000000 0       
 3081: 00000000:8F0E 00000000:0000 07 00000000:00000000 00:00000000 00000000   111        0 16963 2 0000000000000000 0         
 3376: 3500007F:0035 00000000:0000 07 00000000:00000000 00:00000000 00000000   102        0 2022601 2 0000000000000000 0       
 3391: 00000000:0044 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4546167 2 0000000000000000 0       

These seq_pad uses were modified by:

>From 652586df95e5d76b37d07a11839126dcfede1621 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 14 Nov 2013 14:31:57 -0800
Subject: [PATCH] seq_file: remove "%n" usage from seq_file users

All seq_printf() users are using "%n" for calculating padding size,
convert them to use seq_setwidth() / seq_pad() pair.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: Joe Perches <joe@perches.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

If these are really necessary, then maybe the seq_pad function
could be optimized using a memset instead of
	seq_printf(, "%*s", len, "");
