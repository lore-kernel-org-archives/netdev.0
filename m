From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Tue, 23 Apr 2013 09:00:42 -0400
Message-ID: <20130423130041.GB31170@thunk.org>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 22, 2013 at 05:15:19PM -0700, Linus Torvalds wrote:
> Here's a ext4 code snippet that looks like an actual bug (but seems to only
> hit read-ahead):
> 
>     ext4_fsblk_t b, block;
> 
>     b = block & ~(EXT4_SB(sb)->s_inode_readahead_blks-1);
> 
> where "b" actually ends up having the upper bits cleared, because the
> s_inode_readahead_blks thing is an unsigned int, so you're masking off not
> just the low bits, but the high bits too. Ted? Of course, it's just
> read-ahead, so it probably doesn't matter, but.

Yep, it's a bug alright.  Thanks for catching it!

     	    		  	     	      - Ted


>From 0d606e2c9fccdd4e67febf1e2da500e1bfe9e045 Mon Sep 17 00:00:00 2001
From: Theodore Ts'o <tytso@mit.edu>
Date: Tue, 23 Apr 2013 08:59:35 -0400
Subject: [PATCH] ext4: fix type-widening bug in inode table readahead code

Due to a missing cast, the high 32-bits of a 64-bit block number used
when calculating the readahead block for inode tables can get lost.
This means we can end up fetching the wrong blocks for readahead for
file systems > 16TB.

Linus found this when experimenting with an enhacement to the sparse
static code checker which checks for missing widening casts before
binary "not" operators.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
---
 fs/ext4/inode.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index d7518e2..793d44b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4011,13 +4011,14 @@ make_io:
 		if (EXT4_SB(sb)->s_inode_readahead_blks) {
 			ext4_fsblk_t b, end, table;
 			unsigned num;
+			__u32 ra_blks = EXT4_SB(sb)->s_inode_readahead_blks;
 
 			table = ext4_inode_table(sb, gdp);
 			/* s_inode_readahead_blks is always a power of 2 */
-			b = block & ~(EXT4_SB(sb)->s_inode_readahead_blks-1);
+			b = block & ~((ext4_fsblk_t) ra_blks - 1);
 			if (table > b)
 				b = table;
-			end = b + EXT4_SB(sb)->s_inode_readahead_blks;
+			end = b + ra_blks;
 			num = EXT4_INODES_PER_GROUP(sb);
 			if (ext4_has_group_desc_csum(sb))
 				num -= ext4_itable_unused_count(sb, gdp);
-- 
1.7.12.rc0.22.gcdd159b

