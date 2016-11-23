From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: sendfile from 9p fs into af_alg
Date: Wed, 23 Nov 2016 15:53:01 +0000
Message-ID: <20161123155301.GP1555@ZenIV.linux.org.uk>
References: <20161123035827.GA43786@ast-mbp.thefacebook.com>
 <20161123044625.GL1555@ZenIV.linux.org.uk>
 <20161123045558.GA43893@ast-mbp.thefacebook.com>
 <20161123061628.GN1555@ZenIV.linux.org.uk>
 <20161123085809.GA46992@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161123085809.GA46992@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2016 at 12:58:11AM -0800, Alexei Starovoitov wrote:

> if I read it correctly 9p actually responded with 8192 bytes of requests...
> whereas the file size was 9624.
> For large file sizes (in megabytes) the difference between what
> sendfile is reporting and actual file size can be 3x.
> In the small file case (like above dump) it looks rounded to page size for some reason.

OK, I think I see one bug in there; could you check if this gets it back to
normal?

diff --git a/fs/splice.c b/fs/splice.c
index dcaf185..5a7750b 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -408,7 +408,8 @@ static ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 	if (res <= 0)
 		return -ENOMEM;
 
-	nr_pages = res / PAGE_SIZE;
+	BUG_ON(dummy);
+	nr_pages = DIV_ROUND_UP(res, PAGE_SIZE);
 
 	vec = __vec;
 	if (nr_pages > PIPE_DEF_BUFFERS) {
